package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.VipSubscriptionMapper;
import cn.nine.pros.post.biz.model.domain.VipSubscriptionDomain;
import cn.nine.pros.post.biz.model.mapstruct.VipSubscriptionMapstruct;
import cn.nine.pros.post.biz.service.base.VipSubscriptionService;
import cn.nine.pros.post.client.model.db.VipSubscriptionDTO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;

/**
 * VIP订阅记录表 ServiceImpl
 *
 * @author Administrator
 */
@Slf4j
@Service
public class VipSubscriptionServiceImpl extends ServiceImpl<VipSubscriptionMapper, VipSubscriptionDomain>
        implements VipSubscriptionService {

    private static final int STATUS_ACTIVE = 1;
    private static final int STATUS_EXPIRED = 2;

    @Autowired
    private VipSubscriptionMapstruct vipSubscriptionMapstruct;

    @Override
    public void upsert(VipSubscriptionDTO vipSubscriptionDTO) {
        Long id = vipSubscriptionDTO.getId();
        if (id == null) {
            VipSubscriptionDomain domain = vipSubscriptionMapstruct.toDomain(vipSubscriptionDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        VipSubscriptionDomain domain = vipSubscriptionMapstruct.toDomain(vipSubscriptionDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public VipSubscriptionDTO findById(Long id) {
        return vipSubscriptionMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Long> ids) {
        VipSubscriptionDomain vipSubscriptionDomain = new VipSubscriptionDomain();
        vipSubscriptionDomain.setDelFlag(true);
        vipSubscriptionDomain.setUpdatedAt(LocalDateTime.now());
        update(vipSubscriptionDomain, new LambdaQueryWrapper<VipSubscriptionDomain>()
                .in(VipSubscriptionDomain::getId, ids));
    }

    @Override
    public long countActive() {
        return count(new LambdaQueryWrapper<VipSubscriptionDomain>()
                .eq(VipSubscriptionDomain::isDelFlag, false));
    }

    @Override
    public VipSubscriptionDomain findLatestForUser(long userId) {
        return getOne(new LambdaQueryWrapper<VipSubscriptionDomain>()
                .eq(VipSubscriptionDomain::getUserId, userId)
                .eq(VipSubscriptionDomain::isDelFlag, false)
                .orderByDesc(VipSubscriptionDomain::getUpdatedAt)
                .orderByDesc(VipSubscriptionDomain::getEndAt)
                .last("LIMIT 1"));
    }

    @Override
    public VipSubscriptionDomain findLatestActiveForUser(long userId) {
        LocalDateTime now = LocalDateTime.now();
        return getOne(new LambdaQueryWrapper<VipSubscriptionDomain>()
                .eq(VipSubscriptionDomain::getUserId, userId)
                .eq(VipSubscriptionDomain::isDelFlag, false)
                .eq(VipSubscriptionDomain::getStatus, STATUS_ACTIVE)
                .gt(VipSubscriptionDomain::getEndAt, now)
                .orderByDesc(VipSubscriptionDomain::getEndAt)
                .orderByDesc(VipSubscriptionDomain::getUpdatedAt)
                .last("LIMIT 1"));
    }

    @Override
    public VipSubscriptionDomain findByPurchaseToken(String purchaseToken) {
        if (!StringUtils.hasText(purchaseToken)) {
            return null;
        }
        return getOne(new LambdaQueryWrapper<VipSubscriptionDomain>()
                .eq(VipSubscriptionDomain::getPurchaseToken, purchaseToken.trim())
                .eq(VipSubscriptionDomain::isDelFlag, false)
                .last("LIMIT 1"));
    }

    @Override
    public VipSubscriptionDomain upsertSubscription(
            long userId,
            String productId,
            String purchaseToken,
            String orderId,
            String packageName,
            boolean isTrial,
            String source,
            LocalDateTime startAt,
            LocalDateTime endAt,
            int status,
            LocalDateTime acknowledgedAt,
            long actorId) {
        VipSubscriptionDomain existing = null;
        if (StringUtils.hasText(purchaseToken)) {
            existing = findByPurchaseToken(purchaseToken);
        } else {
            // 无 token（test_override / admin）：刷新用户最新一行
            existing = findLatestForUser(userId);
        }
        if (existing == null) {
            VipSubscriptionDomain created = new VipSubscriptionDomain();
            fillSubscriptionFields(created, userId, productId, purchaseToken, orderId, packageName,
                    isTrial, source, startAt, endAt, status, acknowledgedAt);
            created.setPlanId(productId);
            created.initAudit(actorId);
            save(created);
            log.info("vip subscription created, userId={}, productId={}, source={}, status={}, endAt={}",
                    userId, productId, source, status, endAt);
            return created;
        }
        fillSubscriptionFields(existing, userId, productId, purchaseToken, orderId, packageName,
                isTrial, source, startAt, endAt, status, acknowledgedAt);
        existing.setPlanId(productId);
        existing.updateAudit(actorId);
        updateById(existing);
        log.info("vip subscription updated, id={}, userId={}, productId={}, source={}, status={}, endAt={}",
                existing.getId(), userId, productId, source, status, endAt);
        return existing;
    }

    @Override
    public int expirePastDue(LocalDateTime now) {
        LocalDateTime cutoff = now != null ? now : LocalDateTime.now();
        boolean ok = update(new LambdaUpdateWrapper<VipSubscriptionDomain>()
                .eq(VipSubscriptionDomain::isDelFlag, false)
                .eq(VipSubscriptionDomain::getStatus, STATUS_ACTIVE)
                .le(VipSubscriptionDomain::getEndAt, cutoff)
                .set(VipSubscriptionDomain::getStatus, STATUS_EXPIRED)
                .set(VipSubscriptionDomain::getUpdatedAt, LocalDateTime.now()));
        return ok ? 1 : 0;
    }

    @Override
    public void markExpired(long subscriptionId, long actorId) {
        LocalDateTime now = LocalDateTime.now();
        update(new LambdaUpdateWrapper<VipSubscriptionDomain>()
                .eq(VipSubscriptionDomain::getId, subscriptionId)
                .eq(VipSubscriptionDomain::isDelFlag, false)
                .set(VipSubscriptionDomain::getStatus, STATUS_EXPIRED)
                .set(VipSubscriptionDomain::getEndAt, now.minusMinutes(1))
                .set(VipSubscriptionDomain::getUpdatedAt, now)
                .set(VipSubscriptionDomain::getUpdatedBy, actorId));
    }

    @Override
    public void expireActiveForUser(long userId, long actorId) {
        LocalDateTime now = LocalDateTime.now();
        update(new LambdaUpdateWrapper<VipSubscriptionDomain>()
                .eq(VipSubscriptionDomain::getUserId, userId)
                .eq(VipSubscriptionDomain::isDelFlag, false)
                .eq(VipSubscriptionDomain::getStatus, STATUS_ACTIVE)
                .set(VipSubscriptionDomain::getStatus, STATUS_EXPIRED)
                .set(VipSubscriptionDomain::getEndAt, now.minusMinutes(1))
                .set(VipSubscriptionDomain::getUpdatedAt, now)
                .set(VipSubscriptionDomain::getUpdatedBy, actorId));
        log.info("vip subscription expired for user, userId={}", userId);
    }

    @Override
    public void softDeleteAllForUser(long userId, long actorId) {
        LocalDateTime now = LocalDateTime.now();
        update(new LambdaUpdateWrapper<VipSubscriptionDomain>()
                .eq(VipSubscriptionDomain::getUserId, userId)
                .eq(VipSubscriptionDomain::isDelFlag, false)
                .set(VipSubscriptionDomain::isDelFlag, true)
                .set(VipSubscriptionDomain::getUpdatedAt, now)
                .set(VipSubscriptionDomain::getUpdatedBy, actorId));
        log.info("vip subscriptions soft-deleted for user, userId={}", userId);
    }

    private static void fillSubscriptionFields(
            VipSubscriptionDomain row,
            long userId,
            String productId,
            String purchaseToken,
            String orderId,
            String packageName,
            boolean isTrial,
            String source,
            LocalDateTime startAt,
            LocalDateTime endAt,
            int status,
            LocalDateTime acknowledgedAt) {
        row.setUserId(userId);
        row.setProductId(productId);
        if (StringUtils.hasText(purchaseToken)) {
            row.setPurchaseToken(purchaseToken.trim());
        }
        row.setOrderId(orderId);
        row.setPackageName(packageName);
        row.setIsTrial(isTrial);
        row.setSource(source);
        row.setStartAt(startAt);
        row.setEndAt(endAt);
        row.setStatus(status);
        row.setAcknowledgedAt(acknowledgedAt);
    }
}
