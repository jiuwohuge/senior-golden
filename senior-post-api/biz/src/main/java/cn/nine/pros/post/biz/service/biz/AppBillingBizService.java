package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.client.model.input.app.BillingMockRtdnInDto;
import cn.nine.pros.post.client.model.input.app.BillingMockSyncInDto;
import cn.nine.pros.post.client.model.input.app.BillingTestOverrideInDto;
import cn.nine.pros.post.client.model.input.app.PlayPurchaseVerifyInDto;
import cn.nine.pros.post.client.model.input.app.PlayRestoreInDto;
import cn.nine.pros.post.client.model.out.SubscriptionStatusVO;

/**
 * App Plus / Play Billing 业务编排。
 */
public interface AppBillingBizService {

    SubscriptionStatusVO getSubscriptionStatus(long userId);

    SubscriptionStatusVO verifyPurchase(long userId, PlayPurchaseVerifyInDto body);

    SubscriptionStatusVO restore(long userId, PlayRestoreInDto body);

    SubscriptionStatusVO testOverride(long userId, BillingTestOverrideInDto body);

    /** 本地 mock 同步（需 billing.mock-enabled）。 */
    SubscriptionStatusVO mockSync(long userId, BillingMockSyncInDto body);

    /** Mock RTDN 回放（需 billing.mock-enabled；须登录为 token 绑定用户）。 */
    SubscriptionStatusVO mockReplayRtdn(long userId, BillingMockRtdnInDto body);
}
