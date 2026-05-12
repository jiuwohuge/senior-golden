package cn.nine.pros.post.client.common.enums;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * 信件业务状态（DB 列 {@code bu_letter.status}）。
 * <ul>
 *   <li>{@link #DELIVERING}（1）— 运输中（典型为平邮在途）</li>
 *   <li>{@link #DELIVERED}（2）— 已送达（挂号即时达、平邮到期或加速后等）</li>
 *   <li>{@link #REGISTERED}（3）— 已挂号（预留语义，当前业务较少使用）</li>
 * </ul>
 */
@Getter
@RequiredArgsConstructor
public enum LetterBizStatus {
    /** 运输中 */
    DELIVERING(1),
    /** 已送达 */
    DELIVERED(2),
    /** 已挂号（预留） */
    REGISTERED(3);

    private final int code;

    /**
     * 将整型映射为枚举；未知值时回退为 {@link #DELIVERING}（仅用于兼容读路径，状态迁移请显式使用枚举）。
     */
    public static LetterBizStatus fromCode(int code) {
        for (LetterBizStatus v : values()) {
            if (v.code == code) {
                return v;
            }
        }
        return DELIVERING;
    }
}
