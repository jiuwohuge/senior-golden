package cn.nine.pros.post.biz.billing;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.pros.post.biz.billing.model.ParsedNotification;
import cn.nine.pros.post.biz.billing.model.RestoreCommand;
import cn.nine.pros.post.biz.billing.model.SubscriptionSnapshot;
import cn.nine.pros.post.biz.billing.model.VerifiedPurchase;
import cn.nine.pros.post.biz.billing.model.VerifyPurchaseCommand;
import cn.nine.pros.post.biz.config.BillingProperties;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.biz.support.PlusEntitlementSupport;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

/**
 * Mock 支付渠道：token 格式 {@code mock:{productCode}:{SCENARIO}:{uuid}}。
 * <p>仅在 {@link BillingProperties#isMockAllowed} 为 true 时由调用方启用；本类仍做二次守卫。
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class MockBillingProvider implements BillingProvider {

    public static final String TOKEN_PREFIX = "mock:";

    public static final String SCENARIO_PURCHASED = "PURCHASED";
    public static final String SCENARIO_PENDING = "PENDING";
    public static final String SCENARIO_RENEW = "RENEW";
    public static final String SCENARIO_CANCEL = "CANCEL";
    public static final String SCENARIO_EXPIRE = "EXPIRE";
    public static final String SCENARIO_REFUND = "REFUND";
    public static final String SCENARIO_REVOKE = "REVOKE";

    private final BillingProperties billingProperties;
    private final Environment environment;
    private final AppMessages appMessages;

    @Override
    public String providerName() {
        return BillingProviders.MOCK;
    }

    /**
     * 解析并模拟购买结果；拒绝未开启 mock 的环境。
     */
    @Override
    public VerifiedPurchase verifyPurchase(VerifyPurchaseCommand cmd) {
        requireMockAllowed();
        if (cmd == null || !StringUtils.hasText(cmd.purchaseToken())) {
            throw new BusinessException(appMessages.get("app.error.billing.invalidToken"));
        }
        String token = cmd.purchaseToken().trim();
        ParsedMockToken parsed = parseToken(token, cmd.productId(), cmd.scenario());
        LocalDateTime now = LocalDateTime.now();
        ScenarioResult result = applyScenario(parsed.scenario(), parsed.productCode(), now, cmd.isTrial());
        String orderId = StringUtils.hasText(cmd.orderId()) ? cmd.orderId().trim() : "mock-order-" + parsed.uuidPart();
        log.info("mock verifyPurchase, scenario={}, productId={}, purchaseStatus={}, subStatus={}, token={}",
                parsed.scenario(), parsed.productCode(), result.purchaseStatus(), result.subscriptionStatus(),
                PurchaseTokenPreview.truncate(token));
        return new VerifiedPurchase(
                BillingProviders.MOCK,
                token,
                parsed.productCode(),
                result.purchaseStatus(),
                result.subscriptionStatus(),
                result.periodStart(),
                result.periodEnd(),
                result.autoRenew(),
                result.isTrial(),
                orderId,
                "sandbox",
                null,
                parsed.scenario());
    }

    @Override
    public SubscriptionSnapshot getSubscription(String purchaseToken) {
        requireMockAllowed();
        VerifiedPurchase verified = verifyPurchase(new VerifyPurchaseCommand(
                0L, purchaseToken, null, null, null, null, null, null));
        return new SubscriptionSnapshot(
                verified.provider(),
                verified.purchaseToken(),
                verified.storeProductId(),
                verified.subscriptionStatus(),
                verified.periodStart(),
                verified.periodEnd(),
                verified.autoRenew(),
                verified.isTrial());
    }

    @Override
    public void acknowledgePurchase(String purchaseToken, String productId) {
        requireMockAllowed();
        log.info("mock acknowledgePurchase no-op, productId={}, token={}",
                productId, PurchaseTokenPreview.truncate(purchaseToken));
    }

    @Override
    public ParsedNotification parseNotification(String rawPayload) {
        throw new UnsupportedOperationException("mock parseNotification not implemented");
    }

    @Override
    public List<VerifiedPurchase> restorePurchases(RestoreCommand cmd) {
        requireMockAllowed();
        return List.of();
    }

    /**
     * 生成 mock token：{@code mock:{productId}:{scenario}:{uuid}}。
     */
    public static String generateToken(String productId, String scenario) {
        String product = StringUtils.hasText(productId) ? productId.trim() : PlusEntitlementSupport.PRODUCT_YEARLY;
        String sc = StringUtils.hasText(scenario) ? scenario.trim().toUpperCase(Locale.ROOT) : SCENARIO_PURCHASED;
        return TOKEN_PREFIX + product + ":" + sc + ":" + UUID.randomUUID().toString().replace("-", "");
    }

    private void requireMockAllowed() {
        if (billingProperties.isMockAllowed(environment)) {
            return;
        }
        throw new BusinessException(appMessages.get("app.error.billing.mockDisabled"));
    }

    /**
     * 解析 mock token。API 传入的 {@code fallbackScenario}（如 mock-sync body）优先于 token 内嵌场景，
     * 以便同一 purchaseToken 上模拟 RENEW/CANCEL/REFUND 等生命周期（token hash 保持不变）。
     */
    private ParsedMockToken parseToken(String token, String fallbackProductId, String fallbackScenario) {
        if (!token.startsWith(TOKEN_PREFIX)) {
            throw new BusinessException(appMessages.get("app.error.billing.invalidToken"));
        }
        String remainder = token.substring(TOKEN_PREFIX.length());
        String[] parts = remainder.split(":", 3);
        if (parts.length < 3) {
            throw new BusinessException(appMessages.get("app.error.billing.invalidToken"));
        }
        String productCode = StringUtils.hasText(parts[0]) ? parts[0].trim() : fallbackProductId;
        if (!PlusEntitlementSupport.isPlusProduct(productCode)) {
            throw new BusinessException(appMessages.get("app.error.billing.invalidProduct"));
        }
        // mock-sync 等显式 scenario 覆盖 token 内嵌值，保证同 token 可推进状态机
        String scenario = StringUtils.hasText(fallbackScenario)
                ? normalizeScenario(fallbackScenario)
                : (StringUtils.hasText(parts[1])
                        ? parts[1].trim().toUpperCase(Locale.ROOT)
                        : SCENARIO_PURCHASED);
        if (!isKnownScenario(scenario)) {
            throw new BusinessException(appMessages.get("app.error.billing.invalidState"));
        }
        String uuidPart = parts[2] == null ? "" : parts[2].trim();
        if (!StringUtils.hasText(uuidPart)) {
            throw new BusinessException(appMessages.get("app.error.billing.invalidToken"));
        }
        return new ParsedMockToken(productCode, scenario, uuidPart);
    }

    private static String normalizeScenario(String raw) {
        if (!StringUtils.hasText(raw)) {
            return SCENARIO_PURCHASED;
        }
        return raw.trim().toUpperCase(Locale.ROOT);
    }

    private static boolean isKnownScenario(String scenario) {
        return SCENARIO_PURCHASED.equals(scenario)
                || SCENARIO_PENDING.equals(scenario)
                || SCENARIO_RENEW.equals(scenario)
                || SCENARIO_CANCEL.equals(scenario)
                || SCENARIO_EXPIRE.equals(scenario)
                || SCENARIO_REFUND.equals(scenario)
                || SCENARIO_REVOKE.equals(scenario);
    }

    private ScenarioResult applyScenario(String scenario, String productCode, LocalDateTime now, Boolean isTrialFlag) {
        boolean trial = resolveTrial(productCode, isTrialFlag);
        LocalDateTime start = now;
        return switch (scenario) {
            case SCENARIO_PENDING -> new ScenarioResult(
                    "pending", "pending", start, null, true, false);
            case SCENARIO_PURCHASED -> new ScenarioResult(
                    "purchased", "active", start, computeEndAt(now, productCode, trial), true, trial);
            case SCENARIO_RENEW -> new ScenarioResult(
                    "purchased", "active", start, computeEndAt(now, productCode, false), true, false);
            case SCENARIO_CANCEL -> new ScenarioResult(
                    "purchased", "canceled", start, computeEndAt(now, productCode, trial), false, trial);
            case SCENARIO_EXPIRE -> new ScenarioResult(
                    "purchased", "expired", start.minusDays(periodDays(productCode, false)),
                    now.minusMinutes(1), false, false);
            case SCENARIO_REFUND -> new ScenarioResult(
                    "refunded", "revoked", start, now, false, false);
            case SCENARIO_REVOKE -> new ScenarioResult(
                    "revoked", "revoked", start, now, false, false);
            default -> throw new BusinessException(appMessages.get("app.error.billing.invalidState"));
        };
    }

    private static boolean resolveTrial(String productCode, Boolean isTrialFlag) {
        if (!PlusEntitlementSupport.PRODUCT_YEARLY.equals(productCode)) {
            return false;
        }
        return Boolean.TRUE.equals(isTrialFlag);
    }

    private static LocalDateTime computeEndAt(LocalDateTime now, String productCode, boolean trial) {
        if (trial) {
            return now.plusDays(7);
        }
        return now.plusDays(periodDays(productCode, false));
    }

    private static long periodDays(String productCode, boolean trial) {
        if (trial) {
            return 7;
        }
        if (PlusEntitlementSupport.PRODUCT_YEARLY.equals(productCode)) {
            return 365;
        }
        return 30;
    }

    private record ParsedMockToken(String productCode, String scenario, String uuidPart) {
    }

    private record ScenarioResult(
            String purchaseStatus,
            String subscriptionStatus,
            LocalDateTime periodStart,
            LocalDateTime periodEnd,
            boolean autoRenew,
            boolean isTrial
    ) {
    }
}
