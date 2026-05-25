package cn.nine.pros.post.biz.moderation;

import cn.nine.pros.post.biz.config.ModerationProperties;
import cn.nine.pros.post.biz.model.domain.PostcardDomain;
import cn.nine.pros.post.biz.service.base.PostcardService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class PostcardModerationRetryScheduler {

    private final PostcardService postcardService;
    private final PostcardModerationOrchestrator orchestrator;
    private final ModerationProperties moderationProperties;

    @Scheduled(fixedDelayString = "${senior-post.moderation.retry-fixed-delay-ms:120000}")
    public void retryStalePending() {
        int minutes = Math.max(1, moderationProperties.getPendingRetryMinutes());
        LocalDateTime before = LocalDateTime.now().minusMinutes(minutes);
        List<PostcardDomain> rows = postcardService.list(new LambdaQueryWrapper<PostcardDomain>()
                .eq(PostcardDomain::isDelFlag, false)
                .apply("review_status = 0")
                .and(w -> w.isNull(PostcardDomain::getMachineReviewedAt)
                        .or()
                        .lt(PostcardDomain::getMachineReviewedAt, before))
                .lt(PostcardDomain::getCreatedAt, before)
                .last("LIMIT 20"));
        for (PostcardDomain row : rows) {
            if (row.getId() == null) {
                continue;
            }
            try {
                orchestrator.moderatePostcard(row.getId());
            } catch (Exception e) {
                log.warn("Postcard moderation retry failed id={}: {}", row.getId(), e.getMessage());
            }
        }
    }
}
