package cn.nine.pros.post.biz.schedule.job;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

/**
 * 计费对账占位（默认关闭；不全量轮询 Play API）。
 */
@Slf4j
@Component
public class BillingReconciliationJob {

    /** 占位 tick：无业务副作用。 */
    public void run() {
        log.debug("schedule placeholder BillingReconciliationJob ran (no-op)");
    }
}
