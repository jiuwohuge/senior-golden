package cn.nine.pros.post.biz.billing.model;

/**
 * 解析后的 RTDN / 商店通知。
 */
public record ParsedNotification(
        String provider,
        String eventType,
        String purchaseToken,
        String storeProductId,
        String rawPayload,
        String messageId,
        String scenario
) {
}
