package cn.nine.pros.post.client.common.enums;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum CommerceProductType {
    SKIN("skin"),
    TEMPLATE("template"),
    FONT("font"),
    ATTACHMENT("attachment"),
    VIP_BUNDLE("vip_bundle"),
    EXPORT("export");

    private final String code;

    public static CommerceProductType fromCode(String code) {
        if (code == null || code.isBlank()) {
            return null;
        }
        String normalized = code.trim().toLowerCase();
        for (CommerceProductType v : values()) {
            if (v.code.equals(normalized)) {
                return v;
            }
        }
        return null;
    }
}
