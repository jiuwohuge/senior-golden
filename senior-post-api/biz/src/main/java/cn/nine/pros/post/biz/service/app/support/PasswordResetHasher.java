package cn.nine.pros.post.biz.service.app.support;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;

/**
 * 重置验证码哈希：服务端胡椒 + userId + 明文 code，避免仅依赖短验证码熵。
 */
public final class PasswordResetHasher {

    private PasswordResetHasher() {
    }

    public static String hexHash(String pepper, long userId, String code) {
        String payload = pepper + "\n" + userId + "\n" + code.trim();
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] digest = md.digest(payload.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }
}
