package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.service.base.UserService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class StampAccountServiceImplTest {

    @Mock
    private UserService userService;

    @InjectMocks
    private StampAccountServiceImpl stampAccountService;

    @Test
    void tryDecrement_nonPositiveDelta_throws() {
        assertThatThrownBy(() -> stampAccountService.tryDecrementBalance(1L, 5, 0, LocalDateTime.now(), 1L))
                .isInstanceOf(IllegalArgumentException.class);
        verify(userService, never()).update(any());
    }

    @Test
    void tryDecrement_expectedLessThanDelta_returnsFalseWithoutUpdate() {
        assertThat(stampAccountService.tryDecrementBalance(1L, 0, 1, LocalDateTime.now(), 1L)).isFalse();
        verify(userService, never()).update(any());
    }

    @Test
    void tryDecrement_delegatesToUserService() {
        when(userService.update(any())).thenReturn(true);
        assertThat(stampAccountService.tryDecrementBalance(9L, 10, 3, LocalDateTime.now(), 9L)).isTrue();
        verify(userService).update(any());
    }
}
