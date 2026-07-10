package cn.nine.pros.post.client.common.enums;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * 信件发送模式（DB 列 {@code bu_letter.mode}），与运输轨 {@link LetterSendMode} 不同。
 */
@Getter
@RequiredArgsConstructor
public enum LetterMode {
    /** 邮局匹配池（无指定收件人） */
    POST_OFFICE(1),
    /** 指定收件人直投 */
    DIRECT(2),
    /** 时光信（预留；当前产品走 bu_time_letter） */
    SELF_TIME(3);

    private final int code;

    public static LetterMode fromCode(Integer code) {
        if (code == null) {
            return null;
        }
        for (LetterMode v : values()) {
            if (v.code == code) {
                return v;
            }
        }
        return null;
    }
}
