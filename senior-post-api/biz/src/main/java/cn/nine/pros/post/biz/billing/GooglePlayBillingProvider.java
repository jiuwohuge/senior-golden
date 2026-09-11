package cn.nine.pros.post.biz.billing;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.pros.post.biz.billing.model.ParsedNotification;
import cn.nine.pros.post.biz.billing.model.RestoreCommand;
import cn.nine.pros.post.biz.billing.model.SubscriptionSnapshot;
import cn.nine.pros.post.biz.billing.model.VerifiedPurchase;
import cn.nine.pros.post.biz.billing.model.VerifyPurchaseCommand;
import cn.nine.pros.post.biz.config.PlusBillingProperties;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.biz.support.PlusEntitlementSupport;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Google Play 支付渠道占位：公钥为空时结构化接受；公钥已配置则拒绝（尚未接线 Developer API）。
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class GooglePlayBillingProvider implements BillingProvider {

    private static final int MIN_TOKEN_LEN = 8;

    private final PlusBillingProperties plusBillingProperties;
    private final AppMessages appMessages;

    @Override
    public String providerName() {
        return BillingProviders.GOOGLE_PLAY;
    }

    /**
     * 校验 Play 购买：无公钥时返回 purchased/active 并按月/年/试用计算周期。
     */
    @Override
    public VerifiedPurchase verifyPurchase(VerifyPurchaseCommand cmd) {
        if (cmd == null || !StringUtils.hasText(cmd.purchaseToken())) {
            throw new BusinessException(appMessages.get("app.error.billing.invalidToken"));
        }
        String token = cmd.purchaseToken().trim();
        if (token.length() < MIN_TOKEN_LEN) {
            throw new BusinessException(appMessages.get("app.error.billing.invalidToken"));
        }
        if (StringUtils.hasText(plusBillingProperties.getPlayPublicKey())) {
            log.warn("play-public-key is set but Play Developer API not wired; rejecting verify");
            throw new BusinessException(appMessages.get("app.error.billing.playVerifyNotWired"));
        }
        String productId = cmd.productId() == null ? "" : cmd.productId().trim();
        if (!PlusEntitlementSupport.isPlusProduct(productId)) {
            throw new BusinessException(appMessages.get("app.error.billing.invalidProduct"));
        }
        validatePackageName(cmd.packageName());
        boolean trial = resolveTrial(productId, cmd.isTrial());
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime endAt = computeEndAt(now, productId, trial);
        log.info("google_play verify placeholder accept, productId={}, trial={}, endAt={}, token={}",
                productId, trial, endAt, PurchaseTokenPreview.truncate(token));
        return new VerifiedPurchase(
                BillingProviders.GOOGLE_PLAY,
                token,
                productId,
                "purchased",
                "active",
                now,
                endAt,
                true,
                trial,
                cmd.orderId(),
                "sandbox",
                null,
                null);
    }

    @Override
    public SubscriptionSnapshot getSubscription(String purchaseToken) {
        throw new UnsupportedOperationException("google_play getSubscription not wired");
    }

    @Override
    public void acknowledgePurchase(String purchaseToken, String productId) {
        log.debug("google_play acknowledgePurchase stub, productId={}, token={}",
                productId, PurchaseTokenPreview.truncate(purchaseToken));
    }

    @Override
    public ParsedNotification parseNotification(String rawPayload) {
        throw new UnsupportedOperationException("google_play parseNotification not wired");
    }

    @Override
    public List<VerifiedPurchase> restorePurchases(RestoreCommand cmd) {
        return List.of();
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

    private static boolean resolveTrial(String productId, Boolean isTrialFlag) {
        if (!PlusEntitlementSupport.PRODUCT_YEARLY.equals(productId)) {
            return false;
        }
        return Boolean.TRUE.equals(isTrialFlag);
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
}
