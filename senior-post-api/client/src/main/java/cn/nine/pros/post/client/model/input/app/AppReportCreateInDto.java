package cn.nine.pros.post.client.model.input.app;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
@Schema(description = "App 提交举报")
public class AppReportCreateInDto {

    @NotBlank
    @Size(max = 32)
    @Schema(description = "举报对象类型：postcard / comment", example = "postcard")
    private String targetType;

    @NotNull
    @Schema(description = "举报对象主键（明信片 ID 或评论 ID）")
    private Long targetId;

    @NotBlank
    @Size(max = 255)
    @Schema(description = "举报原因")
    private String reason;
}
