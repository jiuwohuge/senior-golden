package cn.nine.pros.post.client.model.input.admin;

import cn.nine.commons.data.dto.AbstractDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "敏感词创建/更新入参")
public class SensitiveWordInDto extends AbstractDTO {

    @Schema(description = "敏感词ID（更新时传入）")
    private Integer id;

    @NotBlank(message = "敏感词不能为空")
    @Schema(description = "敏感词")
    private String word;

    @NotBlank(message = "语言代码不能为空")
    @Schema(description = "语言代码")
    private String langCode;

    @NotBlank(message = "类型不能为空")
    @Schema(description = "类型：porn/politics/ad等")
    private String type;

    @Schema(description = "类型描述（多语言）")
    private String typeText;
}