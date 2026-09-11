package cn.nine.pros.post.biz.service.biz.admin.impl;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.billing.BillingProviders;
import cn.nine.pros.post.biz.controller.admin.AdminPageHelper;
import cn.nine.pros.post.biz.model.domain.CommerceProductDomain;
import cn.nine.pros.post.biz.model.domain.PaymentPurchaseDomain;
import cn.nine.pros.post.biz.model.domain.PaymentSubscriptionDomain;
import cn.nine.pros.post.biz.model.domain.PaymentTransactionDomain;
import cn.nine.pros.post.biz.model.domain.PaymentWebhookEventDomain;
import cn.nine.pros.post.biz.model.domain.UserEntitlementDomain;
import cn.nine.pros.post.biz.service.base.CommerceProductService;
import cn.nine.pros.post.biz.service.base.PaymentPurchaseService;
import cn.nine.pros.post.biz.service.base.PaymentSubscriptionService;
import cn.nine.pros.post.biz.service.base.PaymentTransactionService;
import cn.nine.pros.post.biz.service.base.PaymentWebhookEventService;
import cn.nine.pros.post.biz.service.base.UserEntitlementService;
import cn.nine.pros.post.biz.service.biz.PurchaseSyncBizService;
import cn.nine.pros.post.biz.service.biz.SyncPurchaseContext;
import cn.nine.pros.post.biz.service.biz.admin.AdminCommercePurchaseBizService;
import cn.nine.pros.post.biz.service.biz.admin.support.AdminOperationRecorder;
import cn.nine.pros.post.client.model.input.admin.AdminCommercePurchaseIdInDto;
import cn.nine.pros.post.client.model.input.admin.AdminCommercePurchaseQueryInDto;
import cn.nine.pros.post.client.model.out.AdminCommercePurchaseForceSyncResultVO;
import cn.nine.pros.post.client.model.out.CommerceEntitlementVO;
import cn.nine.pros.post.client.model.out.CommercePurchaseDetailVO;
import cn.nine.pros.post.client.model.out.CommercePurchaseTimelineItemVO;
import cn.nine.pros.post.client.model.out.CommercePurchaseVO;
import cn.nine.pros.post.client.model.out.CommercePurchaseWebhookEventVO;
import cn.nine.pros.post.client.model.out.CommerceSubscriptionSummaryVO;
import cn.nine.pros.post.client.model.out.SubscriptionStatusVO;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

/**
 * 管理端购买记录：只读分页/详情/webhook；mock 可强制同步（不退款）。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AdminCommercePurchaseBizServiceImpl implements AdminCommercePurchaseBizService {

    private static final int WEBHOOK_LOOKUP_LIMIT = 50;
    private static final Pattern TOKEN_FIELD_PATTERN = Pattern.compile(
            "(?i)(\"(?:purchaseToken|token|purchase_token)\"\\s*:\\s*\")([^\"]+)(\")");

    private final PaymentPurchaseService paymentPurchaseService;
    private final PaymentSubscriptionService paymentSubscriptionService;
    private final PaymentTransactionService paymentTransactionService;
    private final PaymentWebhookEventService paymentWebhookEventService;
    private final UserEntitlementService userEntitlementService;
    private final CommerceProductService commerceProductService;
    private final PurchaseSyncBizService purchaseSyncBizService;
    private final AdminOperationRecorder adminOperationRecorder;
    private final ObjectMapper objectMapper;

    @Override
    public PageData<CommercePurchaseVO> paging(AdminCommercePurchaseQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        Long productId = body.getProductId();
        if (productId == null && StringUtils.hasText(body.getProductCode())) {
            CommerceProductDomain byCode = commerceProductService.findByCodeAnyStatus(body.getProductCode());
            if (byCode == null) {
                return AdminPageHelper.pageData(
                        pageQuery, new Page<>(pageQuery.getPage(), pageQuery.getSize()), List.of());
            }
            productId = byCode.getId();
        }
        Page<PaymentPurchaseDomain> page = paymentPurchaseService.pageForAdmin(
                pageQuery,
                body.getUserId(),
                body.getPurchaseNo(),
                productId,
                body.getStatus(),
                body.getPurchasedAtFrom(),
                body.getPurchasedAtTo());
        Map<Long, String> codeMap = loadProductCodeMap(page.getRecords());
        List<CommercePurchaseVO> records = page.getRecords().stream()
                .map(p -> toPurchaseVo(p, codeMap.get(p.getProductId())))
                .collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, page, records);
    }

    @Override
    public CommercePurchaseDetailVO detail(AdminCommercePurchaseIdInDto body) {
        PaymentPurchaseDomain purchase = requirePurchase(body);
        CommerceProductDomain product = purchase.getProductId() == null
                ? null
                : commerceProductService.getById(purchase.getProductId());
        CommercePurchaseVO purchaseVo = toPurchaseVo(
                purchase, product == null ? null : product.getProductCode());

        PaymentSubscriptionDomain sub = resolveSubscription(purchase);
        List<CommerceEntitlementVO> entitlements = buildEntitlements(purchase, product);
        List<CommercePurchaseTimelineItemVO> timeline = buildTimeline(purchase, sub);
        List<CommercePurchaseWebhookEventVO> webhooks = listWebhookVos(purchase);

        log.info("admin purchase detail, purchaseId={}, userId={}, webhooks={}",
                purchase.getId(), purchase.getUserId(), webhooks.size());
        return CommercePurchaseDetailVO.builder()
                .purchase(purchaseVo)
                .subscription(toSubscriptionSummary(sub))
                .entitlements(entitlements)
                .timeline(timeline)
                .webhooks(webhooks)
                .build();
    }

    @Override
    public List<CommercePurchaseWebhookEventVO> webhookEvents(AdminCommercePurchaseIdInDto body) {
        PaymentPurchaseDomain purchase = requirePurchase(body);
        List<CommercePurchaseWebhookEventVO> list = listWebhookVos(purchase);
        log.info("admin purchase webhook-events, purchaseId={}, count={}", purchase.getId(), list.size());
        return list;
    }

    /**
     * mock + Base64 cipher 可解码时调用 syncPurchase；否则返回提示。禁止退款。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public AdminCommercePurchaseForceSyncResultVO forceSync(AdminCommercePurchaseIdInDto body) {
        PaymentPurchaseDomain purchase = requirePurchase(body);
        String token = recoverTokenForSync(purchase);
        if (!StringUtils.hasText(token)) {
            log.info("admin force sync skipped, purchaseId={}, reason=no_cipher", purchase.getId());
            return AdminCommercePurchaseForceSyncResultVO.builder()
                    .purchaseId(purchase.getId())
                    .synced(false)
                    .message("no recoverable purchase token (cipher only for mock); cannot force sync")
                    .build();
        }
        if (purchase.getUserId() == null) {
            return AdminCommercePurchaseForceSyncResultVO.builder()
                    .purchaseId(purchase.getId())
                    .synced(false)
                    .message("purchase has no userId; cannot force sync")
                    .build();
        }
        SyncPurchaseContext ctx = SyncPurchaseContext.of(
                purchase.getStoreProductId(),
                null,
                purchase.getExternalOrderId(),
                false,
                null);
        SubscriptionStatusVO status = purchaseSyncBizService.syncPurchase(
                purchase.getProvider(), token, purchase.getUserId(), ctx);
        adminOperationRecorder.record("commerce.purchase_force_sync", "payment_purchase", purchase.getId(),
                "provider=" + purchase.getProvider());
        log.info("admin force sync purchase, purchaseId={}, provider={}, preview={}",
                purchase.getId(), purchase.getProvider(), purchase.getPurchaseTokenPreview());
        return AdminCommercePurchaseForceSyncResultVO.builder()
                .purchaseId(purchase.getId())
                .synced(true)
                .message("re-queried provider state via syncPurchase (no refund)")
                .subscriptionStatus(status)
                .build();
    }

    private PaymentPurchaseDomain requirePurchase(AdminCommercePurchaseIdInDto body) {
        if (body == null) {
            throw new BusinessException("purchaseId or purchaseNo required");
        }
        if (body.getPurchaseId() != null) {
            PaymentPurchaseDomain byId = paymentPurchaseService.findByIdNotDeleted(body.getPurchaseId());
            if (byId == null) {
                throw new BusinessException("purchase not found");
            }
            return byId;
        }
        if (StringUtils.hasText(body.getPurchaseNo())) {
            PaymentPurchaseDomain byNo = paymentPurchaseService.findByPurchaseNo(body.getPurchaseNo());
            if (byNo == null) {
                throw new BusinessException("purchase not found");
            }
            return byNo;
        }
        throw new BusinessException("purchaseId or purchaseNo required");
    }

    private PaymentSubscriptionDomain resolveSubscription(PaymentPurchaseDomain purchase) {
        PaymentSubscriptionDomain byPurchaseId = paymentSubscriptionService.findByPurchaseId(purchase.getId());
        if (byPurchaseId != null) {
            return byPurchaseId;
        }
        if (!StringUtils.hasText(purchase.getPurchaseTokenHash())) {
            return null;
        }
        return paymentSubscriptionService.findByTokenHash(purchase.getPurchaseTokenHash());
    }

    private List<CommerceEntitlementVO> buildEntitlements(
            PaymentPurchaseDomain purchase, CommerceProductDomain product) {
        if (purchase.getUserId() == null) {
            return List.of();
        }
        List<UserEntitlementDomain> all = userEntitlementService.listByUserId(purchase.getUserId());
        List<UserEntitlementDomain> filtered = all.stream()
                .filter(e -> matchesPurchaseEntitlement(e, purchase, product))
                .collect(Collectors.toList());
        if (filtered.isEmpty()) {
            filtered = all;
        }
        return filtered.stream().map(e -> toEntitlementVo(e, product)).collect(Collectors.toList());
    }

    private static boolean matchesPurchaseEntitlement(
            UserEntitlementDomain e, PaymentPurchaseDomain purchase, CommerceProductDomain product) {
        if (Objects.equals(e.getPurchaseId(), purchase.getId())) {
            return true;
        }
        if (Objects.equals(e.getProductId(), purchase.getProductId())) {
            return true;
        }
        return product != null
                && StringUtils.hasText(product.getEntitlementCode())
                && product.getEntitlementCode().equals(e.getEntitlementCode());
    }

    private CommerceEntitlementVO toEntitlementVo(UserEntitlementDomain row, CommerceProductDomain productHint) {
        CommerceProductDomain product = productHint;
        if (product == null || !Objects.equals(product.getId(), row.getProductId())) {
            product = row.getProductId() == null ? null : commerceProductService.getById(row.getProductId());
        }
        return CommerceEntitlementVO.builder()
                .entitlementId(row.getId())
                .productId(row.getProductId())
                .productCode(product == null ? null : product.getProductCode())
                .productType(product == null ? null : product.getProductType())
                .titleKey(product == null ? null : product.getTitleKey())
                .source(row.getSource())
                .expiresAt(row.getExpiresAt())
                .grantedAt(row.getCreatedAt() != null ? row.getCreatedAt() : row.getEffectiveAt())
                .build();
    }

    private List<CommercePurchaseTimelineItemVO> buildTimeline(
            PaymentPurchaseDomain purchase, PaymentSubscriptionDomain sub) {
        List<CommercePurchaseTimelineItemVO> items = new ArrayList<>();
        if (purchase.getPurchasedAt() != null || purchase.getCreatedAt() != null) {
            items.add(CommercePurchaseTimelineItemVO.builder()
                    .kind("purchase")
                    .title("购买主单")
                    .detail("status=" + purchase.getStatus())
                    .at(purchase.getPurchasedAt() != null ? purchase.getPurchasedAt() : purchase.getCreatedAt())
                    .build());
        }
        for (PaymentTransactionDomain tx : paymentTransactionService.listByPurchaseId(purchase.getId())) {
            items.add(CommercePurchaseTimelineItemVO.builder()
                    .kind(tx.getTxType())
                    .title(txTitle(tx.getTxType()))
                    .detail("providerTxId=" + tx.getProviderTxId())
                    .at(tx.getOccurredAt() != null ? tx.getOccurredAt() : tx.getCreatedAt())
                    .build());
        }
        if (sub != null) {
            items.add(CommercePurchaseTimelineItemVO.builder()
                    .kind("subscription")
                    .title("当前订阅")
                    .detail("status=" + sub.getStatus() + ", autoRenew=" + sub.getAutoRenew())
                    .at(sub.getLastSyncedAt() != null ? sub.getLastSyncedAt() : sub.getUpdatedAt())
                    .build());
        }
        for (CommercePurchaseWebhookEventVO wh : listWebhookVos(purchase)) {
            items.add(CommercePurchaseTimelineItemVO.builder()
                    .kind("webhook")
                    .title(wh.getEventType() != null ? wh.getEventType() : "webhook")
                    .detail("processStatus=" + wh.getProcessStatus())
                    .at(wh.getReceivedAt())
                    .build());
        }
        items.sort(Comparator.comparing(CommercePurchaseTimelineItemVO::getAt,
                Comparator.nullsLast(Comparator.naturalOrder())));
        return items;
    }

    private static String txTitle(String txType) {
        if (txType == null) {
            return "流水";
        }
        return switch (txType) {
            case "initial_purchase" -> "首次购买";
            case "renewal" -> "续费";
            case "refund" -> "退款";
            case "revocation" -> "撤销";
            case "chargeback" -> "拒付";
            default -> txType;
        };
    }

    private List<CommercePurchaseWebhookEventVO> listWebhookVos(PaymentPurchaseDomain purchase) {
        if (!StringUtils.hasText(purchase.getProvider())) {
            return List.of();
        }
        LocalDateTime from = purchase.getPurchasedAt() != null
                ? purchase.getPurchasedAt().minusDays(1)
                : LocalDateTime.now().minusDays(7);
        List<PaymentWebhookEventDomain> events = paymentWebhookEventService.listForPurchaseLookup(
                purchase.getProvider(), purchase.getStoreProductId(), from, WEBHOOK_LOOKUP_LIMIT);
        // 再按 purchaseNo / tokenPreview 做轻量过滤（无命中则保留 provider 窗口内结果）
        List<PaymentWebhookEventDomain> matched = events.stream()
                .filter(e -> payloadLikelyMatches(e, purchase))
                .collect(Collectors.toList());
        List<PaymentWebhookEventDomain> use = matched.isEmpty() ? events : matched;
        return use.stream().map(this::toWebhookVo).collect(Collectors.toList());
    }

    private boolean payloadLikelyMatches(PaymentWebhookEventDomain event, PaymentPurchaseDomain purchase) {
        String text = payloadAsText(event.getPayloadJson());
        if (!StringUtils.hasText(text)) {
            return false;
        }
        if (StringUtils.hasText(purchase.getStoreProductId()) && text.contains(purchase.getStoreProductId())) {
            return true;
        }
        if (StringUtils.hasText(purchase.getPurchaseNo()) && text.contains(purchase.getPurchaseNo())) {
            return true;
        }
        return StringUtils.hasText(purchase.getPurchaseTokenPreview())
                && text.contains(purchase.getPurchaseTokenPreview());
    }

    private CommercePurchaseWebhookEventVO toWebhookVo(PaymentWebhookEventDomain e) {
        return CommercePurchaseWebhookEventVO.builder()
                .id(e.getId())
                .provider(e.getProvider())
                .eventIdOrMessageId(e.getEventIdOrMessageId())
                .eventType(e.getEventType())
                .processStatus(e.getProcessStatus())
                .errorMessage(e.getErrorMessage())
                .retryCount(e.getRetryCount())
                .receivedAt(e.getReceivedAt())
                .processedAt(e.getProcessedAt())
                .payloadMasked(maskTokenFields(payloadAsText(e.getPayloadJson())))
                .build();
    }

    private String payloadAsText(Object payload) {
        if (payload == null) {
            return null;
        }
        if (payload instanceof String s) {
            return s;
        }
        try {
            return objectMapper.writeValueAsString(payload);
        } catch (Exception ex) {
            return String.valueOf(payload);
        }
    }

    private static String maskTokenFields(String payload) {
        if (!StringUtils.hasText(payload)) {
            return payload;
        }
        return TOKEN_FIELD_PATTERN.matcher(payload).replaceAll("$1***$3");
    }

    private String recoverTokenForSync(PaymentPurchaseDomain purchase) {
        if (!BillingProviders.MOCK.equals(purchase.getProvider())) {
            return null;
        }
        if (!StringUtils.hasText(purchase.getPurchaseTokenCipher())) {
            return null;
        }
        try {
            return new String(Base64.getDecoder().decode(purchase.getPurchaseTokenCipher()), StandardCharsets.UTF_8);
        } catch (IllegalArgumentException e) {
            log.warn("invalid mock purchaseTokenCipher, purchaseId={}", purchase.getId());
            return null;
        }
    }

    private Map<Long, String> loadProductCodeMap(List<PaymentPurchaseDomain> records) {
        Set<Long> productIds = records.stream()
                .map(PaymentPurchaseDomain::getProductId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());
        if (productIds.isEmpty()) {
            return Map.of();
        }
        return commerceProductService.listByIds(productIds).stream()
                .collect(Collectors.toMap(
                        CommerceProductDomain::getId, CommerceProductDomain::getProductCode, (a, b) -> a));
    }

    private static CommercePurchaseVO toPurchaseVo(PaymentPurchaseDomain p, String productCode) {
        return CommercePurchaseVO.builder()
                .id(p.getId())
                .purchaseNo(p.getPurchaseNo())
                .userId(p.getUserId())
                .productId(p.getProductId())
                .productCode(productCode)
                .provider(p.getProvider())
                .storeProductId(p.getStoreProductId())
                .purchaseTokenPreview(p.getPurchaseTokenPreview())
                .externalOrderId(p.getExternalOrderId())
                .status(p.getStatus())
                .purchasedAt(p.getPurchasedAt())
                .paidAt(p.getPaidAt())
                .environment(p.getEnvironment())
                .channelSnapshotJson(p.getChannelSnapshotJson())
                .createdAt(p.getCreatedAt())
                .build();
    }

    private static CommerceSubscriptionSummaryVO toSubscriptionSummary(PaymentSubscriptionDomain sub) {
        if (sub == null) {
            return null;
        }
        return CommerceSubscriptionSummaryVO.builder()
                .id(sub.getId())
                .purchaseId(sub.getPurchaseId())
                .productId(sub.getProductId())
                .provider(sub.getProvider())
                .status(sub.getStatus())
                .currentPeriodStart(sub.getCurrentPeriodStart())
                .currentPeriodEnd(sub.getCurrentPeriodEnd())
                .autoRenew(sub.getAutoRenew())
                .lastSyncedAt(sub.getLastSyncedAt())
                .storeProductId(sub.getStoreProductId())
                .build();
    }
}
