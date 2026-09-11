package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.mapper.PaymentPurchaseMapper;
import cn.nine.pros.post.biz.model.domain.PaymentPurchaseDomain;
import cn.nine.pros.post.biz.service.base.PaymentPurchaseService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

/**
 * 支付购买主单 ServiceImpl。
 */
@Slf4j
@Service
public class PaymentPurchaseServiceImpl extends ServiceImpl<PaymentPurchaseMapper, PaymentPurchaseDomain>
        implements PaymentPurchaseService {

    @Override
    public PaymentPurchaseDomain findByTokenHash(String purchaseTokenHash) {
        if (!StringUtils.hasText(purchaseTokenHash)) {
            return null;
        }
        return getOne(new LambdaQueryWrapper<PaymentPurchaseDomain>()
                .eq(PaymentPurchaseDomain::getPurchaseTokenHash, purchaseTokenHash.trim())
                .eq(PaymentPurchaseDomain::isDelFlag, false)
                .last("LIMIT 1"));
    }

    @Override
    public PaymentPurchaseDomain findByPurchaseNo(String purchaseNo) {
        if (!StringUtils.hasText(purchaseNo)) {
            return null;
        }
        return getOne(new LambdaQueryWrapper<PaymentPurchaseDomain>()
                .eq(PaymentPurchaseDomain::getPurchaseNo, purchaseNo.trim())
                .eq(PaymentPurchaseDomain::isDelFlag, false)
                .last("LIMIT 1"));
    }

    @Override
    public PaymentPurchaseDomain upsertByTokenHash(PaymentPurchaseDomain row, long actorId) {
        if (row == null || !StringUtils.hasText(row.getPurchaseTokenHash())) {
            return null;
        }
        PaymentPurchaseDomain existing = findByTokenHash(row.getPurchaseTokenHash());
        if (existing == null) {
            row.initAudit(actorId);
            save(row);
            log.info("payment purchase created, id={}, userId={}, productId={}, status={}, tokenPreview={}",
                    row.getId(), row.getUserId(), row.getProductId(), row.getStatus(), row.getPurchaseTokenPreview());
            return row;
        }
        existing.setUserId(row.getUserId());
        existing.setProductId(row.getProductId());
        existing.setProvider(row.getProvider());
        existing.setStoreProductId(row.getStoreProductId());
        if (StringUtils.hasText(row.getPurchaseTokenCipher())) {
            existing.setPurchaseTokenCipher(row.getPurchaseTokenCipher());
        }
        if (StringUtils.hasText(row.getPurchaseTokenPreview())) {
            existing.setPurchaseTokenPreview(row.getPurchaseTokenPreview());
        }
        if (StringUtils.hasText(row.getExternalOrderId())) {
            existing.setExternalOrderId(row.getExternalOrderId());
        }
        existing.setStatus(row.getStatus());
        if (row.getPurchasedAt() != null) {
            existing.setPurchasedAt(row.getPurchasedAt());
        }
        if (row.getPaidAt() != null) {
            existing.setPaidAt(row.getPaidAt());
        }
        if (StringUtils.hasText(row.getEnvironment())) {
            existing.setEnvironment(row.getEnvironment());
        }
        if (StringUtils.hasText(row.getChannelSnapshotJson())) {
            existing.setChannelSnapshotJson(row.getChannelSnapshotJson());
        }
        existing.updateAudit(actorId);
        updateById(existing);
        log.info("payment purchase updated, id={}, userId={}, status={}, tokenPreview={}",
                existing.getId(), existing.getUserId(), existing.getStatus(), existing.getPurchaseTokenPreview());
        return existing;
    }
}
