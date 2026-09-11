package cn.nine.pros.post.client.model.input.app;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * QA Mock 入队推送（仅 {@code senior-post.push.mock-enabled} 且非 prod）。
 */
@Data
@Schema(description = "Mock 推送入队")
public class PushMockEnqueueInDto {

    @NotBlank
    @Schema(description = "letter_matched_in_transit | letter_arrived",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private String eventType;

    @NotNull
    @Schema(description = "信件 ID", requiredMode = Schema.RequiredMode.REQUIRED)
    private Long letterId;

    @Schema(description = "收件人用户 ID；缺省为当前登录用户")
    private Long recipientUserId;

    @Schema(description = "入队后是否立即跑一轮 Outbox Job；默认 true")
    private Boolean triggerJob = true;
}
