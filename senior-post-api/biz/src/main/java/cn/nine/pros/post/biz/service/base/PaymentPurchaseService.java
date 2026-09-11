package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.PaymentPurchaseDomain;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 * 支付购买主单 Base Service。
 */
public interface PaymentPurchaseService extends IService<PaymentPurchaseDomain> {

    PaymentPurchaseDomain findByTokenHash(String purchaseTokenHash);

    PaymentPurchaseDomain findByPurchaseNo(String purchaseNo);

    /**
     * 按 token hash 幂等写入/刷新购买行。
     *
     * @return 持久化后的行
     */
    PaymentPurchaseDomain upsertByTokenHash(PaymentPurchaseDomain row, long actorId);
}
