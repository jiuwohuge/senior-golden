package cn.nine.pros.post.client.common.enums;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum PenpalRequestStatus {
    PENDING(1),
    ACCEPTED(2),
    IGNORED(3);

    private final int code;

    public static PenpalRequestStatus fromCode(int code) {
        for (PenpalRequestStatus v : values()) {
            if (v.code == code) {
                return v;
            }
        }
        return PENDING;
    }
}
