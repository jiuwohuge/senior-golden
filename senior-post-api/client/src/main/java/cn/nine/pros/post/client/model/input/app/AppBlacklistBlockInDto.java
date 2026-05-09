package cn.nine.pros.post.client.model.input.app;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
@Schema(description = "拉黑用户")
public class AppBlacklistBlockInDto {

    @NotNull
    @Schema(description = "被拉黑用户 ID")
    private Long blockedUserId;

    @Schema(description = "原因（可选）")
    private String reason;
}
