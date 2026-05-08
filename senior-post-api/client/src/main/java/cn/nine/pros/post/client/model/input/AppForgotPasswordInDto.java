package cn.nine.pros.post.client.model.input;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
@Schema(description = "忘记密码：申请验证码")
public class AppForgotPasswordInDto {

    @NotBlank
    @Email
    @Schema(description = "注册邮箱")
    private String email;
}
