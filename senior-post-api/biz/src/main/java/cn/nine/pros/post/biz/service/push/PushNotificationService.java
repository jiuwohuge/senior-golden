package cn.nine.pros.post.biz.service.push;

/**
 * §11.6 推送通知：FCM/APNs 未配置时降级为日志 no-op。
 */
public interface PushNotificationService {

    void notifyLetterDelivered(long recipientUserId, long letterId);

    void notifyPenpalRequest(long targetUserId, long requesterUserId, long requestId);

    void notifyPenpalAccepted(long requesterUserId, long accepterUserId);

    void notifyTimeLetterDelivered(long recipientUserId, long timeLetterId);

    void notifyAuditRejected(long senderUserId, long letterId);
}
