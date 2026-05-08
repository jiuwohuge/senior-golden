package cn.nine.pros.post.client.model.input;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
@Schema(description = "重置密码")
public class AppResetPasswordInDto {

    @NotBlank
    @Email
    @Schema(description = "注册邮箱")
    private String email;

    @NotBlank
    @Size(min = 4, max = 16)
    @Schema(description = "邮件中的验证码")
    private String code;

    @NotBlank
    @Size(min = 8, max = 64)
    @Schema(description = "新密码（至少 8 位）")
    private String newPassword;
}
