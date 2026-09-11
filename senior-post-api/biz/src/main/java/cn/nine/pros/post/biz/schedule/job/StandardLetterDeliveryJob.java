package cn.nine.pros.post.biz.schedule.job;

import cn.nine.pros.post.biz.schedule.SchedulerProperties;
import cn.nine.pros.post.biz.service.mailbox.StandardLetterDeliveryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/**
 * 标准信（平邮）到期自动送达扫描。
 */
@Component
@RequiredArgsConstructor
public class StandardLetterDeliveryJob {

    private static final int DEFAULT_BATCH = 200;

    private final StandardLetterDeliveryService standardLetterDeliveryService;
    private final SchedulerProperties schedulerProperties;

    /** 投递当前到期的标准信批次。 */
    public void run() {
        Integer configured = schedulerProperties.getStandardLetterDelivery().getBatchSize();
        int batchSize = configured != null && configured > 0 ? configured : DEFAULT_BATCH;
        standardLetterDeliveryService.deliverDueStandardLetters(LocalDateTime.now(), batchSize);
    }
}
