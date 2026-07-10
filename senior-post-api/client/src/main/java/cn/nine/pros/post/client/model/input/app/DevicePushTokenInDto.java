package cn.nine.pros.post.client.model.input.app;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
@Schema(description = "推送 Token 注册")
public class DevicePushTokenInDto {

    @NotBlank
    @Schema(description = "平台 ios|android", requiredMode = Schema.RequiredMode.REQUIRED)
    private String platform;

    @NotBlank
    @Schema(description = "FCM/APNs device token", requiredMode = Schema.RequiredMode.REQUIRED)
    private String token;

    @Schema(description = "是否启用推送，默认 true")
    private Boolean enabled;
}
