package cn.nine.pros.post.biz.schedule.job;

import cn.nine.pros.post.biz.schedule.SchedulerProperties;
import cn.nine.pros.post.biz.service.push.NotificationOutboxDispatchService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

/**
 * 通知 Outbox 派发任务：认领 pending → FCM（mock/real）→ 写 delivery。
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class NotificationOutboxJob {

    private final NotificationOutboxDispatchService dispatchService;
    private final SchedulerProperties schedulerProperties;

    /**
     * 执行一轮派发；batchSize 来自 {@code senior-post.scheduler.notification-outbox.batch-size}，默认 50。
     */
    public NotificationOutboxDispatchService.DispatchSummary run() {
        Integer configured = schedulerProperties.getNotificationOutbox() != null
                ? schedulerProperties.getNotificationOutbox().getBatchSize()
                : null;
        int batchSize = configured != null && configured > 0 ? configured : 50;
        NotificationOutboxDispatchService.DispatchSummary summary = dispatchService.processBatch(batchSize);
        if (summary.claimed() > 0) {
            log.info("NotificationOutboxJob finished, claimed={}, sent={}, failed={}, deliveries={}",
                    summary.claimed(), summary.sent(), summary.failed(), summary.deliveries());
        } else {
            log.debug("NotificationOutboxJob idle (no pending)");
        }
        return summary;
    }
}
