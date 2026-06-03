package cn.nine.pros.post.client.common.enums;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * 时光信状态，对应 {@code bu_time_letter.status}。
 */
@Getter
@RequiredArgsConstructor
public enum TimeLetterStatus {
    DRAFT(1),
    PENDING(2),
    DELIVERED(3),
    READ(4),
    CANCELLED(5),
    FAILED(6);

    private final int code;

    public static TimeLetterStatus fromCode(int code) {
        for (TimeLetterStatus v : values()) {
            if (v.code == code) {
                return v;
            }
        }
        return null;
    }
}
