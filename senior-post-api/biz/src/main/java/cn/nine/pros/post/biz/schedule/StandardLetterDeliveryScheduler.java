package cn.nine.pros.post.biz.schedule;

import cn.nine.pros.post.biz.service.mailbox.StandardLetterDeliveryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/**
 * 定时扫描到期平邮并送达。间隔可通过配置调整。
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class StandardLetterDeliveryScheduler {

    private final StandardLetterDeliveryService standardLetterDeliveryService;

    @Value("${senior-post.mailbox.standard-delivery-batch-size:200}")
    private int batchSize;

    @Scheduled(fixedDelayString = "${senior-post.mailbox.standard-delivery-fixed-delay-ms:30000}")
    public void tick() {
        try {
            standardLetterDeliveryService.deliverDueStandardLetters(LocalDateTime.now(), batchSize);
        } catch (Exception e) {
            log.warn("Standard letter delivery tick failed: {}", e.getMessage());
        }
    }
}
