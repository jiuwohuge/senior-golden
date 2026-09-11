package cn.nine.pros.post.biz.billing;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.pros.post.biz.billing.model.ParsedNotification;
import cn.nine.pros.post.biz.billing.model.VerifiedPurchase;
import cn.nine.pros.post.biz.billing.model.VerifyPurchaseCommand;
import cn.nine.pros.post.biz.config.BillingProperties;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.biz.support.PlusEntitlementSupport;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.core.env.Environment;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.when;

/**
 * {@link MockBillingProvider} token 解析与场景单元测试。
 */
@ExtendWith(MockitoExtension.class)
class MockBillingProviderTest {

    @Mock
    private AppMessages appMessages;

    @Mock
    private Environment environment;

    private BillingProperties billingProperties;
    private MockBillingProvider provider;

    @BeforeEach
    void setUp() {
        billingProperties = new BillingProperties();
        billingProperties.setMockEnabled(true);
        lenient().when(appMessages.get(anyString())).thenAnswer(inv -> inv.getArgument(0));
        lenient().when(environment.getActiveProfiles()).thenReturn(new String[]{"local"});
        provider = new MockBillingProvider(billingProperties, environment, appMessages);
    }

    @Test
    void parsePurchasedToken() {
        String token = MockBillingProvider.generateToken(PlusEntitlementSupport.PRODUCT_MONTHLY, "PURCHASED");
        VerifiedPurchase verified = provider.verifyPurchase(new VerifyPurchaseCommand(
                1L, token, PlusEntitlementSupport.PRODUCT_MONTHLY, null, null, true, null, null));

        assertEquals(BillingProviders.MOCK, verified.provider());
        assertEquals("purchased", verified.purchaseStatus());
        assertEquals("active", verified.subscriptionStatus());
        assertTrue(verified.autoRenew());
        assertNotNull(verified.periodEnd());
        assertEquals(PlusEntitlementSupport.PRODUCT_MONTHLY, verified.storeProductId());
    }

    @Test
    void pendingScenario() {
        String token = "mock:plus_yearly:PENDING:abc123def456";
        VerifiedPurchase verified = provider.verifyPurchase(new VerifyPurchaseCommand(
                1L, token, null, null, null, null, null, null));

        assertEquals("pending", verified.purchaseStatus());
        assertEquals("pending", verified.subscriptionStatus());
    }

    @Test
    void cancelKeepsPeriodEndAndDisablesAutoRenew() {
        String token = "mock:plus_yearly:CANCEL:abc123def456";
        VerifiedPurchase verified = provider.verifyPurchase(new VerifyPurchaseCommand(
                1L, token, null, null, null, null, null, null));

        assertEquals("canceled", verified.subscriptionStatus());
        assertFalse(verified.autoRenew());
        assertNotNull(verified.periodEnd());
    }

    @Test
    void refundRevokes() {
        String token = "mock:plus_monthly:REFUND:abc123def456";
        VerifiedPurchase verified = provider.verifyPurchase(new VerifyPurchaseCommand(
                1L, token, null, null, null, null, null, null));

        assertEquals("refunded", verified.purchaseStatus());
        assertEquals("revoked", verified.subscriptionStatus());
    }

    @Test
    void invalidTokenRejected() {
        assertThrows(BusinessException.class, () ->
                provider.verifyPurchase(new VerifyPurchaseCommand(
                        1L, "not-mock-token", "plus_yearly", null, null, null, null, null)));
    }

    @Test
    void mockDisabledThrows() {
        billingProperties.setMockEnabled(false);
        String token = MockBillingProvider.generateToken("plus_yearly", "PURCHASED");
        BusinessException ex = assertThrows(BusinessException.class, () ->
                provider.verifyPurchase(new VerifyPurchaseCommand(
                        1L, token, "plus_yearly", null, null, null, null, null)));
        assertTrue(ex.getMessage().contains("app.error.billing.mockDisabled"));
    }

    @Test
    void generateTokenFormat() {
        String token = MockBillingProvider.generateToken("plus_yearly", "RENEW");
        assertTrue(token.startsWith("mock:plus_yearly:RENEW:"));
    }

    @Test
    void parseNotificationRenewedMapsToRenew() {
        String token = MockBillingProvider.generateToken(PlusEntitlementSupport.PRODUCT_YEARLY, "PURCHASED");
        String json = """
                {"messageId":"msg-1","purchaseToken":"%s","notificationType":"SUBSCRIPTION_RENEWED"}
                """.formatted(token);
        ParsedNotification parsed = provider.parseNotification(json);

        assertEquals(BillingProviders.MOCK, parsed.provider());
        assertEquals("RENEWED", parsed.eventType());
        assertEquals(MockBillingProvider.SCENARIO_RENEW, parsed.scenario());
        assertEquals("msg-1", parsed.messageId());
        assertEquals(token, parsed.purchaseToken());
    }

    @Test
    void parseNotificationTypeMappings() {
        assertEquals(MockBillingProvider.SCENARIO_CANCEL,
                MockBillingProvider.mapNotificationTypeToScenario("SUBSCRIPTION_CANCELED"));
        assertEquals(MockBillingProvider.SCENARIO_EXPIRE,
                MockBillingProvider.mapNotificationTypeToScenario("EXPIRED"));
        assertEquals(MockBillingProvider.SCENARIO_REVOKE,
                MockBillingProvider.mapNotificationTypeToScenario("REVOKED"));
        assertEquals(MockBillingProvider.SCENARIO_REFUND,
                MockBillingProvider.mapNotificationTypeToScenario("SUBSCRIPTION_REFUND"));
        assertEquals(MockBillingProvider.SCENARIO_PURCHASED,
                MockBillingProvider.mapNotificationTypeToScenario("PURCHASED"));
        assertEquals(MockBillingProvider.SCENARIO_PENDING,
                MockBillingProvider.mapNotificationTypeToScenario("ON_HOLD"));
        assertEquals(MockBillingProvider.SCENARIO_RENEW,
                MockBillingProvider.mapNotificationTypeToScenario("RECOVERED"));
    }

    @Test
    void parseNotificationInvalidPayloadThrows() {
        assertThrows(BusinessException.class, () -> provider.parseNotification("{"));
        assertThrows(BusinessException.class, () -> provider.parseNotification("""
                {"messageId":"","purchaseToken":"t","notificationType":"RENEWED"}
                """));
        assertThrows(BusinessException.class, () -> provider.parseNotification("""
                {"messageId":"m","purchaseToken":"t","notificationType":"UNKNOWN_TYPE"}
                """));
    }

    @Test
    void parseNotificationMockDisabledThrows() {
        billingProperties.setMockEnabled(false);
        assertThrows(BusinessException.class, () -> provider.parseNotification("""
                {"messageId":"m","purchaseToken":"t","notificationType":"RENEWED"}
                """));
    }

    @Test
    void apiScenarioOverridesTokenEmbeddedScenario() {
        // 同 token 推进生命周期：body scenario=CANCEL 覆盖 token 内 PURCHASED
        String token = "mock:plus_yearly:PURCHASED:stableuuid001";
        VerifiedPurchase verified = provider.verifyPurchase(new VerifyPurchaseCommand(
                1L, token, null, null, null, null, null, "CANCEL"));

        assertEquals("canceled", verified.subscriptionStatus());
        assertFalse(verified.autoRenew());
        assertEquals("CANCEL", verified.scenario());
    }
}
