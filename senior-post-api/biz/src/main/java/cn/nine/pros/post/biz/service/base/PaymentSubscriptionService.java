package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.PaymentSubscriptionDomain;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 * 支付订阅（bu_subscription）Base Service。
 */
public interface PaymentSubscriptionService extends IService<PaymentSubscriptionDomain> {

    PaymentSubscriptionDomain findByTokenHash(String purchaseTokenHash);

    /** 按购买主单 ID 查找关联订阅。 */
    PaymentSubscriptionDomain findByPurchaseId(Long purchaseId);

    /** 用户最新一条未删除订阅（按 updated_at / period_end 倒序）。 */
    PaymentSubscriptionDomain findLatestForUser(long userId);

    /**
     * 按 token hash 幂等写入/刷新订阅行；无 hash 时按 user+product 刷新最新行。
     */
    PaymentSubscriptionDomain upsertByTokenHash(PaymentSubscriptionDomain row, long actorId);
}
