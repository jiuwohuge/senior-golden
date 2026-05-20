package cn.nine.pros.post.client.model.input;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
@Schema(description = "Google 登录")
public class AppGoogleLoginInDto {

    @NotBlank
    @Schema(description = "Google ID Token")
    private String idToken;

    @NotNull
    @AssertTrue(message = "须同意用户协议与隐私政策")
    private Boolean agreedTerms;

    @NotBlank
    private String deviceUuid;

    @NotBlank
    private String deviceType;
}
