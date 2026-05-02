package cn.nine.pros.post.client.common.enums;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * 信件发送模式（业务轨，与 TIM 无关）。
 */
@Getter
@RequiredArgsConstructor
public enum LetterSendMode {
    STANDARD_POST(1),
    REGISTERED_MAIL(2),
    DIRECT_VIP(3);

    private final int code;

    public static LetterSendMode fromCode(int code) {
        for (LetterSendMode v : values()) {
            if (v.code == code) {
                return v;
            }
        }
        return STANDARD_POST;
    }
}
