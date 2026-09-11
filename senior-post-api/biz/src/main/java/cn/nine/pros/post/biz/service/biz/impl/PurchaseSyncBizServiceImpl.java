package cn.nine.pros.post.biz.service.biz.impl;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.pros.post.biz.billing.BillingProvider;
import cn.nine.pros.post.biz.billing.BillingProviderRegistry;
import cn.nine.pros.post.biz.billing.BillingProviders;
import cn.nine.pros.post.biz.billing.PurchaseTokenPreview;
import cn.nine.pros.post.biz.billing.model.VerifiedPurchase;
import cn.nine.pros.post.biz.billing.model.VerifyPurchaseCommand;
import cn.nine.pros.post.biz.billing.util.PurchaseTokenHasher;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.CommerceProductDomain;
import cn.nine.pros.post.biz.model.domain.PaymentPurchaseDomain;
import cn.nine.pros.post.biz.model.domain.PaymentSubscriptionDomain;
import cn.nine.pros.post.biz.model.domain.PaymentTransactionDomain;
import cn.nine.pros.post.biz.model.domain.VipSubscriptionDomain;
import cn.nine.pros.post.biz.service.base.AiAssistUsageService;
import cn.nine.pros.post.biz.service.base.CommerceProductService;
import cn.nine.pros.post.biz.service.base.PaymentPurchaseService;
import cn.nine.pros.post.biz.service.base.PaymentSubscriptionService;
import cn.nine.pros.post.biz.service.base.PaymentTransactionService;
import cn.nine.pros.post.biz.service.base.UserEntitlementService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.biz.service.base.VipSubscriptionService;
import cn.nine.pros.post.biz.service.biz.PurchaseSyncBizService;
import cn.nine.pros.post.biz.service.biz.SyncPurchaseContext;
import cn.nine.pros.post.biz.service.biz.support.PlusEntitlementSupport;
import cn.nine.pros.post.client.model.out.PlusSkuItemVO;
import cn.nine.pros.post.client.model.out.SubscriptionStatusVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.nio.charset.StandardCharsets;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.TemporalAdjusters;
import java.util.Base64;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

/**
 * 购买同步：BillingProvider 校验 → 公共表落库 → 权益与 VIP 镜像。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PurchaseSyncBizServiceImpl implements PurchaseSyncBizService {

    private static final int VIP_STATUS_ACTIVE = 1;
    private static final int VIP_STATUS_EXPIRED = 2;

    private static final String TX_INITIAL = "initial_purchase";
    private static final String TX_RENEWAL = "renewal";
    private static final String TX_REFUND = "refund";
    private static final String TX_REVOCATION = "revocation";

    private static final String ENTITLEMENT_PLUS = "plus";

    private final BillingProviderRegistry billingProviderRegistry;
    private final PaymentPurchaseService paymentPurchaseService;
    private final PaymentSubscriptionService paymentSubscriptionService;
    private final PaymentTransactionService paymentTransactionService;
    private final UserEntitlementService userEntitlementService;
    private final CommerceProductService commerceProductService;
    private final VipSubscriptionService vipSubscriptionService;
    private final UserService userService;
    private final PlusEntitlementSupport plusEntitlementSupport;
    private final AiAssistUsageService aiAssistUsageService;
    private final AppMessages appMessages;

    /**
     * 同步购买：幂等按 token hash；禁止跨用户绑定；同步 VIP 镜像供 PlusEntitlementSupport。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public SubscriptionStatusVO syncPurchase(
            String provider, String purchaseToken, long userId, SyncPurchaseContext ctx) {
        if (!StringUtils.hasText(purchaseToken)) {
            throw new BusinessException(appMessages.get("app.error.billing.invalidToken"));
        }
        String token = purchaseToken.trim();
        SyncPurchaseContext safeCtx = ctx != null ? ctx : SyncPurchaseContext.of(null, null, null, null, null);

        BillingProvider billingProvider = billingProviderRegistry.getRequired(provider);
        VerifiedPurchase verified = billingProvider.verifyPurchase(new VerifyPurchaseCommand(
                userId,
                token,
                safeCtx.productId(),
                safeCtx.packageName(),
                safeCtx.orderId(),
                safeCtx.acknowledged(),
                safeCtx.isTrial(),
                safeCtx.scenario()));

        String tokenHash = PurchaseTokenHasher.hashToken(token);
        String tokenPreview = PurchaseTokenHasher.preview(token);
        assertTokenNotBoundOtherUser(token, tokenHash, userId);

        CommerceProductDomain product = resolveProduct(verified.storeProductId());
        LocalDateTime now = LocalDateTime.now();
        boolean isFirstPurchase = paymentPurchaseService.findByTokenHash(tokenHash) == null;

        PaymentPurchaseDomain purchase = upsertPurchase(userId, product, verified, token, tokenHash, tokenPreview, now);
        insertTransactionIfNeeded(purchase, verified, userId, isFirstPurchase, now);
        PaymentSubscriptionDomain subscription = upsertSubscription(userId, product, purchase, verified, tokenHash, now);
        applyEntitlementAndVipMirror(userId, product, purchase, subscription, verified, token, now);

        if (Boolean.TRUE.equals(safeCtx.acknowledged())) {
            billingProvider.acknowledgePurchase(token, verified.storeProductId());
        }

        log.info("syncPurchase ok, provider={}, userId={}, productId={}, purchaseStatus={}, subStatus={}, token={}",
                provider, userId, verified.storeProductId(), verified.purchaseStatus(),
                verified.subscriptionStatus(), tokenPreview);
        return buildStatusVo(userId);
    }

    private void assertTokenNotBoundOtherUser(String rawToken, String tokenHash, long userId) {
        PaymentPurchaseDomain existing = paymentPurchaseService.findByTokenHash(tokenHash);
        if (existing != null && existing.getUserId() != null && !existing.getUserId().equals(userId)) {
            log.info("syncPurchase rejected: token bound other user, userId={}, ownerId={}, token={}",
                    userId, existing.getUserId(), PurchaseTokenPreview.truncate(rawToken));
            throw new BusinessException(appMessages.get("app.error.billing.tokenBoundOtherUser"));
        }
        // 过渡期：旧 VIP 表按明文 token 绑定校验
        VipSubscriptionDomain legacy = vipSubscriptionService.findByPurchaseToken(rawToken);
        if (legacy != null && legacy.getUserId() != null && !legacy.getUserId().equals(userId)) {
            log.info("syncPurchase rejected: legacy vip token bound other user, userId={}, ownerId={}, token={}",
                    userId, legacy.getUserId(), PurchaseTokenPreview.truncate(rawToken));
            throw new BusinessException(appMessages.get("app.error.billing.tokenBoundOtherUser"));
        }
    }

    private CommerceProductDomain resolveProduct(String storeProductId) {
        if (!StringUtils.hasText(storeProductId)) {
            throw new BusinessException(appMessages.get("app.error.billing.invalidProduct"));
        }
        CommerceProductDomain product = commerceProductService.findByCode(storeProductId.trim());
        if (product == null || product.getId() == null) {
            throw new BusinessException(appMessages.get("app.error.billing.invalidProduct"));
        }
        return product;
    }

    private PaymentPurchaseDomain upsertPurchase(
            long userId,
            CommerceProductDomain product,
            VerifiedPurchase verified,
            String token,
            String tokenHash,
            String tokenPreview,
            LocalDateTime now) {
        PaymentPurchaseDomain row = new PaymentPurchaseDomain();
        row.setPurchaseNo(UUID.randomUUID().toString().replace("-", ""));
        row.setUserId(userId);
        row.setProductId(product.getId());
        row.setProvider(verified.provider());
        row.setStoreProductId(verified.storeProductId());
        row.setPurchaseTokenHash(tokenHash);
        // non-prod mock：简单 base64；生产须 vault/AES（注释见 Flyway）
        if (BillingProviders.MOCK.equals(verified.provider())) {
            row.setPurchaseTokenCipher(Base64.getEncoder().encodeToString(token.getBytes(StandardCharsets.UTF_8)));
        }
        row.setPurchaseTokenPreview(tokenPreview);
        row.setExternalOrderId(verified.orderId());
        row.setStatus(verified.purchaseStatus());
        row.setPurchasedAt(verified.periodStart() != null ? verified.periodStart() : now);
        if ("purchased".equalsIgnoreCase(verified.purchaseStatus())) {
            row.setPaidAt(now);
        }
        row.setEnvironment(verified.environment());
        row.setChannelSnapshotJson(verified.rawSnapshot());
        return paymentPurchaseService.upsertByTokenHash(row, userId);
    }

    private void insertTransactionIfNeeded(
            PaymentPurchaseDomain purchase,
            VerifiedPurchase verified,
            long userId,
            boolean isFirstPurchase,
            LocalDateTime now) {
        String txType = resolveTxType(verified, isFirstPurchase);
        if (txType == null) {
            return;
        }
        PaymentTransactionDomain tx = new PaymentTransactionDomain();
        tx.setPurchaseId(purchase.getId());
        tx.setUserId(userId);
        tx.setTxType(txType);
        tx.setProviderTxId(verified.orderId());
        tx.setOccurredAt(now);
        tx.setRawSnapshotJson(verified.rawSnapshot());
        paymentTransactionService.saveTx(tx, userId);
    }

    private static String resolveTxType(VerifiedPurchase verified, boolean isFirstPurchase) {
        String scenario = verified.scenario() == null ? "" : verified.scenario().toUpperCase(Locale.ROOT);
        String purchaseStatus = verified.purchaseStatus() == null ? "" : verified.purchaseStatus().toLowerCase(Locale.ROOT);
        if ("RENEW".equals(scenario)) {
            return TX_RENEWAL;
        }
        if ("REFUND".equals(scenario) || "refunded".equals(purchaseStatus)) {
            return TX_REFUND;
        }
        if ("REVOKE".equals(scenario) || "revoked".equals(purchaseStatus)) {
            return TX_REVOCATION;
        }
        if (isFirstPurchase && ("purchased".equals(purchaseStatus) || "pending".equals(purchaseStatus))) {
            return TX_INITIAL;
        }
        if (isFirstPurchase) {
            return TX_INITIAL;
        }
        return null;
    }

    private PaymentSubscriptionDomain upsertSubscription(
            long userId,
            CommerceProductDomain product,
            PaymentPurchaseDomain purchase,
            VerifiedPurchase verified,
            String tokenHash,
            LocalDateTime now) {
        PaymentSubscriptionDomain row = new PaymentSubscriptionDomain();
        row.setUserId(userId);
        row.setProductId(product.getId());
        row.setPurchaseId(purchase.getId());
        row.setProvider(verified.provider());
        row.setStatus(verified.subscriptionStatus());
        row.setCurrentPeriodStart(verified.periodStart());
        row.setCurrentPeriodEnd(verified.periodEnd());
        row.setAutoRenew(verified.autoRenew());
        row.setPurchaseTokenHash(tokenHash);
        row.setLastSyncedAt(now);
        row.setIsTrial(verified.isTrial());
        row.setStoreProductId(verified.storeProductId());
        return paymentSubscriptionService.upsertByTokenHash(row, userId);
    }

    /**
     * 按订阅状态授予/撤销 entitlement，并写 VIP 镜像。
     */
    private void applyEntitlementAndVipMirror(
            long userId,
            CommerceProductDomain product,
            PaymentPurchaseDomain purchase,
            PaymentSubscriptionDomain subscription,
            VerifiedPurchase verified,
            String rawToken,
            LocalDateTime now) {
        String entitlementCode = StringUtils.hasText(product.getEntitlementCode())
                ? product.getEntitlementCode().trim()
                : ENTITLEMENT_PLUS;
        String subStatus = verified.subscriptionStatus() == null
                ? ""
                : verified.subscriptionStatus().toLowerCase(Locale.ROOT);
        EntitlementAction action = resolveEntitlementAction(subStatus);

        if (action == EntitlementAction.GRANT_OR_KEEP) {
            userEntitlementService.grantEntitlement(
                    userId,
                    entitlementCode,
                    product.getId(),
                    purchase.getId(),
                    subscription.getId(),
                    vipSource(verified.provider()),
                    verified.periodStart() != null ? verified.periodStart() : now,
                    verified.periodEnd(),
                    userId);
        }
        if (action == EntitlementAction.REVOKE) {
            userEntitlementService.revokeEntitlementByCode(userId, entitlementCode, userId);
        }

        mirrorVip(userId, product, verified, rawToken, action, now);
    }

    private void mirrorVip(
            long userId,
            CommerceProductDomain product,
            VerifiedPurchase verified,
            String rawToken,
            EntitlementAction action,
            LocalDateTime now) {
        String source = vipSource(verified.provider());
        String productCode = verified.storeProductId();
        LocalDateTime start = verified.periodStart() != null ? verified.periodStart() : now;
        LocalDateTime end = verified.periodEnd() != null ? verified.periodEnd() : now;
        String subStatus = verified.subscriptionStatus() == null
                ? ""
                : verified.subscriptionStatus().toLowerCase(Locale.ROOT);

        if (action == EntitlementAction.NONE) {
            // PENDING：支付表已落库，不授予权益、不写 VIP 镜像
            log.info("vip mirror skipped for pending, userId={}, productId={}", userId, productCode);
            return;
        }

        if (action == EntitlementAction.REVOKE) {
            vipSubscriptionService.upsertSubscription(
                    userId, productCode, rawToken, verified.orderId(),
                    null, verified.isTrial(), source, start, end,
                    VIP_STATUS_EXPIRED, null, userId);
            userService.syncVipEntitlement(userId, false, end, userId);
            return;
        }

        // GRANT_OR_KEEP：active / canceled（到期前仍 entitled → VIP status 保持有效）
        int vipStatus = VIP_STATUS_ACTIVE;
        if ("expired".equals(subStatus) || "revoked".equals(subStatus)) {
            vipStatus = VIP_STATUS_EXPIRED;
        }
        vipSubscriptionService.upsertSubscription(
                userId, productCode, rawToken, verified.orderId(),
                null, verified.isTrial(), source, start, end,
                vipStatus, null, userId);
        userService.syncVipEntitlement(userId, true, end, userId);
    }

    private static EntitlementAction resolveEntitlementAction(String subStatus) {
        return switch (subStatus) {
            case "pending" -> EntitlementAction.NONE;
            case "active", "canceled", "grace_period", "paused" -> EntitlementAction.GRANT_OR_KEEP;
            case "expired", "revoked", "on_hold" -> EntitlementAction.REVOKE;
            default -> EntitlementAction.REVOKE;
        };
    }

    private static String vipSource(String provider) {
        if (BillingProviders.MOCK.equals(provider)) {
            return PlusEntitlementSupport.SOURCE_MOCK;
        }
        if (BillingProviders.GOOGLE_PLAY.equals(provider)) {
            return PlusEntitlementSupport.SOURCE_PLAY;
        }
        return provider == null ? PlusEntitlementSupport.SOURCE_UNKNOWN : provider;
    }

    /**
     * 构建与 AppBilling 一致的订阅状态 VO。
     */
    public SubscriptionStatusVO buildStatusVo(long userId) {
        PlusEntitlementSupport.Snapshot snap = plusEntitlementSupport.resolve(userId);
        LocalDate weekStart = LocalDate.now().with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        int used = aiAssistUsageService.getUseCount(userId, weekStart);
        int limit = plusEntitlementSupport.aiQuotaLimit(snap.isEntitled());
        int remaining = Math.max(0, limit - used);
        return SubscriptionStatusVO.builder()
                .state(snap.getState())
                .productId(snap.getProductId())
                .expiryAt(snap.getExpiryAt())
                .isTrial(snap.isTrial())
                .source(snap.getSource())
                .entitled(snap.isEntitled())
                .aiQuotaLimit(limit)
                .aiQuotaUsed(used)
                .aiQuotaRemaining(remaining)
                .recallWindowMinutes(plusEntitlementSupport.recallWindowMinutes())
                .skus(List.of(
                        PlusSkuItemVO.builder()
                                .productId(PlusEntitlementSupport.PRODUCT_MONTHLY)
                                .preferred(false)
                                .build(),
                        PlusSkuItemVO.builder()
                                .productId(PlusEntitlementSupport.PRODUCT_YEARLY)
                                .preferred(true)
                                .build()))
                .build();
    }

    private enum EntitlementAction {
        NONE,
        GRANT_OR_KEEP,
        REVOKE
    }
}
