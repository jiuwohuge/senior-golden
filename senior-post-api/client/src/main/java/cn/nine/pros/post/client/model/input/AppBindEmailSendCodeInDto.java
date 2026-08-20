package cn.nine.pros.post.client.model.input;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 访客绑定邮箱前发验证码。
 */
@Data
@Schema(description = "访客绑定邮箱：发送验证码")
public class AppBindEmailSendCodeInDto {

    @NotBlank
    @Email
    @Schema(description = "待绑定邮箱")
    private String email;
}
