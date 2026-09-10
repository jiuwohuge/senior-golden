package cn.nine.pros.post.biz.service.biz.impl;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.pros.post.biz.config.PlusBillingProperties;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.VipSubscriptionDomain;
import cn.nine.pros.post.biz.service.base.AiAssistUsageService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.biz.service.base.VipSubscriptionService;
import cn.nine.pros.post.biz.service.biz.AppBillingBizService;
import cn.nine.pros.post.biz.service.biz.support.PlusEntitlementSupport;
import cn.nine.pros.post.client.model.input.app.BillingTestOverrideInDto;
import cn.nine.pros.post.client.model.input.app.PlayPurchaseVerifyInDto;
import cn.nine.pros.post.client.model.input.app.PlayRestoreInDto;
import cn.nine.pros.post.client.model.out.PlusSkuItemVO;
import cn.nine.pros.post.client.model.out.SubscriptionStatusVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.TemporalAdjusters;
import java.util.List;

/**
 * Plus / Play Billing：订阅状态、购买校验（占位）、恢复与测试覆盖。
 * <p>生产必须接入 Google Play Developer API；当前仅在 play-public-key 为空时做结构化校验。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AppBillingBizServiceImpl implements AppBillingBizService {

    private static final int STATUS_ACTIVE = 1;
    private static final int STATUS_EXPIRED = 2;
    private static final int MIN_TOKEN_LEN = 8;

    private final PlusEntitlementSupport plusEntitlementSupport;
    private final VipSubscriptionService vipSubscriptionService;
    private final AiAssistUsageService aiAssistUsageService;
    private final UserService userService;
    private final PlusBillingProperties plusBillingProperties;
    private final AppMessages appMessages;

    @Override
    public SubscriptionStatusVO getSubscriptionStatus(long userId) {
        return buildStatusVo(userId);
    }

    /**
     * 校验并落库 Play 购买；同步 bu_user.is_vip / vip_expire_at。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public SubscriptionStatusVO verifyPurchase(long userId, PlayPurchaseVerifyInDto body) {
        if (body == null) {
            throw new BusinessException(appMessages.get("app.error.billing.invalidRequest"));
        }
        String productId = normalizeProductId(body.getProductId());
        String token = body.getPurchaseToken() == null ? "" : body.getPurchaseToken().trim();
        validatePlayTokenPlaceholder(token);
        validatePackageName(body.getPackageName());

        VipSubscriptionDomain bound = vipSubscriptionService.findByPurchaseToken(token);
        if (bound != null && bound.getUserId() != null && !bound.getUserId().equals(userId)) {
            log.info("verify-purchase rejected: token bound to other user, userId={}, ownerId={}, token={}",
                    userId, bound.getUserId(), truncateToken(token));
            throw new BusinessException(appMessages.get("app.error.billing.tokenBoundOtherUser"));
        }

        boolean trial = resolveTrial(userId, productId, body.getIsTrial());
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime endAt = computeEndAt(now, productId, trial);
        LocalDateTime ackAt = Boolean.TRUE.equals(body.getAcknowledged()) ? now : null;
        String packageName = StringUtils.hasText(body.getPackageName())
                ? body.getPackageName().trim()
                : plusBillingProperties.getPlayPackageName();

        vipSubscriptionService.upsertSubscription(
                userId,
                productId,
                token,
                body.getOrderId(),
                packageName,
                trial,
                PlusEntitlementSupport.SOURCE_PLAY,
                now,
                endAt,
                STATUS_ACTIVE,
                ackAt,
                userId);
        userService.syncVipEntitlement(userId, true, endAt, userId);
        log.info("verify-purchase ok, userId={}, productId={}, trial={}, endAt={}, token={}",
                userId, productId, trial, endAt, truncateToken(token));
        return buildStatusVo(userId);
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
     * Play Developer API 占位：公钥为空时仅要求 token 非空且长度≥8。
     * TODO(prod): 用 Google Play Developer API 校验订阅真实性与有效期。
     */
    private void validatePlayTokenPlaceholder(String token) {
        if (!StringUtils.hasText(token) || token.length() < MIN_TOKEN_LEN) {
            throw new BusinessException(appMessages.get("app.error.billing.invalidToken"));
        }
        if (StringUtils.hasText(plusBillingProperties.getPlayPublicKey())) {
            // 公钥已配置但尚未接线真实校验：拒绝以免误以为已验签
            log.warn("play-public-key is set but Play Developer API not wired; rejecting verify");
            throw new BusinessException(appMessages.get("app.error.billing.playVerifyNotWired"));
        }
        log.debug("play verify placeholder accept (no public key), tokenLen={}", token.length());
    }

    private void validatePackageName(String clientPackage) {
        String expected = plusBillingProperties.getPlayPackageName();
        if (!StringUtils.hasText(clientPackage) || !StringUtils.hasText(expected)) {
            return;
        }
        if (!expected.trim().equals(clientPackage.trim())) {
            throw new BusinessException(appMessages.get("app.error.billing.packageMismatch"));
        }
    }

    /**
     * 试用判定：年订 + 客户端显式 isTrial=true；或年订且用户尚无 play 源订阅时默认 7 天试用
     *（Play Developer API 未接线前的占位策略；接线后应以商店 intro/trial 为准）。
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
        VipSubscriptionDomain existing = vipSubscriptionService.findLatestForUser(userId);
        if (existing == null) {
            return true;
        }
        return !PlusEntitlementSupport.SOURCE_PLAY.equals(
                existing.getSource() == null ? "" : existing.getSource().trim());
    }

    private static LocalDateTime computeEndAt(LocalDateTime now, String productId, boolean trial) {
        if (trial) {
            return now.plusDays(7);
        }
        if (PlusEntitlementSupport.PRODUCT_YEARLY.equals(productId)) {
            return now.plusDays(365);
        }
        return now.plusDays(30);
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
