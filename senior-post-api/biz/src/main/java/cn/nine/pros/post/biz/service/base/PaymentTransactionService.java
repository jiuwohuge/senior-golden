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
}
