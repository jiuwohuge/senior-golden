package cn.nine.pros.post.client.common.enums;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * §10.3 UI 派生关系展示态（非持久状态）。
 */
@Getter
@RequiredArgsConstructor
public enum RelationDisplayState {
    STRANGER(1),
    CONTACTING(2),
    CAN_ADD_PENPAL(3),
    PENDING_OUT(4),
    PENDING_IN(5),
    PENPAL(6);

    private final int code;

    public static RelationDisplayState fromCode(int code) {
        for (RelationDisplayState v : values()) {
            if (v.code == code) {
                return v;
            }
        }
        return STRANGER;
    }
}
