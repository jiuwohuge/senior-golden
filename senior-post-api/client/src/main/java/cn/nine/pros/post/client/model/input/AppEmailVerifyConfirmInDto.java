package cn.nine.pros.post.client.model.input;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
@Schema(description = "确认邮箱验证码")
public class AppEmailVerifyConfirmInDto {

    @NotBlank
    @Schema(description = "6 位验证码")
    private String code;
}
