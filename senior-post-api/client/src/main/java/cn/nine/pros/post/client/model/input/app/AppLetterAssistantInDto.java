package cn.nine.pros.post.client.model.input.app;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * 信件助手：基于用户原文与帮助模式生成整理稿或灵感话题（不自动覆盖正文）。
 */
@Data
@Schema(description = "信件助手请求")
public class AppLetterAssistantInDto {

    @Size(max = 8000)
    @Schema(description = "用户原文；inspire 可空（尚未落笔时给开场灵感）")
    private String sourceText;

    @NotBlank
    @Schema(
            description = "帮助模式：warmer|natural|continue|shorten|inspire",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private String helpMode;

    @Size(max = 2000)
    @Schema(description = "自定义需求（已废弃，保留兼容）")
    private String customInstruction;

    @Size(max = 16)
    @Schema(description = "输出语言：en|zh；未传时默认 zh")
    private String targetLang;
}
