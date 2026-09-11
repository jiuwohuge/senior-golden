package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.UserEntitlementDomain;
import com.baomidou.mybatisplus.extension.service.IService;

import java.time.LocalDateTime;
import java.util.List;

public interface UserEntitlementService extends IService<UserEntitlementDomain> {

    List<UserEntitlementDomain> listActiveForUser(Long userId);

    boolean hasEntitlement(Long userId, Long productId);

    boolean hasEntitlementByCode(Long userId, String productCode);

    UserEntitlementDomain grant(Long userId, Long productId, String source, Long actorId);

    /**
     * 按权益码授予/刷新用户权益（订阅同步用）。
     */
    UserEntitlementDomain grantEntitlement(
            long userId,
            String entitlementCode,
            Long productId,
            Long purchaseId,
            Long subscriptionId,
            String source,
            LocalDateTime effectiveAt,
            LocalDateTime expiresAt,
            long actorId);

    /**
     * 按权益码撤销用户权益。
     */
    void revokeEntitlementByCode(long userId, String entitlementCode, long actorId);

    /**
     * 查找用户指定权益码下仍有效的行（status=active 且未过期）。
     */
    UserEntitlementDomain findActiveByUserAndCode(long userId, String entitlementCode);
}

