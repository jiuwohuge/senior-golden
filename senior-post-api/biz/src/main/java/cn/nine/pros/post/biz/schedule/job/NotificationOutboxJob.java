package cn.nine.pros.post.biz.schedule.job;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

/**
 * 通知 Outbox 派发占位（默认关闭；后续接 FCM Outbox）。
 */
@Slf4j
@Component
public class NotificationOutboxJob {

    /** 占位 tick：无业务副作用。 */
    public void run() {
        log.debug("schedule placeholder NotificationOutboxJob ran (no-op)");
    }
}
