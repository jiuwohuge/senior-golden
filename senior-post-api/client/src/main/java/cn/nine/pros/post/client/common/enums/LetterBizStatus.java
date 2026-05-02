package cn.nine.pros.post.client.common.enums;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * 信件业务状态（DB bu_letter.status）。
 */
@Getter
@RequiredArgsConstructor
public enum LetterBizStatus {
    DELIVERING(1),
    DELIVERED(2),
    REGISTERED(3);

    private final int code;

    public static LetterBizStatus fromCode(int code) {
        for (LetterBizStatus v : values()) {
            if (v.code == code) {
                return v;
            }
        }
        return DELIVERING;
    }
}
