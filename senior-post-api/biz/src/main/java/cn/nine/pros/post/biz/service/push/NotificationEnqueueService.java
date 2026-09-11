package cn.nine.pros.post.biz.service.push;

/**
 * 通知入队业务服务：可在调用方事务内写入 Outbox（默认 REQUIRED）。
 */
public interface NotificationEnqueueService {

    /**
     * 入队信件推送事件（仅 {@code letter_matched_in_transit}/{@code letter_arrived}）。
     * <p>支付类 eventType 抛 BusinessException；dedupe 冲突返回已有 outboxId。
     *
     * @return outbox 行 id
     */
    long enqueueLetterEvent(String eventType, long letterId, long recipientUserId);
}
