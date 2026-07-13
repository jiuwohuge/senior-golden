package cn.nine.pros.post.client.model.input.app;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * 信件助手：基于用户原文与帮助模式生成整理稿（不自动覆盖正文）。
 */
@Data
@Schema(description = "信件助手请求")
public class AppLetterAssistantInDto {

    @NotBlank
    @Size(max = 8000)
    @Schema(description = "用户原文", requiredMode = Schema.RequiredMode.REQUIRED)
    private String sourceText;

    @NotBlank
    @Schema(
            description = "帮助模式：warmer|natural|expand|polite|translate|custom",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private String helpMode;

    @Size(max = 2000)
    @Schema(description = "自定义需求（helpMode=custom 时建议填写）")
    private String customInstruction;

    @Size(max = 16)
    @Schema(description = "翻译目标语，默认 en（仅 translate）")
    private String targetLang;
}
