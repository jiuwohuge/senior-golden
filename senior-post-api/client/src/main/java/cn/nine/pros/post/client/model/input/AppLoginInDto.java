package cn.nine.pros.post.client.model.input;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
@Schema(description = "App 登录请求")
public class AppLoginInDto {

    @NotBlank
    @Schema(description = "邮箱")
    private String email;

    @NotBlank
    @Schema(description = "密码")
    private String password;

    @NotBlank
    @Schema(description = "设备唯一标识")
    private String deviceUuid;

    @NotBlank
    @Schema(description = "设备类型")
    private String deviceType;
}
