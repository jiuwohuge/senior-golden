package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.mapper.PaymentTransactionMapper;
import cn.nine.pros.post.biz.model.domain.PaymentTransactionDomain;
import cn.nine.pros.post.biz.service.base.PaymentTransactionService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/**
 * 支付流水 ServiceImpl。
 */
@Slf4j
@Service
public class PaymentTransactionServiceImpl
        extends ServiceImpl<PaymentTransactionMapper, PaymentTransactionDomain>
        implements PaymentTransactionService {

    @Override
    public PaymentTransactionDomain saveTx(PaymentTransactionDomain row, long actorId) {
        if (row == null) {
            return null;
        }
        if (row.getOccurredAt() == null) {
            row.setOccurredAt(LocalDateTime.now());
        }
        row.initAudit(actorId);
        save(row);
        log.info("payment transaction saved, id={}, purchaseId={}, userId={}, txType={}",
                row.getId(), row.getPurchaseId(), row.getUserId(), row.getTxType());
        return row;
    }
}
