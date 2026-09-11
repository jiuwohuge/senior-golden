package cn.nine.pros.post.biz.schedule.job;

import cn.nine.pros.post.biz.service.base.MailOutboxService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

/**
 * 邮件 Outbox 派发：拉取 pending 批次并发送。
 * <p>批大小仍由 {@code senior-post.mail.outbox.batch-size} / SeniorPostMailOutboxProperties 控制。
 */
@Component
@RequiredArgsConstructor
public class MailOutboxDispatchJob {

    private final MailOutboxService mailOutboxService;

    /** 处理一批评待邮件。 */
    public void run() {
        mailOutboxService.processPendingBatch();
    }
}
