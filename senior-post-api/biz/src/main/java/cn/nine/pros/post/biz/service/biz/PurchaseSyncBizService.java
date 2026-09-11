package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.client.model.out.SubscriptionStatusVO;

/**
 * 购买同步编排：校验 → 落库 purchase/subscription/tx/entitlement → VIP 镜像。
 */
public interface PurchaseSyncBizService {

    /**
     * 同步一笔购买到支付公共表与 VIP 兼容镜像。
     *
     * @param provider      {@code mock} / {@code google_play}
     * @param purchaseToken 商店 token（勿日志全文）
     * @param userId        当前用户
     * @param ctx           客户端上下文
     * @return 同步后订阅状态 VO（由调用方可再 build；本方法返回简要状态供编排）
     */
    SubscriptionStatusVO syncPurchase(String provider, String purchaseToken, long userId, SyncPurchaseContext ctx);
}
