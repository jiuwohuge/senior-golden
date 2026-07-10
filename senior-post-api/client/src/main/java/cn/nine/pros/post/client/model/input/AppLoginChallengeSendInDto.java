package cn.nine.pros.post.client.model.input;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
@Schema(description = "中风险登录二次验证：发送验证码")
public class AppLoginChallengeSendInDto {

    @NotBlank
    @Email
    private String email;
}
