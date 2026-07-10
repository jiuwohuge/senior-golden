package cn.nine.pros.post.biz.schedule;

import cn.nine.pros.post.biz.service.base.MailOutboxService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class MailOutboxDispatchScheduler {

    private final MailOutboxService mailOutboxService;

    @Scheduled(fixedDelayString = "${senior-post.mail.outbox.poll-delay-ms:10000}")
    public void dispatchOutbox() {
        try {
            mailOutboxService.processPendingBatch();
        } catch (RuntimeException e) {
            log.error("mail outbox dispatch batch failed", e);
        }
    }
}
