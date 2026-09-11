package cn.nine.pros.post.biz.billing.model;

import java.time.LocalDateTime;

/**
 * 订阅查询快照（getSubscription）。
 */
public record SubscriptionSnapshot(
        String provider,
        String purchaseToken,
        String storeProductId,
        String status,
        LocalDateTime periodStart,
        LocalDateTime periodEnd,
        boolean autoRenew,
        boolean isTrial
) {
}
