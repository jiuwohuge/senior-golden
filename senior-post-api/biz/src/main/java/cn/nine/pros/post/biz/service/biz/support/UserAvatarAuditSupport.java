package cn.nine.pros.post.biz.service.biz.support;

import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.client.model.db.UserDTO;
import org.springframework.util.StringUtils;

/**
 * 用户头像审核可见性：对外仅展示「已通过」；本人可见待审预览，驳回不展示图片。
 */
public final class UserAvatarAuditSupport {

    public static final int PENDING = 0;
    public static final int APPROVED = 1;
    public static final int REJECTED = 2;

    private UserAvatarAuditSupport() {}

    public static int statusOf(UserDTO dto) {
        if (dto == null) {
            return APPROVED;
        }
        return normalizeStatus(dto.getAvatarAuditStatus(), hasStoredAvatar(dto));
    }

    public static int statusOf(UserDomain domain) {
        if (domain == null) {
            return APPROVED;
        }
        return normalizeStatus(domain.getAvatarAuditStatus(), hasStoredAvatar(domain));
    }

    private static int normalizeStatus(Integer raw, boolean hasAvatar) {
        if (!hasAvatar) {
            return APPROVED;
        }
        if (raw == null) {
            return APPROVED;
        }
        return raw;
    }

    public static boolean hasStoredAvatar(UserDTO dto) {
        return dto != null && StringUtils.hasText(dto.getAvatarUrl());
    }

    public static boolean hasStoredAvatar(UserDomain domain) {
        return domain != null && StringUtils.hasText(domain.getAvatarUrl());
    }

    /** 他人可见：仅审核通过的头像存储引用。 */
    public static String publicStoredRef(UserDTO dto) {
        if (!hasStoredAvatar(dto) || statusOf(dto) != APPROVED) {
            return null;
        }
        return dto.getAvatarUrl().trim();
    }

    public static String publicStoredRef(UserDomain domain) {
        if (!hasStoredAvatar(domain) || statusOf(domain) != APPROVED) {
            return null;
        }
        return domain.getAvatarUrl().trim();
    }

    /** 本人可见：待审可预览；驳回不返回图片引用。 */
    public static String ownerVisibleStoredRef(UserDTO dto) {
        if (!hasStoredAvatar(dto)) {
            return null;
        }
        int st = statusOf(dto);
        if (st == REJECTED) {
            return null;
        }
        return dto.getAvatarUrl().trim();
    }
}
