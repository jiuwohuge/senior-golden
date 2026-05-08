package cn.nine.pros.post.biz.service.app.support;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class PasswordResetHasherTest {

    @Test
    void hexHash_stableForSameInputs() {
        String a = PasswordResetHasher.hexHash("p", 42L, "123456");
        String b = PasswordResetHasher.hexHash("p", 42L, "123456");
        assertThat(a).hasSize(64).isEqualTo(b);
    }

    @Test
    void hexHash_trimsCode() {
        String a = PasswordResetHasher.hexHash("p", 1L, "123456");
        String b = PasswordResetHasher.hexHash("p", 1L, "  123456  ");
        assertThat(a).isEqualTo(b);
    }
}
