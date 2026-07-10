package cn.nine.pros.post.client.common.enums;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * 信件业务状态（DB 列 {@code bu_letter.status}）。
 * <ul>
 *   <li>{@link #PENDING}（0）— 待匹配 / 待启运（POST_OFFICE 入池）</li>
 *   <li>{@link #DELIVERING}（1）— 运输中</li>
 *   <li>{@link #DELIVERED}（2）— 已送达</li>
 *   <li>{@link #REGISTERED}（3）— 已挂号（预留）</li>
 *   <li>{@link #MATCHED}（4）— 已匹配待启运（M3）</li>
 * </ul>
 */
@Getter
@RequiredArgsConstructor
public enum LetterBizStatus {
    /** 待匹配 / 待启运 */
    PENDING(0),
    /** 运输中 */
    DELIVERING(1),
    /** 已送达 */
    DELIVERED(2),
    /** 已挂号（预留） */
    REGISTERED(3),
    /** 已匹配（M3） */
    MATCHED(4);

    private final int code;

    /**
     * 将整型映射为枚举；未知值时回退为 {@link #DELIVERING}（仅用于兼容读路径）。
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
