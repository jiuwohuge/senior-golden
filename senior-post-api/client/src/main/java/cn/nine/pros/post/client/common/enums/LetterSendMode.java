package cn.nine.pros.post.client.common.enums;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * 信件发送模式（DB 列 {@code bu_letter.send_mode}）。
 * <p>
 * 现行产品统一慢递：写入固定 {@link #STANDARD_POST}；
 * {@link #REGISTERED_MAIL} / {@link #DIRECT_VIP} 仅为库内遗留取值兼容，无计费或「立即送达」业务语义。
 * </p>
 */
@Getter
@RequiredArgsConstructor
public enum LetterSendMode {
    /** 慢递（现行唯一写入值） */
    STANDARD_POST(1),
    /** 遗留编码；新发信不使用 */
    REGISTERED_MAIL(2),
    /** 遗留编码；新发信不使用 */
    DIRECT_VIP(3);

    private final int code;

    /**
     * 将整型映射为枚举；未知值回退 {@link #STANDARD_POST}。
     */
    public static LetterSendMode fromCode(int code) {
        for (LetterSendMode v : values()) {
            if (v.code == code) {
                return v;
            }
        }
        return STANDARD_POST;
    }
}
