package cn.nine.pros.post.client.common.enums;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * 信件载体类型（DB 列 {@code bu_letter.letter_type}，API 字段 {@code letterType}）。
 * <p>
 * 与 {@link LetterSendMode} 区分：本枚举描述「寄的是挂号信还是平邮」；{@link LetterSendMode} 描述实际走的投递/计费路径
 * （例如 VIP 寄挂号信可能走直发轨 {@code DIRECT_VIP}）。
 * </p>
 * <ul>
 *   <li>{@link #REGISTERED}（1）— 挂号信：业务上通常即时送达（仍可能配合 {@link LetterSendMode} 区分路径）</li>
 *   <li>{@link #STANDARD}（2）— 平邮：慢信，运输中直至预计送达或发件人加速/收件人提前拆信等</li>
 * </ul>
 */
@Getter
@RequiredArgsConstructor
public enum LetterPhysicalType {

    /** 挂号信（即时送达语义，具体路径见 {@link LetterSendMode}） */
    REGISTERED(1),

    /** 平邮（慢信，运输中 / 预计送达） */
    STANDARD(2);

    private final int code;

    /**
     * 按库表整型解析；未知或非支持值时返回 {@code null}（调用方应视为非法入参）。
     */
    public static LetterPhysicalType fromCode(int code) {
        for (LetterPhysicalType v : values()) {
            if (v.code == code) {
                return v;
            }
        }
        return null;
    }

    /**
     * 与 {@link #fromCode(int)} 相同，便于接收可空 DTO 字段。
     */
    public static LetterPhysicalType fromCode(Integer code) {
        if (code == null) {
            return null;
        }
        return fromCode(code.intValue());
    }
}
