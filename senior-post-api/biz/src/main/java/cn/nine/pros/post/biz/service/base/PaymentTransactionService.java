package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.PaymentTransactionDomain;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 * 支付流水 Base Service。
 */
public interface PaymentTransactionService extends IService<PaymentTransactionDomain> {

    /**
     * 写入一条支付流水。
     *
     * @return 持久化后的行
     */
    PaymentTransactionDomain saveTx(PaymentTransactionDomain row, long actorId);

    /** 某购买主单下未删除流水（按发生时间升序）。 */
    java.util.List<PaymentTransactionDomain> listByPurchaseId(Long purchaseId);
}
