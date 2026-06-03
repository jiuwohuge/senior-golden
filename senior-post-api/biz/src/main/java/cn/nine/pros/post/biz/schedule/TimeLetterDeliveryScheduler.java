package cn.nine.pros.post.biz.schedule;

import cn.nine.pros.post.biz.config.TimeLetterProperties;
import cn.nine.pros.post.biz.service.timeletter.TimeLetterDeliveryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class TimeLetterDeliveryScheduler {

    private final TimeLetterDeliveryService timeLetterDeliveryService;
    private final TimeLetterProperties properties;

    @Scheduled(fixedDelayString = "${senior-post.time-letter.delivery-fixed-delay-ms:60000}")
    public void tick() {
        try {
            timeLetterDeliveryService.deliverDueLetters(properties.getDeliveryBatchSize());
        } catch (Exception e) {
            log.warn("Time letter delivery tick failed: {}", e.getMessage());
        }
    }
}
