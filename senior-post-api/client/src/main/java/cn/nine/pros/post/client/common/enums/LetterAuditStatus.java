package cn.nine.pros.post.client.common.enums;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * 信件审核状态（DB 列 {@code bu_letter.audit_status}），与投递 {@code status} 并行。
 */
@Getter
@RequiredArgsConstructor
public enum LetterAuditStatus {
    PENDING_REVIEW(0),
    APPROVED(1),
    REJECTED(2);

    private final int code;

    public static LetterAuditStatus fromCode(Integer code) {
        if (code == null) {
            return null;
        }
        for (LetterAuditStatus v : values()) {
            if (v.code == code) {
                return v;
            }
        }
        return null;
    }
}
