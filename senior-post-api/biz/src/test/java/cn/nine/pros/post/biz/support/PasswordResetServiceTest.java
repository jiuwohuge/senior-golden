package cn.nine.pros.post.biz.support;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.config.SeniorPostAuthProperties;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.base.PasswordResetTokenService;
import cn.nine.pros.post.biz.model.domain.PasswordResetTokenDomain;
import cn.nine.pros.post.biz.service.biz.PasswordResetService;
import cn.nine.pros.post.biz.service.base.MailOutboxService;
import cn.nine.pros.post.biz.service.biz.support.PasswordResetHasher;
import cn.nine.pros.post.biz.service.base.UserIdentityService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.model.db.UserDTO;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class PasswordResetServiceTest {

    @Mock
    private UserService userService;
    @Mock
    private UserIdentityService userIdentityService;
    @Mock
    private PasswordResetTokenService passwordResetTokenService;
    @Mock
    private PasswordEncoder passwordEncoder;
    @Mock
    private MailOutboxService mailOutboxService;
    @Mock
    private AppMessages appMessages;

    private final SeniorPostAuthProperties authProperties = new SeniorPostAuthProperties();

    private PasswordResetService passwordResetService;

    @BeforeEach
    void setProps() {
        authProperties.setPasswordResetPepper("test-pepper");
        authProperties.setPasswordResetExpireMinutes(15);
        authProperties.setPasswordResetMaxRequestsPerHour(5);
        authProperties.setPasswordResetMinIntervalSeconds(0);
        passwordResetService = new PasswordResetService(
                userService,
                userIdentityService,
                passwordResetTokenService,
                passwordEncoder,
                mailOutboxService,
                authProperties,
                appMessages);
    }

    @Test
    void requestForgotPassword_unknownEmail_doesNotInsert() {
        when(userService.findByEmail("x@y.com")).thenReturn(null);
        passwordResetService.requestForgotPassword("x@y.com");
        verify(passwordResetTokenService, never()).insert(any(PasswordResetTokenDomain.class));
        verify(mailOutboxService, never()).enqueuePasswordReset(anyString(), anyString(), anyString(), anyInt());
    }

    @Test
    void requestForgotPassword_activeUser_enqueuesOutbox() {
        UserDTO u = new UserDTO();
        u.setId(1L);
        u.setStatus(1);
        when(userService.findByEmail("a@b.com")).thenReturn(u);
        when(passwordResetTokenService.selectCount(any())).thenReturn(0L);
        when(passwordResetTokenService.selectOne(any())).thenReturn(null);

        passwordResetService.requestForgotPassword("a@b.com");

        verify(passwordResetTokenService).insert(any(PasswordResetTokenDomain.class));
        verify(mailOutboxService).enqueuePasswordReset(eq("a@b.com"), anyString(), anyString(), eq(15));
    }

    @Test
    void completeReset_wrongCode_throws() {
        UserDTO user = new UserDTO();
        user.setId(9L);
        user.setStatus(1);
        when(userService.findByEmail("u@example.com")).thenReturn(user);
        PasswordResetTokenDomain tok = new PasswordResetTokenDomain();
        tok.setCodeHash(PasswordResetHasher.hexHash("test-pepper", 9L, "111111"));
        tok.setExpiresAt(LocalDateTime.now().plusMinutes(10));
        when(passwordResetTokenService.selectList(any())).thenReturn(List.of(tok));
        when(appMessages.get("app.error.code.invalid")).thenReturn("Invalid or expired verification code.");

        assertThatThrownBy(() -> passwordResetService.completeReset("u@example.com", "222222", "newpass123"))
                .isInstanceOf(BadRequestException.class)
                .hasMessageContaining("verification");
    }
}
