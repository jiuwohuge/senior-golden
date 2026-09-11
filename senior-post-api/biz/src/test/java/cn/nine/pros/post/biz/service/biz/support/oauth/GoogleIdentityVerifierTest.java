package cn.nine.pros.post.biz.service.biz.support.oauth;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.config.GoogleOAuthProperties;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.client.common.constant.AuthProvider;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.core.env.Environment;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.when;

/**
 * {@link GoogleIdentityVerifier} 本机 mock 与配置守卫单元测试（无 Spring 上下文）。
 */
@ExtendWith(MockitoExtension.class)
class GoogleIdentityVerifierTest {

    @Mock
    private AppMessages appMessages;

    @Mock
    private Environment environment;

    private GoogleOAuthProperties properties;
    private GoogleIdentityVerifier verifier;

    @BeforeEach
    void setUp() {
        properties = new GoogleOAuthProperties();
        lenient().when(appMessages.get(anyString())).thenAnswer(inv -> inv.getArgument(0));
        verifier = new GoogleIdentityVerifier(appMessages, properties, environment);
    }

    @Test
    void mockTokenAcceptedWhenEnabledAndLocalProfile() {
        properties.setMockEnabled(true);
        when(environment.getActiveProfiles()).thenReturn(new String[]{"local"});

        VerifiedExternalIdentity identity = verifier.verify("mock-google:sub-123:User@Example.COM");

        assertEquals(AuthProvider.GOOGLE, identity.provider());
        assertEquals("sub-123", identity.subject());
        assertEquals("user@example.com", identity.email());
    }

    @Test
    void mockTokenWithoutEmail() {
        properties.setMockEnabled(true);
        when(environment.getActiveProfiles()).thenReturn(new String[]{"local"});

        VerifiedExternalIdentity identity = verifier.verify("mock-google:only-sub");

        assertEquals("only-sub", identity.subject());
        assertNull(identity.email());
    }

    @Test
    void mockRejectedWhenMockDisabled() {
        properties.setMockEnabled(false);

        BadRequestException ex = assertThrows(
                BadRequestException.class,
                () -> verifier.verify("mock-google:sub-1"));
        assertTrue(ex.getMessage().contains("app.error.oauth.invalidToken"));
    }

    @Test
    void mockRejectedWhenProdProfile() {
        properties.setMockEnabled(true);
        when(environment.getActiveProfiles()).thenReturn(new String[]{"prod"});

        BadRequestException ex = assertThrows(
                BadRequestException.class,
                () -> verifier.verify("mock-google:sub-1:a@b.com"));
        assertTrue(ex.getMessage().contains("app.error.oauth.invalidToken"));
    }

    @Test
    void emptyAudiencesAndMockDisabledThrowsGoogleNotConfigured() {
        properties.setMockEnabled(false);

        BadRequestException ex = assertThrows(
                BadRequestException.class,
                () -> verifier.verify("not-a-real-jwt"));
        assertTrue(ex.getMessage().contains("app.error.oauth.googleNotConfigured"));
    }

    @Test
    void blankMockSubjectAfterPrefixIsInvalidToken() {
        properties.setMockEnabled(true);
        when(environment.getActiveProfiles()).thenReturn(new String[]{"local"});

        BadRequestException ex = assertThrows(
                BadRequestException.class,
                () -> verifier.verify("mock-google:"));
        assertTrue(ex.getMessage().contains("app.error.oauth.invalidToken"));
    }
}
