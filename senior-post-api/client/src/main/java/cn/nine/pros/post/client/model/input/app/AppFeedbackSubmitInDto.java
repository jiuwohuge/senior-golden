package cn.nine.pros.post.client.model.input.app;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
@Schema(description = "提交 APP 反馈")
public class AppFeedbackSubmitInDto {

    @NotBlank
    @Size(max = 4000)
    @Schema(description = "反馈正文")
    private String content;

    @Size(max = 128)
    @Schema(description = "客户端版本（可选）")
    private String clientVersion;
}
