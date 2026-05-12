package cn.nine.pros.post.client.common.enums;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * 信件发送 / 投递路径模式（DB 列 {@code bu_letter.send_mode}）。
 * <p>
 * 与 {@link LetterPhysicalType} 区分：{@code send_mode} 表示系统内部选择的「运输轨」；
 * {@code letter_type}（{@link LetterPhysicalType}）表示用户选择的挂号/平邮产品形态。
 * 二者组合可表达例如「用户选挂号 + VIP 直发」等场景。
 * </p>
 * <ul>
 *   <li>{@link #STANDARD_POST}（1）— 平邮路径：慢递、可配预计送达</li>
 *   <li>{@link #REGISTERED_MAIL}（2）— 挂号路径：非 VIP 寄挂号时扣邮票后走挂号轨</li>
 *   <li>{@link #DIRECT_VIP}（3）— VIP 直发：寄挂号且 VIP 免邮票时采用的即时送达轨</li>
 * </ul>
 */
@Getter
@RequiredArgsConstructor
public enum LetterSendMode {
    /** 平邮路径（与 {@link LetterPhysicalType#STANDARD} 搭配） */
    STANDARD_POST(1),
    /** 挂号路径（扣邮票等非 VIP 场景） */
    REGISTERED_MAIL(2),
    /** VIP 直发 / 免扣邮票的即时送达轨 */
    DIRECT_VIP(3);

    private final int code;

    /**
     * 将整型映射为枚举；若值未定义则回退为 {@link #STANDARD_POST}（兼容历史脏数据，写入路径请使用显式枚举）。
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
