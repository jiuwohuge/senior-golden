package cn.nine.pros.post.client.model.json;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 商业商品 metadata_json。
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown = true)
@Schema(description = "商品元数据")
public class CommerceProductMetadata {

    @Schema(description = "皮肤 ID")
    private String skinId;

    @Schema(description = "字体 ID")
    private String fontId;

    @Schema(description = "模板 ID")
    private String templateId;

    @Schema(description = "预览色")
    private String previewColor;

    @Schema(description = "导出格式，如 pdf")
    private String format;

    @Schema(description = "预览图 OSS 路径")
    private String previewOssKey;
}
