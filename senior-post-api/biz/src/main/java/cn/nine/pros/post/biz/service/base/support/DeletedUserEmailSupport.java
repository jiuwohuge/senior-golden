package cn.nine.pros.post.biz.service.base.support;

import java.time.LocalDateTime;
import java.time.ZoneId;

/**
 * 账号注销/删除时释放 {@code bu_user.email} UNIQUE，便于同邮箱重新注册。
 */
public final class DeletedUserEmailSupport {

    private static final int EMAIL_MAX_LEN = 255;
    private static final String MARKER = "+deleted.";

    private DeletedUserEmailSupport() {
    }

    /**
     * 将登录邮箱改写为归档形态，例如 {@code user+deleted.1716000000000@example.com}。
     */
    public static String archive(String email, LocalDateTime at) {
        if (email == null || email.isBlank()) {
            return email;
        }
        String normalized = email.trim().toLowerCase();
        if (normalized.contains(MARKER)) {
            return normalized;
        }
        long ts = at.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli();
        String suffix = MARKER + ts;
        int atIdx = normalized.lastIndexOf('@');
        String archived;
        if (atIdx > 0) {
            String local = normalized.substring(0, atIdx);
            String domain = normalized.substring(atIdx + 1);
            archived = local + suffix + "@" + domain;
        } else {
            archived = normalized + suffix;
        }
        return truncate(archived);
    }

    private static String truncate(String value) {
        if (value.length() <= EMAIL_MAX_LEN) {
            return value;
        }
        return value.substring(0, EMAIL_MAX_LEN);
    }
}
