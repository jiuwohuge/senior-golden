package cn.nine.pros.post.client.model.input;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * 给当前登录用户挂邮箱 identity，不新建 user。
 */
@Data
@Schema(description = "访客绑定邮箱")
public class AppBindEmailInDto {

    @NotBlank
    @Email
    @Schema(description = "邮箱")
    private String email;

    @NotBlank
    @Size(min = 6, max = 8)
    @Schema(description = "邮箱验证码")
    private String code;

    @NotBlank
    @Size(min = 8, max = 64)
    @Schema(description = "密码（至少 8 位）")
    private String password;
}
