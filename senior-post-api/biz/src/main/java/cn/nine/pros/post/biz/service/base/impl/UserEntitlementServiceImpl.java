package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.mapper.UserEntitlementMapper;
import cn.nine.pros.post.biz.model.domain.CommerceProductDomain;
import cn.nine.pros.post.biz.model.domain.UserEntitlementDomain;
import cn.nine.pros.post.biz.service.base.CommerceProductService;
import cn.nine.pros.post.biz.service.base.UserEntitlementService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class UserEntitlementServiceImpl extends ServiceImpl<UserEntitlementMapper, UserEntitlementDomain>
        implements UserEntitlementService {

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
                .and(w -> w.isNull(UserEntitlementDomain::getExpiresAt)
                        .or()
                        .gt(UserEntitlementDomain::getExpiresAt, now))
                .orderByDesc(UserEntitlementDomain::getUpdatedAt));
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
                .and(w -> w.isNull(UserEntitlementDomain::getExpiresAt)
                        .or()
                        .gt(UserEntitlementDomain::getExpiresAt, now))) > 0;
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
        LocalDateTime now = LocalDateTime.now();
        Long auditUserId = actorId != null ? actorId : userId;
        if (existing != null) {
            existing.setSource(StringUtils.hasText(source) ? source.trim() : existing.getSource());
            existing.setExpiresAt(null);
            existing.updateAudit(auditUserId);
            updateById(existing);
            return existing;
        }
        UserEntitlementDomain row = new UserEntitlementDomain();
        row.setUserId(userId);
        row.setProductId(productId);
        row.setSource(StringUtils.hasText(source) ? source.trim() : "admin_grant");
        row.initAudit(auditUserId);
        save(row);
        return row;
    }
}
