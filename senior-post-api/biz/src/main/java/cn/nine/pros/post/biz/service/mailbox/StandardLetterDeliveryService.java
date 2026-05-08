package cn.nine.pros.post.biz.service.mailbox;

import cn.nine.pros.post.biz.mapper.LetterMapper;
import cn.nine.pros.post.biz.model.domain.LetterDomain;
import cn.nine.pros.post.biz.service.base.LetterService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 平邮到期自动送达：以 {@code bu_letter.expected_arrival_time} 为准，乐观条件更新避免重复投递。
 * Redis 延迟队列可作为后续扩展（高并发扫表优化），当前实现满足 FP-A5d-002 验收。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class StandardLetterDeliveryService {

    private static final int STATUS_DELIVERED = 2;
    /** 系统任务更新人（与业务用户 ID 区分） */
    private static final long SYSTEM_UPDATED_BY = 0L;

    private final LetterMapper letterMapper;
    private final LetterService letterService;

    /**
     * 将已到预计送达时间的平邮置为已送达。
     *
     * @param now      当前时间（可注入便于单测）
     * @param maxBatch 单次处理上限
     * @return 实际更新行数
     */
    @Transactional(rollbackFor = Exception.class)
    public int deliverDueStandardLetters(LocalDateTime now, int maxBatch) {
        List<LetterDomain> due = letterMapper.selectList(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .apply("letter_type = 2")
                .apply("status = 1")
                .isNotNull(LetterDomain::getExpectedArrivalTime)
                .le(LetterDomain::getExpectedArrivalTime, now)
                .orderByAsc(LetterDomain::getExpectedArrivalTime)
                .last("LIMIT " + maxBatch));

        int delivered = 0;
        for (LetterDomain row : due) {
            if (row.getId() == null) {
                continue;
            }
            boolean ok = letterService.update(new LambdaUpdateWrapper<LetterDomain>()
                    .eq(LetterDomain::getId, row.getId())
                    .eq(LetterDomain::isDelFlag, false)
                    .apply("letter_type = 2")
                    .apply("status = 1")
                    .set(LetterDomain::getStatus, STATUS_DELIVERED)
                    .set(LetterDomain::getActualArrivalTime, now)
                    .set(LetterDomain::getUpdatedAt, now)
                    .set(LetterDomain::getUpdatedBy, SYSTEM_UPDATED_BY));
            if (ok) {
                delivered++;
                log.debug("Standard letter {} marked delivered at {}", row.getId(), now);
            }
        }
        if (delivered > 0) {
            log.info("Standard mail delivery: {} letter(s) delivered (batch cap {})", delivered, maxBatch);
        }
        return delivered;
    }
}
