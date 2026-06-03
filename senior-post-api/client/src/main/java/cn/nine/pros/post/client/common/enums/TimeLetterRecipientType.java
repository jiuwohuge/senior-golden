package cn.nine.pros.post.client.common.enums;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * 时光信收件人类型，对应 {@code bu_time_letter.recipient_type}。
 */
@Getter
@RequiredArgsConstructor
public enum TimeLetterRecipientType {
    SELF(1),
    FRIEND(2);

    private final int code;

    public static TimeLetterRecipientType fromCode(int code) {
        for (TimeLetterRecipientType v : values()) {
            if (v.code == code) {
                return v;
            }
        }
        return null;
    }
}
