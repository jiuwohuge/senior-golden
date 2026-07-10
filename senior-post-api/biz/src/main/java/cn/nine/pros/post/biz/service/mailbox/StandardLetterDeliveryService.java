package cn.nine.pros.post.biz.service.mailbox;

import cn.nine.pros.post.biz.model.domain.LetterDomain;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.biz.service.push.PushNotificationService;
import cn.nine.pros.post.client.common.enums.LetterAuditStatus;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;

/**
 * 到期自动送达：扫描 DELIVERING 且 expected_arrival_time 到期的信件；
 * DELIVERED 前须 audit_status=APPROVED；REJECTED 则中止。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class StandardLetterDeliveryService {

    private final LetterService letterService;
    private final PushNotificationService pushNotificationService;

    /**
     * 将已到预计送达时间的在途信置为已送达（不限 letter_type；速度由 §6.1 决定）。
     */
    @Transactional(rollbackFor = Exception.class)
    public int deliverDueStandardLetters(LocalDateTime now, int maxBatch) {
        List<LetterDomain> due = letterService.listDueDelivering(now, maxBatch);

        int delivered = 0;
        int skippedAudit = 0;
        int abortedReject = 0;
        for (LetterDomain row : due) {
            if (row.getId() == null) {
                continue;
            }
            Integer audit = row.getAuditStatus();
            if (Objects.equals(audit, LetterAuditStatus.REJECTED.getCode())) {
                abortedReject += abortRejectedDelivery(row.getId(), now);
                continue;
            }
            if (!Objects.equals(audit, LetterAuditStatus.APPROVED.getCode())
                    && audit != null) {
                skippedAudit++;
                continue;
            }
            if (letterService.markDelivered(row.getId(), now)) {
                delivered++;
                notifyDelivered(row);
                log.debug("letter {} marked delivered at {}", row.getId(), now);
            }
        }
        if (delivered > 0 || skippedAudit > 0 || abortedReject > 0) {
            log.info("mail delivery: delivered={}, skippedAudit={}, abortedReject={} (batch {})",
                    delivered, skippedAudit, abortedReject, maxBatch);
        }
        return delivered;
    }

    private void notifyDelivered(LetterDomain row) {
        if (row.getToUserId() == null || row.getId() == null) {
            return;
        }
        pushNotificationService.notifyLetterDelivered(row.getToUserId(), row.getId());
    }

    private int abortRejectedDelivery(long letterId, LocalDateTime now) {
        if (!letterService.abortDeliveryRejected(letterId, now)) {
            return 0;
        }
        log.info("letter delivery aborted (rejected), letterId={}", letterId);
        return 1;
    }
}
