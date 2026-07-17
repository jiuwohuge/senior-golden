package cn.nine.pros.post.client.common.enums;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * 信件载体类型（DB 列 {@code bu_letter.letter_type}，API 字段 {@code letterType}）。
 * <p>
 * 现行产品写入固定 {@link #STANDARD}；{@link #REGISTERED} 仅为遗留取值。
 * 投递时长由慢递规则（距离 + 关系）决定，与本枚举无关。
 * </p>
 */
@Getter
@RequiredArgsConstructor
public enum LetterPhysicalType {

    /** 遗留编码；新发信不使用 */
    REGISTERED(1),

    /** 现行唯一写入值（慢递信件） */
    STANDARD(2);

    private final int code;

    /**
     * 按库表整型解析；未知值返回 {@code null}。
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
