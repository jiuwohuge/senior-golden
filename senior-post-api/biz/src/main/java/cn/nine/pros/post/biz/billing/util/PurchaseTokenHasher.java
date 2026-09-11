package cn.nine.pros.post.biz.billing.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;

/**
 * purchaseToken SHA-256 与截断预览（勿记录完整 token）。
 */
public final class PurchaseTokenHasher {

    private PurchaseTokenHasher() {
    }

    /** UTF-8 SHA-256 hex（小写）。 */
    public static String hashToken(String token) {
        if (token == null) {
            return hashBytes(new byte[0]);
        }
        return hashBytes(token.getBytes(StandardCharsets.UTF_8));
    }

    /** first4…last4；过短则 ***。 */
    public static String preview(String token) {
        if (token == null || token.isEmpty()) {
            return "";
        }
        if (token.length() <= 8) {
            return "***";
        }
        return token.substring(0, 4) + "…" + token.substring(token.length() - 4);
    }

    private static String hashBytes(byte[] bytes) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(digest.digest(bytes));
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 not available", e);
        }
    }
}
