package cn.nine.pros.post.biz.schedule.job;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

/**
 * 计费渠道事件重试占位（默认关闭）。
 */
@Slf4j
@Component
public class BillingEventRetryJob {

    /** 占位 tick：无业务副作用。 */
    public void run() {
        log.debug("schedule placeholder BillingEventRetryJob ran (no-op)");
    }
}
