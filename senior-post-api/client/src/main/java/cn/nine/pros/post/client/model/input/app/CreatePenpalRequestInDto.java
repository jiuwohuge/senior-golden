package cn.nine.pros.post.client.model.input.app;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CreatePenpalRequestInDto {

    @NotNull
    @Schema(description = "目标用户 ID")
    private Long peerUserId;

    @Schema(description = "触发申请的来源信件 ID（可选）")
    private Long sourceLetterId;
}
