package cn.nine.pros.post.biz.schedule.job;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

/**
 * 失效推送终端清理占位（默认关闭）。
 */
@Slf4j
@Component
public class PushEndpointCleanupJob {

    /** 占位 tick：无业务副作用。 */
    public void run() {
        log.debug("schedule placeholder PushEndpointCleanupJob ran (no-op)");
    }
}
