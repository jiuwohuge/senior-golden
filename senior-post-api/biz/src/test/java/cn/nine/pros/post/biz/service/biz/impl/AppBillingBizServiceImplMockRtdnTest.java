package cn.nine.pros.post.biz.service.biz.impl;

import cn.nine.pros.post.biz.billing.BillingProvider;
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
import cn.nine.pros.post.biz.service.base.AiAssistUsageService;
import cn.nine.pros.post.biz.service.base.PaymentPurchaseService;
import cn.nine.pros.post.biz.service.base.PaymentWebhookEventService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.biz.service.base.VipSubscriptionService;
import cn.nine.pros.post.biz.service.biz.PurchaseSyncBizService;
import cn.nine.pros.post.biz.service.biz.SyncPurchaseContext;
import cn.nine.pros.post.biz.service.biz.support.PlusEntitlementSupport;
import cn.nine.pros.post.client.model.input.app.BillingMockRtdnInDto;
import cn.nine.pros.post.client.model.out.SubscriptionStatusVO;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.core.env.Environment;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * {@link AppBillingBizServiceImpl#mockReplayRtdn} 单元测试。
 */
@ExtendWith(MockitoExtension.class)
class AppBillingBizServiceImplMockRtdnTest {

    private static final long USER_ID = 42L;

    @Mock
    private PlusEntitlementSupport plusEntitlementSupport;
    @Mock
    private VipSubscriptionService vipSubscriptionService;
    @Mock
    private AiAssistUsageService aiAssistUsageService;
    @Mock
    private UserService userService;
    @Mock
    private PlusBillingProperties plusBillingProperties;
    @Mock
    private Environment environment;
    @Mock
    private PurchaseSyncBizService purchaseSyncBizService;
    @Mock
    private PaymentWebhookEventService paymentWebhookEventService;
    @Mock
    private PaymentPurchaseService paymentPurchaseService;
    @Mock
    private BillingProviderRegistry billingProviderRegistry;
    @Mock
    private BillingProvider mockBillingProvider;
    @Mock
    private AppMessages appMessages;

    private BillingProperties billingProperties;
    private AppBillingBizServiceImpl bizService;

    @BeforeEach
    void setUp() {
        billingProperties = new BillingProperties();
        billingProperties.setMockEnabled(true);
        lenient().when(appMessages.get(anyString())).thenAnswer(inv -> inv.getArgument(0));
        lenient().when(environment.getActiveProfiles()).thenReturn(new String[]{"local"});
        lenient().when(plusBillingProperties.getPlayPackageName()).thenReturn("com.example.app");
        lenient().when(billingProviderRegistry.getRequired(BillingProviders.MOCK)).thenReturn(mockBillingProvider);
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

        bizService = new AppBillingBizServiceImpl(
                plusEntitlementSupport,
                vipSubscriptionService,
                aiAssistUsageService,
                userService,
                plusBillingProperties,
                billingProperties,
                environment,
                purchaseSyncBizService,
                paymentWebhookEventService,
                paymentPurchaseService,
                billingProviderRegistry,
                appMessages);
    }

    @Test
    void idempotentSkipsSyncPurchase() {
        String token = MockBillingProvider.generateToken(PlusEntitlementSupport.PRODUCT_YEARLY, "PURCHASED");
        BillingMockRtdnInDto body = rtdnBody("msg-dup", token, "SUBSCRIPTION_RENEWED");

        PaymentPurchaseDomain purchase = new PaymentPurchaseDomain();
        purchase.setUserId(USER_ID);
        when(paymentPurchaseService.findByTokenHash(PurchaseTokenHasher.hashToken(token))).thenReturn(purchase);

        when(mockBillingProvider.parseNotification(anyString())).thenReturn(
                new ParsedNotification(
                        BillingProviders.MOCK, "RENEWED", token, PlusEntitlementSupport.PRODUCT_YEARLY,
                        "{}", "msg-dup", MockBillingProvider.SCENARIO_RENEW));

        PaymentWebhookEventDomain existing = new PaymentWebhookEventDomain();
        existing.setId(1L);
        existing.setProcessStatus("processed");
        when(paymentWebhookEventService.insertIfAbsent(any(PaymentWebhookEventDomain.class), eq(USER_ID)))
                .thenReturn(existing);

        SubscriptionStatusVO status = bizService.mockReplayRtdn(USER_ID, body);

        assertNotNull(status);
        assertEquals(PlusEntitlementSupport.STATE_ACTIVE, status.getState());
        verify(purchaseSyncBizService, never()).syncPurchase(anyString(), anyString(), anyLong(), any());
    }

    @Test
    void happyPathCallsSyncPurchaseOnce() {
        String token = MockBillingProvider.generateToken(PlusEntitlementSupport.PRODUCT_YEARLY, "PURCHASED");
        BillingMockRtdnInDto body = rtdnBody("msg-new", token, "SUBSCRIPTION_CANCELED");

        PaymentPurchaseDomain purchase = new PaymentPurchaseDomain();
        purchase.setUserId(USER_ID);
        when(paymentPurchaseService.findByTokenHash(PurchaseTokenHasher.hashToken(token))).thenReturn(purchase);

        when(mockBillingProvider.parseNotification(anyString())).thenReturn(
                new ParsedNotification(
                        BillingProviders.MOCK, "CANCELED", token, PlusEntitlementSupport.PRODUCT_YEARLY,
                        "{}", "msg-new", MockBillingProvider.SCENARIO_CANCEL));

        PaymentWebhookEventDomain row = new PaymentWebhookEventDomain();
        row.setId(2L);
        row.setProcessStatus("received");
        when(paymentWebhookEventService.insertIfAbsent(any(PaymentWebhookEventDomain.class), eq(USER_ID)))
                .thenReturn(row);

        SubscriptionStatusVO expected = SubscriptionStatusVO.builder()
                .state(PlusEntitlementSupport.STATE_ACTIVE)
                .productId(PlusEntitlementSupport.PRODUCT_YEARLY)
                .entitled(true)
                .build();
        when(purchaseSyncBizService.syncPurchase(
                eq(BillingProviders.MOCK), eq(token), eq(USER_ID), any(SyncPurchaseContext.class)))
                .thenReturn(expected);

        SubscriptionStatusVO status = bizService.mockReplayRtdn(USER_ID, body);

        assertEquals(expected, status);
        ArgumentCaptor<SyncPurchaseContext> ctxCaptor = ArgumentCaptor.forClass(SyncPurchaseContext.class);
        verify(purchaseSyncBizService).syncPurchase(
                eq(BillingProviders.MOCK), eq(token), eq(USER_ID), ctxCaptor.capture());
        assertEquals(MockBillingProvider.SCENARIO_CANCEL, ctxCaptor.getValue().scenario());
        verify(paymentWebhookEventService).updateById(row);
        assertEquals("processed", row.getProcessStatus());
    }

    private static BillingMockRtdnInDto rtdnBody(String messageId, String token, String notificationType) {
        BillingMockRtdnInDto body = new BillingMockRtdnInDto();
        body.setMessageId(messageId);
        body.setPurchaseToken(token);
        body.setNotificationType(notificationType);
        return body;
    }
}
