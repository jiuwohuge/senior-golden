package cn.nine.pros.post.client.model.input.app;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * App 发送信件（挂号 / 平邮）。
 */
@Data
@Schema(description = "发送信件")
public class AppSendLetterInDto {

    @NotNull
    @Schema(description = "收件人用户 ID", requiredMode = Schema.RequiredMode.REQUIRED)
    private Long toUserId;

    @NotBlank
    @Size(max = 20000)
    @Schema(description = "信件正文", requiredMode = Schema.RequiredMode.REQUIRED)
    private String content;

    /**
     * 1=挂号信（即时）；2=平邮（慢信）。
     */
    @NotNull
    @Schema(description = "1挂号信 2平邮", requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer letterType;
}
