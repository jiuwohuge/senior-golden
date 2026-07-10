package cn.nine.pros.post.biz.service.timeletter;

import cn.nine.pros.post.biz.config.TimeLetterProperties;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.TimeLetterDomain;
import cn.nine.pros.post.biz.service.base.TimeLetterService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.common.enums.TimeLetterStatus;
import cn.nine.pros.post.client.model.db.UserDTO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class TimeLetterDeliveryService {

    private static final long SYSTEM_UPDATED_BY = 0L;
    private static final int USER_STATUS_NORMAL = 1;

        private final TimeLetterService timeLetterService;
    private final UserService userService;
    private final TimeLetterProperties properties;
    private final AppMessages appMessages;

    @Transactional(rollbackFor = Exception.class)
    public int deliverDueLetters(int maxBatch) {
        List<TimeLetterDomain> pending = timeLetterService.list(new LambdaQueryWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::isDelFlag, false)
                .eq(TimeLetterDomain::getStatus, TimeLetterStatus.PENDING.getCode())
                .orderByAsc(TimeLetterDomain::getDeliveryDate)
                .last("LIMIT " + maxBatch));

        int delivered = 0;
        int failed = 0;
        for (TimeLetterDomain row : pending) {
            if (row.getId() == null || row.getDeliveryDate() == null) {
                continue;
            }
            if (!isDue(row)) {
                continue;
            }
            Long recipientId = row.getRecipientId() != null ? row.getRecipientId() : row.getSenderId();
            if (!canUserReceive(recipientId)) {
                if (markFailed(row, appMessages.get("app.timeLetter.fail.recipientUnavailable"))) {
                    failed++;
                }
                continue;
            }
            if (!canUserReceive(row.getSenderId())) {
                if (markFailed(row, appMessages.get("app.timeLetter.fail.senderUnavailable"))) {
                    failed++;
                }
                continue;
            }
            LocalDateTime now = LocalDateTime.now();
            boolean ok = timeLetterService.update(new LambdaUpdateWrapper<TimeLetterDomain>()
                    .eq(TimeLetterDomain::getId, row.getId())
                    .eq(TimeLetterDomain::isDelFlag, false)
                    .eq(TimeLetterDomain::getStatus, TimeLetterStatus.PENDING.getCode())
                    .set(TimeLetterDomain::getStatus, TimeLetterStatus.DELIVERED.getCode())
                    .set(TimeLetterDomain::getDeliveredAt, now)
                    .set(TimeLetterDomain::getUpdatedAt, now)
                    .set(TimeLetterDomain::getUpdatedBy, SYSTEM_UPDATED_BY));
            if (ok) {
                delivered++;
            }
        }
        if (delivered > 0 || failed > 0) {
            log.info("Time letter delivery: delivered={}, failed={}", delivered, failed);
        }
        return delivered;
    }

    private boolean isDue(TimeLetterDomain row) {
        String tz = row.getDeliveryTz();
        ZoneId zone;
        try {
            zone = ZoneId.of(tz != null && !tz.isBlank() ? tz : "UTC");
        } catch (Exception e) {
            zone = ZoneId.of("UTC");
        }
        LocalDate today = ZonedDateTime.now(zone).toLocalDate();
        return !today.isBefore(row.getDeliveryDate());
    }

    private boolean canUserReceive(Long userId) {
        if (userId == null) {
            return false;
        }
        UserDTO u = userService.findById(userId);
        if (u == null) {
            return false;
        }
        return userStatus(u.getStatus()) == USER_STATUS_NORMAL;
    }

    private boolean markFailed(TimeLetterDomain row, String reason) {
        LocalDateTime now = LocalDateTime.now();
        return timeLetterService.update(new LambdaUpdateWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::getId, row.getId())
                .eq(TimeLetterDomain::isDelFlag, false)
                .eq(TimeLetterDomain::getStatus, TimeLetterStatus.PENDING.getCode())
                .set(TimeLetterDomain::getStatus, TimeLetterStatus.FAILED.getCode())
                .set(TimeLetterDomain::getFailReason, reason)
                .set(TimeLetterDomain::getUpdatedAt, now)
                .set(TimeLetterDomain::getUpdatedBy, SYSTEM_UPDATED_BY));
    }


    private static int userStatus(Object status) {
        if (status instanceof Number n) {
            return n.intValue();
        }
        if (status instanceof String s) {
            return Integer.parseInt(s);
        }
        return 0;
    }
}
