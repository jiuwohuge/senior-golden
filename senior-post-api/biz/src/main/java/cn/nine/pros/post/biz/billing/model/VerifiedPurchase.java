package cn.nine.pros.post.biz.billing.model;

import java.time.LocalDateTime;

/**
 * Provider 校验通过后的购买快照。
 *
 * @param provider         mock|google_play
 * @param purchaseToken    原始 token（调用方负责 hash/截断，勿日志全文）
 * @param storeProductId   商店商品 ID
 * @param purchaseStatus   pending|purchased|canceled|refunded|revoked
 * @param subscriptionStatus pending|active|canceled|expired|revoked|on_hold|…
 * @param periodStart      当前周期开始
 * @param periodEnd        当前周期结束
 * @param autoRenew        是否自动续订
 * @param isTrial          是否试用
 * @param orderId          外部订单号
 * @param environment      sandbox|production
 * @param rawSnapshot      可选原始快照（JSON 字符串）
 * @param scenario         mock 场景名（可空）
 */
public record VerifiedPurchase(
        String provider,
        String purchaseToken,
        String storeProductId,
        String purchaseStatus,
        String subscriptionStatus,
        LocalDateTime periodStart,
        LocalDateTime periodEnd,
        boolean autoRenew,
        boolean isTrial,
        String orderId,
        String environment,
        String rawSnapshot,
        String scenario
) {
}
