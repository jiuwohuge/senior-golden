package cn.nine.pros.post.biz.service.base.support;

import java.time.LocalDateTime;
import java.time.ZoneId;

/**
 * 用户删除/注销时改写带 UNIQUE 约束的标识，释放槽位以便同邮箱、同 openId 等可再次注册/绑定。
 * <p>
 * 约定：追加 {@value #MARKER}{epochMillis}；已含 marker 的值幂等返回。
 */
public final class DeletedUniqueKeySupport {

    public static final String MARKER = "+deleted.";

    private static final int MAX_LEN = 255;

    private DeletedUniqueKeySupport() {
    }

    /**
     * 邮箱类唯一键（{@code bu_user.email} 或 identity {@code provider=email} 的 {@code provider_uid}）。
     * 例：{@code user@example.com} → {@code user+deleted.1716000000000@example.com}
     */
    public static String archiveEmail(String email, LocalDateTime at) {
        if (email == null || email.isBlank()) {
            return email;
        }
        String normalized = email.trim().toLowerCase();
        if (normalized.contains(MARKER)) {
            return truncate(normalized);
        }
        String suffix = MARKER + epochMillis(at);
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

    /**
     * 非邮箱类唯一键（如 Google/Apple {@code provider_uid}、设备号等无 {@code @} 的标识）。
     * 例：{@code 103547891234567890123} → {@code 103547891234567890123+deleted.1716000000000}
     */
    public static String archiveProviderUid(String providerUid, LocalDateTime at) {
        if (providerUid == null || providerUid.isBlank()) {
            return providerUid;
        }
        String normalized = providerUid.trim();
        if (normalized.contains(MARKER)) {
            return truncate(normalized);
        }
        return truncate(normalized + MARKER + epochMillis(at));
    }

    private static long epochMillis(LocalDateTime at) {
        return at.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli();
    }

    private static String truncate(String value) {
        if (value.length() <= MAX_LEN) {
            return value;
        }
        return value.substring(0, MAX_LEN);
    }
}
