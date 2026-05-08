package cn.nine.pros.post.biz.service.app;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.config.SeniorPostAuthProperties;
import cn.nine.pros.post.biz.mapper.PasswordResetTokenMapper;
import cn.nine.pros.post.biz.model.domain.PasswordResetTokenDomain;
import cn.nine.pros.post.biz.service.app.support.PasswordResetHasher;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.model.db.UserDTO;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class PasswordResetServiceTest {

    @Mock
    private UserService userService;
    @Mock
    private PasswordResetTokenMapper passwordResetTokenMapper;
    @Mock
    private PasswordEncoder passwordEncoder;
    @Mock
    private PasswordResetMailNotifier passwordResetMailNotifier;

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
                passwordResetTokenMapper,
                passwordEncoder,
                passwordResetMailNotifier,
                authProperties);
    }

    @Test
    void requestForgotPassword_unknownEmail_doesNotInsert() {
        when(userService.findByEmail("x@y.com")).thenReturn(null);
        passwordResetService.requestForgotPassword("x@y.com");
        verify(passwordResetTokenMapper, never()).insert(any(PasswordResetTokenDomain.class));
        verify(passwordResetMailNotifier, never()).sendSixDigitCode(any(), any(), anyInt());
    }

    @Test
    void completeReset_success_updatesPasswordAndMarksUsed() {
        UserDTO user = new UserDTO();
        user.setId(9L);
        user.setEmail("u@example.com");
        user.setStatus(1);
        when(userService.findByEmail("u@example.com")).thenReturn(user);

        String code = "384920";
        String hash = PasswordResetHasher.hexHash("test-pepper", 9L, code);
        PasswordResetTokenDomain tok = new PasswordResetTokenDomain();
        tok.setId(100L);
        tok.setUserId(9L);
        tok.setCodeHash(hash);
        tok.setExpiresAt(LocalDateTime.now().plusMinutes(10));
        when(passwordResetTokenMapper.selectList(any())).thenReturn(List.of(tok));
        when(passwordEncoder.encode("newpass123")).thenReturn("ENC");

        passwordResetService.completeReset("u@example.com", code, "newpass123");

        verify(userService).update(any());
        ArgumentCaptor<PasswordResetTokenDomain> cap = ArgumentCaptor.forClass(PasswordResetTokenDomain.class);
        verify(passwordResetTokenMapper).updateById(cap.capture());
        assertThat(cap.getValue().getUsedAt()).isNotNull();
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
        when(passwordResetTokenMapper.selectList(any())).thenReturn(List.of(tok));

        assertThatThrownBy(() -> passwordResetService.completeReset("u@example.com", "222222", "newpass123"))
                .isInstanceOf(BadRequestException.class)
                .hasMessageContaining("验证码");
    }
}
