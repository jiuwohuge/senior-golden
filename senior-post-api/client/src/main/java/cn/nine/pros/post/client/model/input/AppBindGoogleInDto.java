package cn.nine.pros.post.client.model.input;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 把 Google openId 挂到当前访客，不新建 user。
 */
@Data
@Schema(description = "访客绑定 Google")
public class AppBindGoogleInDto {

    @NotBlank
    @Schema(description = "Google ID Token")
    private String idToken;
}
