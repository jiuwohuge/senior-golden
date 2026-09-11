package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.mapper.UserEntitlementMapper;
import cn.nine.pros.post.biz.model.domain.CommerceProductDomain;
import cn.nine.pros.post.biz.model.domain.UserEntitlementDomain;
import cn.nine.pros.post.biz.service.base.CommerceProductService;
import cn.nine.pros.post.biz.service.base.UserEntitlementService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserEntitlementServiceImpl extends ServiceImpl<UserEntitlementMapper, UserEntitlementDomain>
        implements UserEntitlementService {

    private static final String STATUS_ACTIVE = "active";
    private static final String STATUS_REVOKED = "revoked";

    private final CommerceProductService commerceProductService;

    @Override
    public List<UserEntitlementDomain> listActiveForUser(Long userId) {
        if (userId == null) {
            return List.of();
        }
        LocalDateTime now = LocalDateTime.now();
        return list(new LambdaQueryWrapper<UserEntitlementDomain>()
                .eq(UserEntitlementDomain::getUserId, userId)
                .eq(UserEntitlementDomain::isDelFlag, false)
                .and(w -> w.isNull(UserEntitlementDomain::getStatus)
                        .or()
                        .eq(UserEntitlementDomain::getStatus, STATUS_ACTIVE))
                .and(w -> w.isNull(UserEntitlementDomain::getExpiresAt)
                        .or()
                        .gt(UserEntitlementDomain::getExpiresAt, now))
                .and(w -> w.isNull(UserEntitlementDomain::getRevokedAt))
                .orderByDesc(UserEntitlementDomain::getUpdatedAt));
    }

    @Override
    public List<UserEntitlementDomain> listByUserId(Long userId) {
        if (userId == null) {
            return List.of();
        }
        return list(new LambdaQueryWrapper<UserEntitlementDomain>()
                .eq(UserEntitlementDomain::getUserId, userId)
                .eq(UserEntitlementDomain::isDelFlag, false)
                .orderByDesc(UserEntitlementDomain::getUpdatedAt)
                .orderByDesc(UserEntitlementDomain::getId));
    }

    @Override
    public boolean hasEntitlement(Long userId, Long productId) {
        if (userId == null || productId == null) {
            return false;
        }
        LocalDateTime now = LocalDateTime.now();
        return count(new LambdaQueryWrapper<UserEntitlementDomain>()
                .eq(UserEntitlementDomain::getUserId, userId)
                .eq(UserEntitlementDomain::getProductId, productId)
                .eq(UserEntitlementDomain::isDelFlag, false)
                .and(w -> w.isNull(UserEntitlementDomain::getStatus)
                        .or()
                        .eq(UserEntitlementDomain::getStatus, STATUS_ACTIVE))
                .and(w -> w.isNull(UserEntitlementDomain::getExpiresAt)
                        .or()
                        .gt(UserEntitlementDomain::getExpiresAt, now))
                .and(w -> w.isNull(UserEntitlementDomain::getRevokedAt))) > 0;
    }

    @Override
    public boolean hasEntitlementByCode(Long userId, String productCode) {
        if (userId == null || !StringUtils.hasText(productCode)) {
            return false;
        }
        CommerceProductDomain product = commerceProductService.findByCode(productCode.trim());
        if (product == null || product.getId() == null) {
            return false;
        }
        return hasEntitlement(userId, product.getId());
    }

    @Override
    public UserEntitlementDomain grant(Long userId, Long productId, String source, Long actorId) {
        if (userId == null || productId == null) {
            return null;
        }
        UserEntitlementDomain existing = getOne(new LambdaQueryWrapper<UserEntitlementDomain>()
                .eq(UserEntitlementDomain::getUserId, userId)
                .eq(UserEntitlementDomain::getProductId, productId)
                .eq(UserEntitlementDomain::isDelFlag, false)
                .last("LIMIT 1"));
        Long auditUserId = actorId != null ? actorId : userId;
        if (existing != null) {
            existing.setSource(StringUtils.hasText(source) ? source.trim() : existing.getSource());
            existing.setExpiresAt(null);
            existing.setStatus(STATUS_ACTIVE);
            existing.setRevokedAt(null);
            existing.setEffectiveAt(LocalDateTime.now());
            existing.updateAudit(auditUserId);
            updateById(existing);
            return existing;
        }
        UserEntitlementDomain row = new UserEntitlementDomain();
        row.setUserId(userId);
        row.setProductId(productId);
        row.setSource(StringUtils.hasText(source) ? source.trim() : "admin_grant");
        row.setStatus(STATUS_ACTIVE);
        row.setEffectiveAt(LocalDateTime.now());
        row.initAudit(auditUserId);
        save(row);
        return row;
    }

    @Override
    public UserEntitlementDomain grantEntitlement(
            long userId,
            String entitlementCode,
            Long productId,
            Long purchaseId,
            Long subscriptionId,
            String source,
            LocalDateTime effectiveAt,
            LocalDateTime expiresAt,
            long actorId) {
        if (!StringUtils.hasText(entitlementCode)) {
            return null;
        }
        String code = entitlementCode.trim();
        UserEntitlementDomain existing = findActiveByUserAndCode(userId, code);
        if (existing == null) {
            existing = getOne(new LambdaQueryWrapper<UserEntitlementDomain>()
                    .eq(UserEntitlementDomain::getUserId, userId)
                    .eq(UserEntitlementDomain::getEntitlementCode, code)
                    .eq(UserEntitlementDomain::isDelFlag, false)
                    .orderByDesc(UserEntitlementDomain::getUpdatedAt)
                    .last("LIMIT 1"));
        }
        LocalDateTime now = LocalDateTime.now();
        if (existing == null) {
            UserEntitlementDomain row = new UserEntitlementDomain();
            row.setUserId(userId);
            row.setProductId(productId);
            row.setEntitlementCode(code);
            row.setPurchaseId(purchaseId);
            row.setSubscriptionId(subscriptionId);
            row.setSource(StringUtils.hasText(source) ? source.trim() : "play");
            row.setEffectiveAt(effectiveAt != null ? effectiveAt : now);
            row.setExpiresAt(expiresAt);
            row.setRevokedAt(null);
            row.setStatus(STATUS_ACTIVE);
            row.initAudit(actorId);
            save(row);
            log.info("entitlement granted, userId={}, code={}, productId={}, expiresAt={}",
                    userId, code, productId, expiresAt);
            return row;
        }
        existing.setProductId(productId != null ? productId : existing.getProductId());
        existing.setPurchaseId(purchaseId);
        existing.setSubscriptionId(subscriptionId);
        if (StringUtils.hasText(source)) {
            existing.setSource(source.trim());
        }
        existing.setEffectiveAt(effectiveAt != null ? effectiveAt : now);
        existing.setExpiresAt(expiresAt);
        existing.setRevokedAt(null);
        existing.setStatus(STATUS_ACTIVE);
        existing.updateAudit(actorId);
        updateById(existing);
        log.info("entitlement refreshed, id={}, userId={}, code={}, expiresAt={}",
                existing.getId(), userId, code, expiresAt);
        return existing;
    }

    @Override
    public void revokeEntitlementByCode(long userId, String entitlementCode, long actorId) {
        if (!StringUtils.hasText(entitlementCode)) {
            return;
        }
        LocalDateTime now = LocalDateTime.now();
        boolean ok = update(new LambdaUpdateWrapper<UserEntitlementDomain>()
                .eq(UserEntitlementDomain::getUserId, userId)
                .eq(UserEntitlementDomain::getEntitlementCode, entitlementCode.trim())
                .eq(UserEntitlementDomain::isDelFlag, false)
                .and(w -> w.isNull(UserEntitlementDomain::getStatus)
                        .or()
                        .eq(UserEntitlementDomain::getStatus, STATUS_ACTIVE))
                .set(UserEntitlementDomain::getStatus, STATUS_REVOKED)
                .set(UserEntitlementDomain::getRevokedAt, now)
                .set(UserEntitlementDomain::getUpdatedAt, now)
                .set(UserEntitlementDomain::getUpdatedBy, actorId));
        log.info("entitlement revoke by code, userId={}, code={}, updated={}", userId, entitlementCode, ok);
    }

    @Override
    public UserEntitlementDomain findActiveByUserAndCode(long userId, String entitlementCode) {
        if (!StringUtils.hasText(entitlementCode)) {
            return null;
        }
        LocalDateTime now = LocalDateTime.now();
        return getOne(new LambdaQueryWrapper<UserEntitlementDomain>()
                .eq(UserEntitlementDomain::getUserId, userId)
                .eq(UserEntitlementDomain::getEntitlementCode, entitlementCode.trim())
                .eq(UserEntitlementDomain::isDelFlag, false)
                .and(w -> w.isNull(UserEntitlementDomain::getStatus)
                        .or()
                        .eq(UserEntitlementDomain::getStatus, STATUS_ACTIVE))
                .and(w -> w.isNull(UserEntitlementDomain::getExpiresAt)
                        .or()
                        .gt(UserEntitlementDomain::getExpiresAt, now))
                .and(w -> w.isNull(UserEntitlementDomain::getRevokedAt))
                .orderByDesc(UserEntitlementDomain::getUpdatedAt)
                .last("LIMIT 1"));
    }
}
