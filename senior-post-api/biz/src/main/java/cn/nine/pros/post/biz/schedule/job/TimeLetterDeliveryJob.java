package cn.nine.pros.post.biz.schedule.job;

import cn.nine.pros.post.biz.schedule.SchedulerProperties;
import cn.nine.pros.post.biz.service.timeletter.TimeLetterDeliveryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

/**
 * 时光信到期投递扫描。
 * <p>批大小优先 {@link SchedulerProperties}；缺省 200（与历史 TimeLetterProperties 一致）。
 */
@Component
@RequiredArgsConstructor
public class TimeLetterDeliveryJob {

    private static final int DEFAULT_BATCH = 200;

    private final TimeLetterDeliveryService timeLetterDeliveryService;
    private final SchedulerProperties schedulerProperties;

    /** 投递当前到期的时光信批次。 */
    public void run() {
        Integer configured = schedulerProperties.getTimeLetterDelivery().getBatchSize();
        int batchSize = configured != null && configured > 0 ? configured : DEFAULT_BATCH;
        timeLetterDeliveryService.deliverDueLetters(batchSize);
    }
}
