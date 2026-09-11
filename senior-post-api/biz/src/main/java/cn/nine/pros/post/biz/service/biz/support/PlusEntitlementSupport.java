package cn.nine.pros.post.biz.service.biz.support;

import cn.nine.pros.post.biz.config.PlusBillingProperties;
import cn.nine.pros.post.biz.model.domain.VipSubscriptionDomain;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.biz.service.base.VipSubscriptionService;
import cn.nine.pros.post.client.model.db.UserDTO;
import lombok.Builder;
import lombok.RequiredArgsConstructor;
import lombok.Value;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;

/**
 * Plus 权益解析：App 侧 AI 高配额 / 在途撤回改信必须以本解析为准，勿单独依赖 bu_user.is_vip。
 * <p>
 * 回退：无 play/test_override 行时，若管理端 vip-debug 将 {@code is_vip=true} 且
 * {@code vip_expire_at} 为空或未过期，则视为 entitled（source=admin）。
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class PlusEntitlementSupport {

    public static final String STATE_NONE = "none";
    public static final String STATE_TRIAL = "trial";
    public static final String STATE_ACTIVE = "active";
    public static final String STATE_EXPIRED = "expired";

    public static final String PRODUCT_MONTHLY = "plus_monthly";
    public static final String PRODUCT_YEARLY = "plus_yearly";

    public static final String SOURCE_PLAY = "play";
    public static final String SOURCE_MOCK = "mock";
    public static final String SOURCE_TEST = "test_override";
    public static final String SOURCE_ADMIN = "admin";
    public static final String SOURCE_UNKNOWN = "unknown";

    private static final int STATUS_ACTIVE = 1;
    private static final int STATUS_EXPIRED = 2;

    private final VipSubscriptionService vipSubscriptionService;
    private final UserService userService;
    private final PlusBillingProperties plusBillingProperties;

    /**
     * 解析用户当前 Plus 状态与是否 entitled。
     */
    public Snapshot resolve(long userId) {
        LocalDateTime now = LocalDateTime.now();
        VipSubscriptionDomain sub = vipSubscriptionService.findLatestForUser(userId);
        if (sub == null) {
            return resolveAdminFallback(userId, now);
        }
        LocalDateTime endAt = toLocalDateTime(sub.getEndAt());
        int status = toInt(sub.getStatus(), STATUS_ACTIVE);
        boolean pastDue = endAt != null && !endAt.isAfter(now);
        // 到期：纠正本行 status、同步 bu_user.is_vip，不锁写信主路径
        if (pastDue) {
            return expireSnapshot(userId, sub, endAt, status);
        }
        if (status != STATUS_ACTIVE) {
            return Snapshot.builder()
                    .state(STATE_EXPIRED)
                    .productId(sub.getProductId())
                    .expiryAt(endAt)
                    .isTrial(Boolean.TRUE.equals(sub.getIsTrial()))
                    .source(normalizeSource(sub.getSource()))
                    .entitled(false)
                    .build();
        }
        boolean trial = Boolean.TRUE.equals(sub.getIsTrial());
        String state = trial ? STATE_TRIAL : STATE_ACTIVE;
        return Snapshot.builder()
                .state(state)
                .productId(sub.getProductId())
                .expiryAt(endAt)
                .isTrial(trial)
                .source(normalizeSource(sub.getSource()))
                .entitled(true)
                .build();
    }

    public int recallWindowMinutes() {
        return Math.max(1, plusBillingProperties.getInTransitRecallWindowMinutes());
    }

    public int aiQuotaLimit(boolean entitled) {
        if (entitled) {
            return Math.max(0, plusBillingProperties.getAiSubscriberWeeklyQuota());
        }
        return Math.max(0, plusBillingProperties.getAiFreeWeeklyQuota());
    }

    public static boolean isPlusProduct(String productId) {
        if (!StringUtils.hasText(productId)) {
            return false;
        }
        String p = productId.trim();
        return PRODUCT_MONTHLY.equals(p) || PRODUCT_YEARLY.equals(p);
    }

    private Snapshot expireSnapshot(long userId, VipSubscriptionDomain sub, LocalDateTime endAt, int status) {
        if (status == STATUS_ACTIVE && sub.getId() != null) {
            vipSubscriptionService.markExpired(sub.getId(), userId);
            userService.syncVipEntitlement(userId, false, endAt, userId);
            log.info("plus entitlement marked expired, userId={}, subscriptionId={}, endAt={}",
                    userId, sub.getId(), endAt);
        }
        return Snapshot.builder()
                .state(STATE_EXPIRED)
                .productId(sub.getProductId())
                .expiryAt(endAt)
                .isTrial(Boolean.TRUE.equals(sub.getIsTrial()))
                .source(normalizeSource(sub.getSource()))
                .entitled(false)
                .build();
    }

    private Snapshot resolveAdminFallback(long userId, LocalDateTime now) {
        UserDTO user = userService.findById(userId);
        if (user == null || !Boolean.TRUE.equals(user.getIsVip())) {
            return Snapshot.builder()
                    .state(STATE_NONE)
                    .entitled(false)
                    .source(SOURCE_UNKNOWN)
                    .isTrial(false)
                    .build();
        }
        LocalDateTime vipExpire = toLocalDateTime(user.getVipExpireAt());
        // vip_expire_at 为空视为长期有效（管理端调试常见）
        boolean stillValid = vipExpire == null || vipExpire.isAfter(now);
        if (!stillValid) {
            return Snapshot.builder()
                    .state(STATE_EXPIRED)
                    .expiryAt(vipExpire)
                    .entitled(false)
                    .source(SOURCE_ADMIN)
                    .isTrial(false)
                    .build();
        }
        log.debug("plus entitlement from admin vip fallback, userId={}, vipExpireAt={}", userId, vipExpire);
        return Snapshot.builder()
                .state(STATE_ACTIVE)
                .expiryAt(vipExpire)
                .entitled(true)
                .source(SOURCE_ADMIN)
                .isTrial(false)
                .build();
    }

    private static String normalizeSource(String source) {
        if (!StringUtils.hasText(source)) {
            return SOURCE_UNKNOWN;
        }
        return source.trim();
    }

    public static LocalDateTime toLocalDateTime(Object raw) {
        if (raw == null) {
            return null;
        }
        if (raw instanceof LocalDateTime ldt) {
            return ldt;
        }
        if (raw instanceof java.sql.Timestamp ts) {
            return ts.toLocalDateTime();
        }
        if (raw instanceof java.util.Date d) {
            return LocalDateTime.ofInstant(d.toInstant(), java.time.ZoneId.systemDefault());
        }
        if (raw instanceof String s && StringUtils.hasText(s)) {
            return LocalDateTime.parse(s.replace(' ', 'T'));
        }
        return null;
    }

    private static int toInt(Object raw, int defaultVal) {
        if (raw instanceof Number n) {
            return n.intValue();
        }
        if (raw instanceof String s && StringUtils.hasText(s)) {
            return Integer.parseInt(s.trim());
        }
        return defaultVal;
    }

    @Value
    @Builder
    public static class Snapshot {
        String state;
        String productId;
        LocalDateTime expiryAt;
        boolean isTrial;
        String source;
        boolean entitled;
    }
}
