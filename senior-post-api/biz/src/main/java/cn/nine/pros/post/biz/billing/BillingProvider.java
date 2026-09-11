package cn.nine.pros.post.biz.billing;

import cn.nine.pros.post.biz.billing.model.ParsedNotification;
import cn.nine.pros.post.biz.billing.model.RestoreCommand;
import cn.nine.pros.post.biz.billing.model.SubscriptionSnapshot;
import cn.nine.pros.post.biz.billing.model.VerifiedPurchase;
import cn.nine.pros.post.biz.billing.model.VerifyPurchaseCommand;

import java.util.List;

/**
 * 支付渠道 SPI：校验购买、查询订阅、acknowledge、解析通知、恢复。
 */
public interface BillingProvider {

    /** @return {@link BillingProviders#MOCK} 或 {@link BillingProviders#GOOGLE_PLAY} 等 */
    String providerName();

    VerifiedPurchase verifyPurchase(VerifyPurchaseCommand cmd);

    SubscriptionSnapshot getSubscription(String purchaseToken);

    void acknowledgePurchase(String purchaseToken, String productId);

    ParsedNotification parseNotification(String rawPayload);

    List<VerifiedPurchase> restorePurchases(RestoreCommand cmd);
}
