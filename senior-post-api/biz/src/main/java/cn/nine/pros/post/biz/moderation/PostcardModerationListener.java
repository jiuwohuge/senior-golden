package cn.nine.pros.post.biz.moderation;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Slf4j
@Component
@RequiredArgsConstructor
public class PostcardModerationListener {

    private final PostcardModerationOrchestrator orchestrator;

    @Async("postcardModerationExecutor")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void onPostcardCreated(PostcardCreatedEvent event) {
        try {
            orchestrator.moderatePostcard(event.postcardId());
        } catch (Exception e) {
            log.error("Postcard moderation async failed id={}", event.postcardId(), e);
        }
    }
}
