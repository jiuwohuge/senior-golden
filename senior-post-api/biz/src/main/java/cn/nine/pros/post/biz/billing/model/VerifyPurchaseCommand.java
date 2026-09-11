package cn.nine.pros.post.biz.billing.model;

/**
 * 校验购买命令。
 *
 * @param userId        当前用户
 * @param purchaseToken 商店 purchaseToken（勿日志全文）
 * @param productId     商店/内部商品码（如 plus_yearly）
 * @param packageName   应用包名
 * @param orderId       外部订单号
 * @param acknowledged  客户端是否已 acknowledge
 * @param isTrial       是否试用（可空，由 provider 推断）
 * @param scenario      mock 场景（可空；token 内也可携带）
 */
public record VerifyPurchaseCommand(
        long userId,
        String purchaseToken,
        String productId,
        String packageName,
        String orderId,
        Boolean acknowledged,
        Boolean isTrial,
        String scenario
) {
}
