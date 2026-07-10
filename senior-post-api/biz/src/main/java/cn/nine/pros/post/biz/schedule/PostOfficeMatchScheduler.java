package cn.nine.pros.post.biz.schedule;

import cn.nine.pros.post.biz.service.biz.PostOfficeMatchService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/**
 * 定时 drain POST_OFFICE 匹配池，并自动放行超时审核。
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class PostOfficeMatchScheduler {

    private final PostOfficeMatchService postOfficeMatchService;

    @Scheduled(fixedDelayString = "${senior-post.match.fixed-delay-ms:20000}")
    public void tick() {
        try {
            postOfficeMatchService.runMatchBatch(LocalDateTime.now());
        } catch (Exception e) {
            log.warn("POST_OFFICE match tick failed: {}", e.getMessage());
        }
    }
}
