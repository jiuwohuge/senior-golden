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
 * 信件 content_meta_json：皮肤/字体/模板。
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

    @JsonAlias({"skin_id"})
    @Schema(description = "信纸皮肤 ID")
    private String skinId;

    @JsonAlias({"font_id"})
    @Schema(description = "字体 ID")
    private String fontId;

    @JsonAlias({"template_id"})
    @Schema(description = "模板 ID")
    private String templateId;

    public static LetterContentMeta of(String skinId, String fontId, String templateId) {
        return LetterContentMeta.builder()
                .skinId(normalize(skinId))
                .fontId(normalize(fontId))
                .templateId(normalize(templateId))
                .build();
    }

    public String skinIdOrDefault() {
        return skinId != null && !skinId.isBlank() ? skinId : DEFAULT_ID;
    }

    public String fontIdOrDefault() {
        return fontId != null && !fontId.isBlank() ? fontId : DEFAULT_ID;
    }

    private static String normalize(String raw) {
        if (raw == null || raw.isBlank()) {
            return DEFAULT_ID;
        }
        return raw.trim();
    }
}
