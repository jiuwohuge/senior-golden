package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.mapper.PaymentSubscriptionMapper;
import cn.nine.pros.post.biz.model.domain.PaymentSubscriptionDomain;
import cn.nine.pros.post.biz.service.base.PaymentSubscriptionService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

/**
 * 支付订阅 ServiceImpl（表 bu_subscription）。
 */
@Slf4j
@Service
public class PaymentSubscriptionServiceImpl
        extends ServiceImpl<PaymentSubscriptionMapper, PaymentSubscriptionDomain>
        implements PaymentSubscriptionService {

    @Override
    public PaymentSubscriptionDomain findByTokenHash(String purchaseTokenHash) {
        if (!StringUtils.hasText(purchaseTokenHash)) {
            return null;
        }
        return getOne(new LambdaQueryWrapper<PaymentSubscriptionDomain>()
                .eq(PaymentSubscriptionDomain::getPurchaseTokenHash, purchaseTokenHash.trim())
                .eq(PaymentSubscriptionDomain::isDelFlag, false)
                .last("LIMIT 1"));
    }

    @Override
    public PaymentSubscriptionDomain findByPurchaseId(Long purchaseId) {
        if (purchaseId == null) {
            return null;
        }
        return getOne(new LambdaQueryWrapper<PaymentSubscriptionDomain>()
                .eq(PaymentSubscriptionDomain::getPurchaseId, purchaseId)
                .eq(PaymentSubscriptionDomain::isDelFlag, false)
                .orderByDesc(PaymentSubscriptionDomain::getUpdatedAt)
                .last("LIMIT 1"));
    }

    @Override
    public PaymentSubscriptionDomain findLatestForUser(long userId) {
        return getOne(new LambdaQueryWrapper<PaymentSubscriptionDomain>()
                .eq(PaymentSubscriptionDomain::getUserId, userId)
                .eq(PaymentSubscriptionDomain::isDelFlag, false)
                .orderByDesc(PaymentSubscriptionDomain::getUpdatedAt)
                .orderByDesc(PaymentSubscriptionDomain::getCurrentPeriodEnd)
                .last("LIMIT 1"));
    }

    @Override
    public PaymentSubscriptionDomain upsertByTokenHash(PaymentSubscriptionDomain row, long actorId) {
        if (row == null) {
            return null;
        }
        PaymentSubscriptionDomain existing = null;
        if (StringUtils.hasText(row.getPurchaseTokenHash())) {
            existing = findByTokenHash(row.getPurchaseTokenHash());
        }
        if (existing == null && row.getUserId() != null && row.getProductId() != null) {
            existing = getOne(new LambdaQueryWrapper<PaymentSubscriptionDomain>()
                    .eq(PaymentSubscriptionDomain::getUserId, row.getUserId())
                    .eq(PaymentSubscriptionDomain::getProductId, row.getProductId())
                    .eq(PaymentSubscriptionDomain::isDelFlag, false)
                    .orderByDesc(PaymentSubscriptionDomain::getUpdatedAt)
                    .last("LIMIT 1"));
        }
        if (existing == null) {
            if (row.getAutoRenew() == null) {
                row.setAutoRenew(true);
            }
            row.initAudit(actorId);
            save(row);
            log.info("payment subscription created, id={}, userId={}, productId={}, status={}, endAt={}",
                    row.getId(), row.getUserId(), row.getProductId(), row.getStatus(), row.getCurrentPeriodEnd());
            return row;
        }
        copySubscriptionFields(existing, row);
        existing.updateAudit(actorId);
        updateById(existing);
        log.info("payment subscription updated, id={}, userId={}, status={}, endAt={}, autoRenew={}",
                existing.getId(), existing.getUserId(), existing.getStatus(),
                existing.getCurrentPeriodEnd(), existing.getAutoRenew());
        return existing;
    }

    private static void copySubscriptionFields(PaymentSubscriptionDomain target, PaymentSubscriptionDomain src) {
        target.setUserId(src.getUserId());
        target.setProductId(src.getProductId());
        target.setPurchaseId(src.getPurchaseId());
        target.setProvider(src.getProvider());
        target.setStatus(src.getStatus());
        target.setCurrentPeriodStart(src.getCurrentPeriodStart());
        target.setCurrentPeriodEnd(src.getCurrentPeriodEnd());
        if (src.getAutoRenew() != null) {
            target.setAutoRenew(src.getAutoRenew());
        }
        if (StringUtils.hasText(src.getPurchaseTokenHash())) {
            target.setPurchaseTokenHash(src.getPurchaseTokenHash());
        }
        target.setLinkedPurchaseTokenHash(src.getLinkedPurchaseTokenHash());
        target.setCancelReason(src.getCancelReason());
        target.setLastSyncedAt(src.getLastSyncedAt());
        target.setIsTrial(src.getIsTrial());
        target.setStoreProductId(src.getStoreProductId());
    }
}
