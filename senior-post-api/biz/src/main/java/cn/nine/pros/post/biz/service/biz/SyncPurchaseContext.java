package cn.nine.pros.post.biz.service.biz;

/**
 * 购买同步上下文（客户端上报字段）。
 *
 * @param productId    商店/内部商品码
 * @param packageName  包名
 * @param orderId      外部订单号
 * @param acknowledged 是否已 acknowledge
 * @param isTrial      是否试用
 * @param scenario     mock 场景（可空）
 */
public record SyncPurchaseContext(
        String productId,
        String packageName,
        String orderId,
        Boolean acknowledged,
        Boolean isTrial,
        String scenario
) {
    public static SyncPurchaseContext of(
            String productId,
            String packageName,
            String orderId,
            Boolean acknowledged,
            Boolean isTrial) {
        return new SyncPurchaseContext(productId, packageName, orderId, acknowledged, isTrial, null);
    }
}
