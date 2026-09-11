package cn.nine.pros.post.biz.service.push;

/**
 * FCM 发送 SPI：mock / real 实现由配置选择。
 */
public interface FcmSender {

    /**
     * 发送一条推送。
     *
     * @param token   设备 token（勿记日志）
     * @param title   标题
     * @param body    正文（不含信件内容）
     * @param dataJson 数据载荷 JSON 字符串
     * @return 发送结果
     */
    FcmSendResult send(String token, String title, String body, String dataJson);

    /** 提供者标识：mock|fcm。 */
    String provider();

    /**
     * 发送结果。
     */
    record FcmSendResult(
            boolean success,
            String sendStatus,
            String messageId,
            String errorMessage,
            boolean invalidToken
    ) {
        public static FcmSendResult ok(String sendStatus, String messageId) {
            return new FcmSendResult(true, sendStatus, messageId, null, false);
        }

        public static FcmSendResult fail(String sendStatus, String error, boolean invalidToken) {
            return new FcmSendResult(false, sendStatus, null, error, invalidToken);
        }

        public static FcmSendResult skipped(String reason) {
            return new FcmSendResult(false, "skipped", null, reason, false);
        }
    }
}
