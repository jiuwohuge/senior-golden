package cn.nine.pros.post.client.model.json;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 信件 content_meta_json：信纸 / 字体 / 字号档 / 模板（插图后置，不进本结构）。
 * <p>字号档仅允许 {@link #FONT_SIZE_LARGE}（默认）与 {@link #FONT_SIZE_XLARGE}，供写读同构渲染。</p>
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown = true)
@Schema(description = "信件表达增强元数据")
public class LetterContentMeta {

    public static final String DEFAULT_ID = "default";

    /** 适老默认「大」字号档。 */
    public static final String FONT_SIZE_LARGE = "large";

    /** 「更大」字号档。 */
    public static final String FONT_SIZE_XLARGE = "xlarge";

    @JsonAlias({"skin_id"})
    @Schema(description = "信纸皮肤 ID")
    private String skinId;

    @JsonAlias({"font_id"})
    @Schema(description = "字体 ID")
    private String fontId;

    @JsonAlias({"font_size_tier", "fontSize"})
    @Schema(description = "字号档：large（默认）| xlarge")
    private String fontSizeTier;

    @JsonAlias({"template_id"})
    @Schema(description = "模板 ID")
    private String templateId;

    public static LetterContentMeta of(String skinId, String fontId, String templateId) {
        return of(skinId, fontId, FONT_SIZE_LARGE, templateId);
    }

    public static LetterContentMeta of(
            String skinId, String fontId, String fontSizeTier, String templateId) {
        return LetterContentMeta.builder()
                .skinId(normalize(skinId))
                .fontId(normalize(fontId))
                .fontSizeTier(normalizeFontSizeTier(fontSizeTier))
                .templateId(normalize(templateId))
                .build();
    }

    public String skinIdOrDefault() {
        return skinId != null && !skinId.isBlank() ? skinId : DEFAULT_ID;
    }

    public String fontIdOrDefault() {
        return fontId != null && !fontId.isBlank() ? fontId : DEFAULT_ID;
    }

    public String fontSizeTierOrDefault() {
        return normalizeFontSizeTier(fontSizeTier);
    }

    private static String normalize(String raw) {
        if (raw == null || raw.isBlank()) {
            return DEFAULT_ID;
        }
        return raw.trim();
    }

    /** 非法或空值回落为 large，避免读者端拿到未知档位。 */
    private static String normalizeFontSizeTier(String raw) {
        if (raw == null || raw.isBlank()) {
            return FONT_SIZE_LARGE;
        }
        String tier = raw.trim().toLowerCase();
        if (FONT_SIZE_XLARGE.equals(tier)) {
            return FONT_SIZE_XLARGE;
        }
        return FONT_SIZE_LARGE;
    }
}
