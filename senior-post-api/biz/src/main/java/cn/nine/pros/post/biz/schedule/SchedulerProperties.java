package cn.nine.pros.post.biz.schedule;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * 统一定时任务开关、周期与批次配置。
 * <p>延迟默认值与历史键对齐；YAML 可用嵌套占位符让旧键继续驱动新键。
 */
@Data
@ConfigurationProperties(prefix = "senior-post.scheduler")
public class SchedulerProperties {

    /** 全局分布式锁 TTL（毫秒）；须大于典型 tick 耗时。 */
    private long lockTtlMs = 120_000L;

    private JobConfig mailOutbox = JobConfig.enabled(10_000L, 20);
    private JobConfig postOfficeMatch = JobConfig.enabled(20_000L, 200);
    private JobConfig standardLetterDelivery = JobConfig.enabled(30_000L, 200);
    private JobConfig timeLetterDelivery = JobConfig.enabled(60_000L, 200);
    private JobConfig notificationOutbox = JobConfig.disabledWithBatch(60_000L, 50);
    private JobConfig billingEventRetry = JobConfig.disabled(60_000L);
    private JobConfig billingReconciliation = JobConfig.disabled(60_000L);
    private JobConfig pushEndpointCleanup = JobConfig.disabled(60_000L);

    /**
     * 单个定时任务的开关与参数。
     */
    @Data
    public static class JobConfig {

        /** 是否启用；关闭时入口跳过且不抢锁。 */
        private boolean enabled = true;

        /** fixedDelay 间隔（毫秒）。 */
        private long fixedDelayMs = 60_000L;

        /** 可选批大小；无批概念的任务可忽略。 */
        private Integer batchSize;

        /** 可选锁 TTL 覆盖；为空则用全局 lockTtlMs。 */
        private Long lockTtlMs;

        static JobConfig enabled(long fixedDelayMs, int batchSize) {
            JobConfig c = new JobConfig();
            c.enabled = true;
            c.fixedDelayMs = fixedDelayMs;
            c.batchSize = batchSize;
            return c;
        }

        static JobConfig disabled(long fixedDelayMs) {
            JobConfig c = new JobConfig();
            c.enabled = false;
            c.fixedDelayMs = fixedDelayMs;
            return c;
        }

        static JobConfig disabledWithBatch(long fixedDelayMs, int batchSize) {
            JobConfig c = disabled(fixedDelayMs);
            c.batchSize = batchSize;
            return c;
        }
    }
}
