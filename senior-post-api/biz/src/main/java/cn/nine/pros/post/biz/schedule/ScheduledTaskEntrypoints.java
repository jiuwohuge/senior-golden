package cn.nine.pros.post.biz.schedule;

import cn.nine.pros.post.biz.schedule.job.BillingEventRetryJob;
import cn.nine.pros.post.biz.schedule.job.BillingReconciliationJob;
import cn.nine.pros.post.biz.schedule.job.MailOutboxDispatchJob;
import cn.nine.pros.post.biz.schedule.job.NotificationOutboxJob;
import cn.nine.pros.post.biz.schedule.job.PostOfficeMatchJob;
import cn.nine.pros.post.biz.schedule.job.PushEndpointCleanupJob;
import cn.nine.pros.post.biz.schedule.job.StandardLetterDeliveryJob;
import cn.nine.pros.post.biz.schedule.job.TimeLetterDeliveryJob;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * 统一定时任务入口：唯一允许声明 {@link Scheduled} 的类。
 * <p>职责：开关、分布式锁、启动/失败日志与异常隔离；不含业务 SQL。
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ScheduledTaskEntrypoints {

    private final DistributedJobLock distributedJobLock;
    private final SchedulerProperties schedulerProperties;
    private final MailOutboxDispatchJob mailOutboxDispatchJob;
    private final PostOfficeMatchJob postOfficeMatchJob;
    private final StandardLetterDeliveryJob standardLetterDeliveryJob;
    private final TimeLetterDeliveryJob timeLetterDeliveryJob;
    private final NotificationOutboxJob notificationOutboxJob;
    private final BillingEventRetryJob billingEventRetryJob;
    private final BillingReconciliationJob billingReconciliationJob;
    private final PushEndpointCleanupJob pushEndpointCleanupJob;

    @Scheduled(fixedDelayString = "${senior-post.scheduler.mail-outbox.fixed-delay-ms:${senior-post.mail.outbox.poll-delay-ms:10000}}")
    public void mailOutbox() {
        tick("mailOutbox", schedulerProperties.getMailOutbox(), mailOutboxDispatchJob::run);
    }

    @Scheduled(fixedDelayString = "${senior-post.scheduler.post-office-match.fixed-delay-ms:${senior-post.match.fixed-delay-ms:20000}}")
    public void postOfficeMatch() {
        tick("postOfficeMatch", schedulerProperties.getPostOfficeMatch(), postOfficeMatchJob::run);
    }

    @Scheduled(fixedDelayString = "${senior-post.scheduler.standard-letter-delivery.fixed-delay-ms:${senior-post.mailbox.standard-delivery-fixed-delay-ms:30000}}")
    public void standardLetterDelivery() {
        tick("standardLetterDelivery", schedulerProperties.getStandardLetterDelivery(),
                standardLetterDeliveryJob::run);
    }

    @Scheduled(fixedDelayString = "${senior-post.scheduler.time-letter-delivery.fixed-delay-ms:${senior-post.time-letter.delivery-fixed-delay-ms:60000}}")
    public void timeLetterDelivery() {
        tick("timeLetterDelivery", schedulerProperties.getTimeLetterDelivery(), timeLetterDeliveryJob::run);
    }

    @Scheduled(fixedDelayString = "${senior-post.scheduler.notification-outbox.fixed-delay-ms:60000}")
    public void notificationOutbox() {
        tick("notificationOutbox", schedulerProperties.getNotificationOutbox(), notificationOutboxJob::run);
    }

    @Scheduled(fixedDelayString = "${senior-post.scheduler.billing-event-retry.fixed-delay-ms:60000}")
    public void billingEventRetry() {
        tick("billingEventRetry", schedulerProperties.getBillingEventRetry(), billingEventRetryJob::run);
    }

    @Scheduled(fixedDelayString = "${senior-post.scheduler.billing-reconciliation.fixed-delay-ms:60000}")
    public void billingReconciliation() {
        tick("billingReconciliation", schedulerProperties.getBillingReconciliation(),
                billingReconciliationJob::run);
    }

    @Scheduled(fixedDelayString = "${senior-post.scheduler.push-endpoint-cleanup.fixed-delay-ms:60000}")
    public void pushEndpointCleanup() {
        tick("pushEndpointCleanup", schedulerProperties.getPushEndpointCleanup(),
                pushEndpointCleanupJob::run);
    }

    /**
     * 单任务 tick：禁用跳过 → 抢锁 → 执行 → 异常隔离 → 解锁。
     */
    private void tick(String jobName, SchedulerProperties.JobConfig config, Runnable job) {
        if (!config.isEnabled()) {
            log.debug("schedule skip disabled job={}", jobName);
            return;
        }
        long ttlMs = resolveLockTtl(config);
        if (!distributedJobLock.tryLock(jobName, ttlMs)) {
            log.debug("schedule skip lock not acquired job={}", jobName);
            return;
        }
        log.info("schedule start job={}", jobName);
        try {
            job.run();
        } catch (Throwable t) {
            log.error("schedule failed job={}", jobName, t);
        } finally {
            distributedJobLock.unlock(jobName);
        }
    }

    private long resolveLockTtl(SchedulerProperties.JobConfig config) {
        Long override = config.getLockTtlMs();
        if (override != null && override > 0) {
            return override;
        }
        return schedulerProperties.getLockTtlMs();
    }
}
