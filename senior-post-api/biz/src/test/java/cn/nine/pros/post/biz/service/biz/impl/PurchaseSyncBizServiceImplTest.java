package cn.nine.pros.post.biz.service.biz.impl;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.pros.post.biz.billing.BillingProvider;
import cn.nine.pros.post.biz.billing.BillingProviderRegistry;
import cn.nine.pros.post.biz.billing.BillingProviders;
import cn.nine.pros.post.biz.billing.MockBillingProvider;
import cn.nine.pros.post.biz.billing.model.VerifiedPurchase;
import cn.nine.pros.post.biz.billing.model.VerifyPurchaseCommand;
import cn.nine.pros.post.biz.billing.util.PurchaseTokenHasher;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.CommerceProductDomain;
import cn.nine.pros.post.biz.model.domain.PaymentPurchaseDomain;
import cn.nine.pros.post.biz.model.domain.PaymentSubscriptionDomain;
import cn.nine.pros.post.biz.model.domain.VipSubscriptionDomain;
import cn.nine.pros.post.biz.service.base.AiAssistUsageService;
import cn.nine.pros.post.biz.service.base.CommerceProductService;
import cn.nine.pros.post.biz.service.base.PaymentPurchaseService;
import cn.nine.pros.post.biz.service.base.PaymentSubscriptionService;
import cn.nine.pros.post.biz.service.base.PaymentTransactionService;
import cn.nine.pros.post.biz.service.base.UserEntitlementService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.biz.service.base.VipSubscriptionService;
import cn.nine.pros.post.biz.service.biz.SyncPurchaseContext;
import cn.nine.pros.post.biz.service.biz.support.PlusEntitlementSupport;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * {@link PurchaseSyncBizServiceImpl} 编排单元测试（Mockito，无 Spring 上下文）。
 */
@ExtendWith(MockitoExtension.class)
class PurchaseSyncBizServiceImplTest {

    private static final long USER_ID = 42L;
    private static final long PRODUCT_DB_ID = 100L;

    @Mock
    private BillingProviderRegistry billingProviderRegistry;
    @Mock
    private BillingProvider billingProvider;
    @Mock
    private PaymentPurchaseService paymentPurchaseService;
    @Mock
    private PaymentSubscriptionService paymentSubscriptionService;
    @Mock
    private PaymentTransactionService paymentTransactionService;
    @Mock
    private UserEntitlementService userEntitlementService;
    @Mock
    private CommerceProductService commerceProductService;
    @Mock
    private VipSubscriptionService vipSubscriptionService;
    @Mock
    private UserService userService;
    @Mock
    private PlusEntitlementSupport plusEntitlementSupport;
    @Mock
    private AiAssistUsageService aiAssistUsageService;
    @Mock
    private AppMessages appMessages;

    private PurchaseSyncBizServiceImpl syncBiz;

    @BeforeEach
    void setUp() {
        lenient().when(appMessages.get(anyString())).thenAnswer(inv -> inv.getArgument(0));
        lenient().when(billingProviderRegistry.getRequired(anyString())).thenReturn(billingProvider);
        lenient().when(plusEntitlementSupport.resolve(USER_ID)).thenReturn(
                PlusEntitlementSupport.Snapshot.builder()
                        .state(PlusEntitlementSupport.STATE_ACTIVE)
                        .productId(PlusEntitlementSupport.PRODUCT_YEARLY)
                        .entitled(true)
                        .isTrial(false)
                        .source(PlusEntitlementSupport.SOURCE_MOCK)
                        .build());
        lenient().when(plusEntitlementSupport.aiQuotaLimit(anyBoolean())).thenReturn(100);
        lenient().when(plusEntitlementSupport.recallWindowMinutes()).thenReturn(20);
        lenient().when(aiAssistUsageService.getUseCount(eq(USER_ID), any())).thenReturn(0);

        CommerceProductDomain product = new CommerceProductDomain();
        product.setId(PRODUCT_DB_ID);
        product.setProductCode(PlusEntitlementSupport.PRODUCT_YEARLY);
        product.setEntitlementCode("plus");
        lenient().when(commerceProductService.findByCode(PlusEntitlementSupport.PRODUCT_YEARLY)).thenReturn(product);
        lenient().when(commerceProductService.findByCode(PlusEntitlementSupport.PRODUCT_MONTHLY)).thenReturn(product);

        syncBiz = new PurchaseSyncBizServiceImpl(
                billingProviderRegistry,
                paymentPurchaseService,
                paymentSubscriptionService,
                paymentTransactionService,
                userEntitlementService,
                commerceProductService,
                vipSubscriptionService,
                userService,
                plusEntitlementSupport,
                aiAssistUsageService,
                appMessages);
    }

    @Test
    void purchasedGrantsEntitlementAndVip() {
        String token = MockBillingProvider.generateToken(PlusEntitlementSupport.PRODUCT_YEARLY, "PURCHASED");
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime end = now.plusDays(365);
        stubVerify(token, "purchased", "active", now, end, true, false, "PURCHASED");
        when(paymentPurchaseService.findByTokenHash(anyString())).thenReturn(null);
        when(paymentPurchaseService.upsertByTokenHash(any(), eq(USER_ID))).thenAnswer(inv -> {
            PaymentPurchaseDomain row = inv.getArgument(0);
            row.setId(1L);
            return row;
        });
        when(paymentSubscriptionService.upsertByTokenHash(any(), eq(USER_ID))).thenAnswer(inv -> {
            PaymentSubscriptionDomain row = inv.getArgument(0);
            row.setId(2L);
            return row;
        });
        when(vipSubscriptionService.findByPurchaseToken(token)).thenReturn(null);

        syncBiz.syncPurchase(BillingProviders.MOCK, token, USER_ID,
                SyncPurchaseContext.of(PlusEntitlementSupport.PRODUCT_YEARLY, null, null, true, null));

        verify(userEntitlementService).grantEntitlement(
                eq(USER_ID), eq("plus"), eq(PRODUCT_DB_ID), eq(1L), eq(2L),
                eq(PlusEntitlementSupport.SOURCE_MOCK), any(), eq(end), eq(USER_ID));
        verify(vipSubscriptionService).upsertSubscription(
                eq(USER_ID), eq(PlusEntitlementSupport.PRODUCT_YEARLY), eq(token), any(),
                isNull(), eq(false), eq(PlusEntitlementSupport.SOURCE_MOCK),
                any(), eq(end), eq(1), isNull(), eq(USER_ID));
        verify(userService).syncVipEntitlement(USER_ID, true, end, USER_ID);
        verify(paymentTransactionService).saveTx(any(), eq(USER_ID));
    }

    @Test
    void pendingDoesNotGrantEntitlement() {
        String token = "mock:plus_yearly:PENDING:abc123456789";
        LocalDateTime now = LocalDateTime.now();
        stubVerify(token, "pending", "pending", now, null, true, false, "PENDING");
        when(paymentPurchaseService.findByTokenHash(anyString())).thenReturn(null);
        when(paymentPurchaseService.upsertByTokenHash(any(), eq(USER_ID))).thenAnswer(inv -> {
            PaymentPurchaseDomain row = inv.getArgument(0);
            row.setId(1L);
            return row;
        });
        when(paymentSubscriptionService.upsertByTokenHash(any(), eq(USER_ID))).thenAnswer(inv -> {
            PaymentSubscriptionDomain row = inv.getArgument(0);
            row.setId(2L);
            return row;
        });
        when(vipSubscriptionService.findByPurchaseToken(token)).thenReturn(null);
        when(vipSubscriptionService.findLatestActiveForUser(USER_ID)).thenReturn(null);

        syncBiz.syncPurchase(BillingProviders.MOCK, token, USER_ID,
                SyncPurchaseContext.of(PlusEntitlementSupport.PRODUCT_YEARLY, null, null, null, null));

        verify(userEntitlementService, never()).grantEntitlement(
                anyLong(), anyString(), any(), any(), any(), anyString(), any(), any(), anyLong());
        verify(userService, never()).syncVipEntitlement(eq(USER_ID), eq(true), any(), anyLong());
        verify(vipSubscriptionService, never()).upsertSubscription(
                anyLong(), anyString(), anyString(), any(), any(), anyBoolean(),
                anyString(), any(), any(), any(Integer.class), any(), anyLong());
        verify(vipSubscriptionService, never()).markExpired(anyLong(), anyLong());
        verify(userEntitlementService).revokeEntitlementByCode(USER_ID, "plus", USER_ID);
        verify(userService).syncVipEntitlement(eq(USER_ID), eq(false), any(), eq(USER_ID));
    }

    @Test
    void purchasedThenPendingSameToken_entitledFalse() {
        String token = MockBillingProvider.generateToken(PlusEntitlementSupport.PRODUCT_YEARLY, "PURCHASED");
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime end = now.plusDays(365);
        stubVerify(token, "pending", "pending", now, null, true, false, "PENDING");
        when(paymentPurchaseService.findByTokenHash(anyString())).thenReturn(null);
        when(paymentPurchaseService.upsertByTokenHash(any(), eq(USER_ID))).thenAnswer(inv -> {
            PaymentPurchaseDomain row = inv.getArgument(0);
            row.setId(1L);
            return row;
        });
        when(paymentSubscriptionService.upsertByTokenHash(any(), eq(USER_ID))).thenAnswer(inv -> {
            PaymentSubscriptionDomain row = inv.getArgument(0);
            row.setId(2L);
            return row;
        });
        VipSubscriptionDomain existingActive = new VipSubscriptionDomain();
        existingActive.setId(50L);
        existingActive.setUserId(USER_ID);
        existingActive.setPurchaseToken(token);
        existingActive.setProductId(PlusEntitlementSupport.PRODUCT_YEARLY);
        existingActive.setStatus(1);
        existingActive.setEndAt(end);
        when(vipSubscriptionService.findByPurchaseToken(token)).thenReturn(existingActive);
        when(vipSubscriptionService.findLatestActiveForUser(USER_ID)).thenReturn(null);

        syncBiz.syncPurchase(BillingProviders.MOCK, token, USER_ID,
                SyncPurchaseContext.of(PlusEntitlementSupport.PRODUCT_YEARLY, null, null, null, null));

        verify(userEntitlementService, never()).grantEntitlement(
                anyLong(), anyString(), any(), any(), any(), anyString(), any(), any(), anyLong());
        verify(vipSubscriptionService).markExpired(50L, USER_ID);
        verify(vipSubscriptionService, never()).upsertSubscription(
                anyLong(), anyString(), anyString(), any(), any(), anyBoolean(),
                anyString(), any(), any(), any(Integer.class), any(), anyLong());
        verify(userEntitlementService).revokeEntitlementByCode(USER_ID, "plus", USER_ID);
        verify(userService).syncVipEntitlement(eq(USER_ID), eq(false), any(), eq(USER_ID));
    }

    @Test
    void cancelKeepsEntitlementWithAutoRenewFalse() {
        String token = "mock:plus_yearly:CANCEL:abc123456789";
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime end = now.plusDays(365);
        stubVerify(token, "purchased", "canceled", now, end, false, false, "CANCEL");
        when(paymentPurchaseService.findByTokenHash(anyString())).thenReturn(null);
        when(paymentPurchaseService.upsertByTokenHash(any(), eq(USER_ID))).thenAnswer(inv -> {
            PaymentPurchaseDomain row = inv.getArgument(0);
            row.setId(1L);
            return row;
        });
        when(paymentSubscriptionService.upsertByTokenHash(any(), eq(USER_ID))).thenAnswer(inv -> {
            PaymentSubscriptionDomain row = inv.getArgument(0);
            row.setId(2L);
            return row;
        });
        when(vipSubscriptionService.findByPurchaseToken(token)).thenReturn(null);

        syncBiz.syncPurchase(BillingProviders.MOCK, token, USER_ID,
                SyncPurchaseContext.of(PlusEntitlementSupport.PRODUCT_YEARLY, null, null, null, null));

        ArgumentCaptor<PaymentSubscriptionDomain> subCap = ArgumentCaptor.forClass(PaymentSubscriptionDomain.class);
        verify(paymentSubscriptionService).upsertByTokenHash(subCap.capture(), eq(USER_ID));
        assertFalse(Boolean.TRUE.equals(subCap.getValue().getAutoRenew()));
        assertEquals("canceled", subCap.getValue().getStatus());

        verify(userEntitlementService).grantEntitlement(
                eq(USER_ID), eq("plus"), any(), any(), any(), anyString(), any(), eq(end), eq(USER_ID));
        verify(userService).syncVipEntitlement(USER_ID, true, end, USER_ID);
        verify(userEntitlementService, never()).revokeEntitlementByCode(anyLong(), anyString(), anyLong());
    }

    @Test
    void refundRevokesEntitlement() {
        String token = "mock:plus_yearly:REFUND:abc123456789";
        LocalDateTime now = LocalDateTime.now();
        stubVerify(token, "refunded", "revoked", now, now, false, false, "REFUND");
        when(paymentPurchaseService.findByTokenHash(anyString())).thenReturn(null);
        when(paymentPurchaseService.upsertByTokenHash(any(), eq(USER_ID))).thenAnswer(inv -> {
            PaymentPurchaseDomain row = inv.getArgument(0);
            row.setId(1L);
            return row;
        });
        when(paymentSubscriptionService.upsertByTokenHash(any(), eq(USER_ID))).thenAnswer(inv -> {
            PaymentSubscriptionDomain row = inv.getArgument(0);
            row.setId(2L);
            return row;
        });
        when(vipSubscriptionService.findByPurchaseToken(token)).thenReturn(null);

        syncBiz.syncPurchase(BillingProviders.MOCK, token, USER_ID,
                SyncPurchaseContext.of(PlusEntitlementSupport.PRODUCT_YEARLY, null, null, null, null));

        verify(userEntitlementService).revokeEntitlementByCode(USER_ID, "plus", USER_ID);
        verify(userService).syncVipEntitlement(eq(USER_ID), eq(false), any(), eq(USER_ID));
    }

    @Test
    void expireRevokesEntitlement() {
        String token = "mock:plus_yearly:EXPIRE:abc123456789";
        LocalDateTime now = LocalDateTime.now();
        stubVerify(token, "purchased", "expired", now.minusDays(365), now.minusMinutes(1), false, false, "EXPIRE");
        when(paymentPurchaseService.findByTokenHash(anyString())).thenReturn(null);
        when(paymentPurchaseService.upsertByTokenHash(any(), eq(USER_ID))).thenAnswer(inv -> {
            PaymentPurchaseDomain row = inv.getArgument(0);
            row.setId(1L);
            return row;
        });
        when(paymentSubscriptionService.upsertByTokenHash(any(), eq(USER_ID))).thenAnswer(inv -> {
            PaymentSubscriptionDomain row = inv.getArgument(0);
            row.setId(2L);
            return row;
        });
        when(vipSubscriptionService.findByPurchaseToken(token)).thenReturn(null);

        syncBiz.syncPurchase(BillingProviders.MOCK, token, USER_ID,
                SyncPurchaseContext.of(PlusEntitlementSupport.PRODUCT_YEARLY, null, null, null, null));

        verify(userEntitlementService).revokeEntitlementByCode(USER_ID, "plus", USER_ID);
        verify(userService).syncVipEntitlement(eq(USER_ID), eq(false), any(), eq(USER_ID));
    }

    @Test
    void idempotentSecondCallUsesExistingPurchase() {
        String token = MockBillingProvider.generateToken(PlusEntitlementSupport.PRODUCT_YEARLY, "PURCHASED");
        String hash = PurchaseTokenHasher.hashToken(token);
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime end = now.plusDays(365);
        stubVerify(token, "purchased", "active", now, end, true, false, "PURCHASED");

        PaymentPurchaseDomain existing = new PaymentPurchaseDomain();
        existing.setId(9L);
        existing.setUserId(USER_ID);
        existing.setPurchaseTokenHash(hash);
        when(paymentPurchaseService.findByTokenHash(hash)).thenReturn(existing);
        when(paymentPurchaseService.upsertByTokenHash(any(), eq(USER_ID))).thenReturn(existing);
        when(paymentSubscriptionService.upsertByTokenHash(any(), eq(USER_ID))).thenAnswer(inv -> {
            PaymentSubscriptionDomain row = inv.getArgument(0);
            row.setId(2L);
            return row;
        });
        when(vipSubscriptionService.findByPurchaseToken(token)).thenReturn(null);

        syncBiz.syncPurchase(BillingProviders.MOCK, token, USER_ID,
                SyncPurchaseContext.of(PlusEntitlementSupport.PRODUCT_YEARLY, null, null, null, null));
        syncBiz.syncPurchase(BillingProviders.MOCK, token, USER_ID,
                SyncPurchaseContext.of(PlusEntitlementSupport.PRODUCT_YEARLY, null, null, null, null));

        verify(paymentPurchaseService, times(2)).upsertByTokenHash(any(), eq(USER_ID));
        verify(userService, times(2)).syncVipEntitlement(USER_ID, true, end, USER_ID);
    }

    @Test
    void tokenBoundOtherUserThrows() {
        String token = "mock:plus_yearly:PURCHASED:abc123456789";
        String hash = PurchaseTokenHasher.hashToken(token);
        LocalDateTime now = LocalDateTime.now();
        stubVerify(token, "purchased", "active", now, now.plusDays(365), true, false, "PURCHASED");

        PaymentPurchaseDomain existing = new PaymentPurchaseDomain();
        existing.setId(9L);
        existing.setUserId(999L);
        existing.setPurchaseTokenHash(hash);
        when(paymentPurchaseService.findByTokenHash(hash)).thenReturn(existing);

        BusinessException ex = assertThrows(BusinessException.class, () ->
                syncBiz.syncPurchase(BillingProviders.MOCK, token, USER_ID,
                        SyncPurchaseContext.of(PlusEntitlementSupport.PRODUCT_YEARLY, null, null, null, null)));
        assertTrue(ex.getMessage().contains("app.error.billing.tokenBoundOtherUser"));
        verify(userEntitlementService, never()).grantEntitlement(
                anyLong(), anyString(), any(), any(), any(), anyString(), any(), any(), anyLong());
    }

    @Test
    void legacyVipTokenBoundOtherUserThrows() {
        String token = "play-token-abcdefgh";
        LocalDateTime now = LocalDateTime.now();
        when(billingProvider.verifyPurchase(any())).thenReturn(new VerifiedPurchase(
                BillingProviders.GOOGLE_PLAY, token, "plus_monthly",
                "purchased", "active", now, now.plusDays(30), true, false, null, "sandbox", null, null));
        when(paymentPurchaseService.findByTokenHash(anyString())).thenReturn(null);
        VipSubscriptionDomain legacy = new VipSubscriptionDomain();
        legacy.setUserId(777L);
        legacy.setPurchaseToken(token);
        when(vipSubscriptionService.findByPurchaseToken(token)).thenReturn(legacy);

        BusinessException ex = assertThrows(BusinessException.class, () ->
                syncBiz.syncPurchase(BillingProviders.GOOGLE_PLAY, token, USER_ID,
                        SyncPurchaseContext.of("plus_monthly", null, null, null, null)));
        assertTrue(ex.getMessage().contains("app.error.billing.tokenBoundOtherUser"));
    }

    private void stubVerify(
            String token,
            String purchaseStatus,
            String subStatus,
            LocalDateTime start,
            LocalDateTime end,
            boolean autoRenew,
            boolean trial,
            String scenario) {
        when(billingProvider.verifyPurchase(any(VerifyPurchaseCommand.class))).thenReturn(new VerifiedPurchase(
                BillingProviders.MOCK,
                token,
                PlusEntitlementSupport.PRODUCT_YEARLY,
                purchaseStatus,
                subStatus,
                start,
                end,
                autoRenew,
                trial,
                "order-1",
                "sandbox",
                null,
                scenario));
    }
}
