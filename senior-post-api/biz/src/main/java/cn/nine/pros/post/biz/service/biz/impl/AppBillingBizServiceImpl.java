package cn.nine.pros.post.biz.service.biz.impl;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.pros.post.biz.billing.BillingProviderRegistry;
import cn.nine.pros.post.biz.billing.BillingProviders;
import cn.nine.pros.post.biz.billing.MockBillingProvider;
import cn.nine.pros.post.biz.billing.model.ParsedNotification;
import cn.nine.pros.post.biz.billing.util.PurchaseTokenHasher;
import cn.nine.pros.post.biz.config.BillingProperties;
import cn.nine.pros.post.biz.config.PlusBillingProperties;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.PaymentPurchaseDomain;
import cn.nine.pros.post.biz.model.domain.PaymentWebhookEventDomain;
import cn.nine.pros.post.biz.model.domain.VipSubscriptionDomain;
import cn.nine.pros.post.biz.service.base.AiAssistUsageService;
import cn.nine.pros.post.biz.service.base.PaymentPurchaseService;
import cn.nine.pros.post.biz.service.base.PaymentWebhookEventService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.biz.service.base.VipSubscriptionService;
import cn.nine.pros.post.biz.service.biz.AppBillingBizService;
import cn.nine.pros.post.biz.service.biz.PurchaseSyncBizService;
import cn.nine.pros.post.biz.service.biz.SyncPurchaseContext;
import cn.nine.pros.post.biz.service.biz.support.PlusEntitlementSupport;
import cn.nine.pros.post.client.model.input.app.BillingMockRtdnInDto;
import cn.nine.pros.post.client.model.input.app.BillingMockSyncInDto;
import com.fasterxml.jackson.databind.ObjectMapper;
import cn.nine.pros.post.client.model.input.app.BillingTestOverrideInDto;
import cn.nine.pros.post.client.model.input.app.PlayPurchaseVerifyInDto;
import cn.nine.pros.post.client.model.input.app.PlayRestoreInDto;
import cn.nine.pros.post.client.model.out.PlusSkuItemVO;
import cn.nine.pros.post.client.model.out.SubscriptionStatusVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.TemporalAdjusters;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Plus / Play Billing：订阅状态、购买校验、恢复、mock-sync 与测试覆盖。
 * <p>生产必须接入 Google Play Developer API；当前 google_play 在无公钥时做结构化校验。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AppBillingBizServiceImpl implements AppBillingBizService {

    private static final int STATUS_ACTIVE = 1;
    private static final int STATUS_EXPIRED = 2;
    private static final int WEBHOOK_ERROR_MESSAGE_MAX_LEN = 500;
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    private final PlusEntitlementSupport plusEntitlementSupport;
    private final VipSubscriptionService vipSubscriptionService;
    private final AiAssistUsageService aiAssistUsageService;
    private final UserService userService;
    private final PlusBillingProperties plusBillingProperties;
    private final BillingProperties billingProperties;
    private final Environment environment;
    private final PurchaseSyncBizService purchaseSyncBizService;
    private final PaymentWebhookEventService paymentWebhookEventService;
    private final PaymentPurchaseService paymentPurchaseService;
    private final BillingProviderRegistry billingProviderRegistry;
    private final AppMessages appMessages;

    @Override
    public SubscriptionStatusVO getSubscriptionStatus(long userId) {
        return buildStatusVo(userId);
    }

    /**
     * 校验并落库购买；mock: 前缀走 mock 渠道，否则 google_play。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public SubscriptionStatusVO verifyPurchase(long userId, PlayPurchaseVerifyInDto body) {
        if (body == null) {
            throw new BusinessException(appMessages.get("app.error.billing.invalidRequest"));
        }
        String productId = normalizeProductId(body.getProductId());
        String token = body.getPurchaseToken() == null ? "" : body.getPurchaseToken().trim();
        if (!StringUtils.hasText(token)) {
            throw new BusinessException(appMessages.get("app.error.billing.invalidToken"));
        }
        String provider = resolveProvider(token);
        if (BillingProviders.MOCK.equals(provider) && !billingProperties.isMockAllowed(environment)) {
            throw new BusinessException(appMessages.get("app.error.billing.mockDisabled"));
        }
        boolean trial = resolveTrial(userId, productId, body.getIsTrial());
        SyncPurchaseContext ctx = SyncPurchaseContext.of(
                productId,
                body.getPackageName(),
                body.getOrderId(),
                body.getAcknowledged(),
                trial);
        return purchaseSyncBizService.syncPurchase(provider, token, userId, ctx);
    }

    /**
     * 恢复：逐条重验本地购买，或空列表仅重读服务端。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public SubscriptionStatusVO restore(long userId, PlayRestoreInDto body) {
        List<PlayPurchaseVerifyInDto> purchases = body == null ? null : body.getPurchases();
        if (purchases == null || purchases.isEmpty()) {
            log.info("billing restore re-read only, userId={}", userId);
            return buildStatusVo(userId);
        }
        SubscriptionStatusVO last = null;
        for (PlayPurchaseVerifyInDto purchase : purchases) {
            last = verifyPurchase(userId, purchase);
        }
        log.info("billing restore verified {} purchase(s), userId={}", purchases.size(), userId);
        return last != null ? last : buildStatusVo(userId);
    }

    /**
     * Mock 同步：生成或使用 token，走 PurchaseSync。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public SubscriptionStatusVO mockSync(long userId, BillingMockSyncInDto body) {
        if (!billingProperties.isMockAllowed(environment)) {
            throw new BusinessException(appMessages.get("app.error.billing.mockDisabled"));
        }
        if (body == null || !StringUtils.hasText(body.getScenario())) {
            throw new BusinessException(appMessages.get("app.error.billing.invalidRequest"));
        }
        String scenario = body.getScenario().trim().toUpperCase(Locale.ROOT);
        String productId = StringUtils.hasText(body.getProductId())
                ? normalizeProductId(body.getProductId())
                : PlusEntitlementSupport.PRODUCT_YEARLY;
        String token = StringUtils.hasText(body.getPurchaseToken())
                ? body.getPurchaseToken().trim()
                : MockBillingProvider.generateToken(productId, scenario);
        log.info("billing mock-sync, userId={}, scenario={}, productId={}, token={}",
                userId, scenario, productId, truncateToken(token));
        SyncPurchaseContext ctx = new SyncPurchaseContext(
                productId, plusBillingProperties.getPlayPackageName(), null, true, null, scenario);
        return purchaseSyncBizService.syncPurchase(BillingProviders.MOCK, token, userId, ctx);
    }

    /**
     * Mock RTDN 回放：解析通知、幂等写入 webhook 事件、同步购买状态。
     * <p>QA 须以 purchaseToken 绑定用户身份登录；跨用户回放会被拒绝。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public SubscriptionStatusVO mockReplayRtdn(long userId, BillingMockRtdnInDto body) {
        if (!billingProperties.isMockAllowed(environment)) {
            throw new BusinessException(appMessages.get("app.error.billing.mockDisabled"));
        }
        if (body == null || !StringUtils.hasText(body.getMessageId())
                || !StringUtils.hasText(body.getPurchaseToken())
                || !StringUtils.hasText(body.getNotificationType())) {
            throw new BusinessException(appMessages.get("app.error.billing.invalidRequest"));
        }
        String token = body.getPurchaseToken().trim();
        log.info("billing mock-rtdn entry, userId={}, messageId={}, notificationType={}, token={}",
                userId, body.getMessageId().trim(), body.getNotificationType().trim(), truncateToken(token));

        Object payload = buildMockRtdnPayload(body);
        String rawJson;
        try {
            rawJson = OBJECT_MAPPER.writeValueAsString(payload);
        } catch (Exception e) {
            throw new BusinessException(appMessages.get("app.error.billing.invalidRequest"));
        }
        ParsedNotification parsed = billingProviderRegistry.getRequired(BillingProviders.MOCK)
                .parseNotification(rawJson);

        long boundUserId = resolveBoundUserId(token);
        // QA 简化：要求当前登录用户即为 token 绑定用户，避免跨账号误操作
        if (boundUserId != userId) {
            throw new BusinessException(appMessages.get("app.error.billing.invalidRequest"));
        }

        PaymentWebhookEventDomain webhookRow = new PaymentWebhookEventDomain();
        webhookRow.setProvider(BillingProviders.MOCK);
        webhookRow.setEventIdOrMessageId(parsed.messageId());
        webhookRow.setEventType(parsed.eventType());
        webhookRow.setPayloadJson(payload);
        webhookRow.setProcessStatus("received");
        webhookRow.setReceivedAt(LocalDateTime.now());
        webhookRow = paymentWebhookEventService.insertIfAbsent(webhookRow, boundUserId);
        if (webhookRow == null) {
            throw new BusinessException(appMessages.get("app.error.billing.invalidRequest"));
        }

        if ("processed".equals(webhookRow.getProcessStatus())) {
            log.info("billing mock-rtdn idempotent hit, userId={}, messageId={}",
                    boundUserId, parsed.messageId());
            return buildStatusVo(boundUserId);
        }

        String productId = resolveProductIdForRtdn(body, parsed, token);
        SyncPurchaseContext ctx = new SyncPurchaseContext(
                productId, plusBillingProperties.getPlayPackageName(), null, true, null, parsed.scenario());
        try {
            SubscriptionStatusVO status = purchaseSyncBizService.syncPurchase(
                    BillingProviders.MOCK, token, boundUserId, ctx);
            webhookRow.setProcessStatus("processed");
            webhookRow.setProcessedAt(LocalDateTime.now());
            webhookRow.setErrorMessage(null);
            paymentWebhookEventService.updateById(webhookRow);
            log.info("billing mock-rtdn sync success, userId={}, messageId={}, scenario={}",
                    boundUserId, parsed.messageId(), parsed.scenario());
            return status;
        } catch (RuntimeException ex) {
            webhookRow.setProcessStatus("failed");
            webhookRow.setErrorMessage(truncateErrorMessage(ex.getMessage()));
            paymentWebhookEventService.updateById(webhookRow);
            log.warn("billing mock-rtdn sync failed, userId={}, messageId={}, err={}",
                    boundUserId, parsed.messageId(), ex.getMessage());
            throw ex;
        }
    }

    /**
     * 测试覆盖订阅状态；未开启开关时拒绝。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public SubscriptionStatusVO testOverride(long userId, BillingTestOverrideInDto body) {
        if (!plusBillingProperties.isTestOverrideEnabled()) {
            throw new BusinessException(appMessages.get("app.error.billing.testOverrideDisabled"));
        }
        if (body == null || !StringUtils.hasText(body.getState())) {
            throw new BusinessException(appMessages.get("app.error.billing.invalidRequest"));
        }
        String state = body.getState().trim().toLowerCase();
        String productId = StringUtils.hasText(body.getProductId())
                ? normalizeProductId(body.getProductId())
                : PlusEntitlementSupport.PRODUCT_YEARLY;
        LocalDateTime now = LocalDateTime.now();
        applyTestOverrideState(userId, state, productId, now);
        log.info("billing test-override applied, userId={}, state={}, productId={}", userId, state, productId);
        return buildStatusVo(userId);
    }

    private String resolveProvider(String token) {
        if (token.startsWith(MockBillingProvider.TOKEN_PREFIX)) {
            return BillingProviders.MOCK;
        }
        return BillingProviders.GOOGLE_PLAY;
    }

    private void applyTestOverrideState(long userId, String state, String productId, LocalDateTime now) {
        switch (state) {
            case PlusEntitlementSupport.STATE_NONE -> {
                vipSubscriptionService.softDeleteAllForUser(userId, userId);
                userService.syncVipEntitlement(userId, false, now.minusMinutes(1), userId);
            }
            case PlusEntitlementSupport.STATE_TRIAL -> {
                LocalDateTime endAt = now.plusDays(7);
                vipSubscriptionService.upsertSubscription(
                        userId, PlusEntitlementSupport.PRODUCT_YEARLY, null, null,
                        plusBillingProperties.getPlayPackageName(), true,
                        PlusEntitlementSupport.SOURCE_TEST, now, endAt, STATUS_ACTIVE, null, userId);
                userService.syncVipEntitlement(userId, true, endAt, userId);
            }
            case PlusEntitlementSupport.STATE_ACTIVE -> {
                boolean yearly = PlusEntitlementSupport.PRODUCT_YEARLY.equals(productId);
                LocalDateTime endAt = yearly ? now.plusDays(365) : now.plusDays(30);
                vipSubscriptionService.upsertSubscription(
                        userId, productId, null, null,
                        plusBillingProperties.getPlayPackageName(), false,
                        PlusEntitlementSupport.SOURCE_TEST, now, endAt, STATUS_ACTIVE, null, userId);
                userService.syncVipEntitlement(userId, true, endAt, userId);
            }
            case PlusEntitlementSupport.STATE_EXPIRED -> {
                LocalDateTime endAt = now.minusDays(1);
                vipSubscriptionService.upsertSubscription(
                        userId, productId, null, null,
                        plusBillingProperties.getPlayPackageName(), false,
                        PlusEntitlementSupport.SOURCE_TEST, now.minusDays(30), endAt, STATUS_EXPIRED, null, userId);
                userService.syncVipEntitlement(userId, false, endAt, userId);
            }
            default -> throw new BusinessException(appMessages.get("app.error.billing.invalidState"));
        }
    }

    private SubscriptionStatusVO buildStatusVo(long userId) {
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

    private String normalizeProductId(String raw) {
        if (!PlusEntitlementSupport.isPlusProduct(raw)) {
            throw new BusinessException(appMessages.get("app.error.billing.invalidProduct"));
        }
        return raw.trim();
    }

    /**
     * 试用判定：年订 + 客户端显式 isTrial=true；或年订且用户尚无 play 源订阅时默认 7 天试用
     *（Play Developer API 未接线前的占位策略）。
     */
    private boolean resolveTrial(long userId, String productId, Boolean isTrialFlag) {
        if (!PlusEntitlementSupport.PRODUCT_YEARLY.equals(productId)) {
            return false;
        }
        if (Boolean.TRUE.equals(isTrialFlag)) {
            return true;
        }
        if (Boolean.FALSE.equals(isTrialFlag)) {
            return false;
        }
        var existing = vipSubscriptionService.findLatestForUser(userId);
        if (existing == null) {
            return true;
        }
        return !PlusEntitlementSupport.SOURCE_PLAY.equals(
                existing.getSource() == null ? "" : existing.getSource().trim());
    }

    private long resolveBoundUserId(String purchaseToken) {
        String tokenHash = PurchaseTokenHasher.hashToken(purchaseToken);
        PaymentPurchaseDomain purchase = paymentPurchaseService.findByTokenHash(tokenHash);
        if (purchase != null && purchase.getUserId() != null) {
            return purchase.getUserId();
        }
        VipSubscriptionDomain legacy = vipSubscriptionService.findByPurchaseToken(purchaseToken);
        if (legacy != null && legacy.getUserId() != null) {
            return legacy.getUserId();
        }
        throw new BusinessException(appMessages.get("app.error.billing.invalidToken"));
    }

    private String resolveProductIdForRtdn(BillingMockRtdnInDto body, ParsedNotification parsed, String token) {
        if (StringUtils.hasText(body.getProductId())) {
            return normalizeProductId(body.getProductId());
        }
        if (StringUtils.hasText(parsed.storeProductId())) {
            return normalizeProductId(parsed.storeProductId());
        }
        String fromToken = extractProductIdFromMockToken(token);
        if (StringUtils.hasText(fromToken)) {
            return normalizeProductId(fromToken);
        }
        return PlusEntitlementSupport.PRODUCT_YEARLY;
    }

    private static String extractProductIdFromMockToken(String token) {
        if (!StringUtils.hasText(token) || !token.startsWith(MockBillingProvider.TOKEN_PREFIX)) {
            return null;
        }
        String remainder = token.substring(MockBillingProvider.TOKEN_PREFIX.length());
        String[] parts = remainder.split(":", 3);
        if (parts.length < 1 || !StringUtils.hasText(parts[0])) {
            return null;
        }
        return parts[0].trim();
    }

    private Object buildMockRtdnPayload(BillingMockRtdnInDto body) {
        Map<String, String> payload = new LinkedHashMap<>();
        payload.put("messageId", body.getMessageId().trim());
        payload.put("purchaseToken", body.getPurchaseToken().trim());
        payload.put("notificationType", body.getNotificationType().trim());
        if (StringUtils.hasText(body.getProductId())) {
            payload.put("productId", body.getProductId().trim());
        }
        return payload;
    }

    private static String truncateErrorMessage(String message) {
        if (message == null) {
            return null;
        }
        if (message.length() <= WEBHOOK_ERROR_MESSAGE_MAX_LEN) {
            return message;
        }
        return message.substring(0, WEBHOOK_ERROR_MESSAGE_MAX_LEN);
    }

    private static String truncateToken(String token) {
        if (token == null) {
            return "";
        }
        if (token.length() <= 8) {
            return "***";
        }
        return token.substring(0, 4) + "…" + token.substring(token.length() - 4);
    }
}
