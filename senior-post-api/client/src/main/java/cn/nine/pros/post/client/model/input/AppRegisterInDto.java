package cn.nine.pros.post.client.model.input;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.*;
import lombok.Data;

/**
 * App 邮箱注册入参（M1：资料可后续在「完善资料」接口补齐）。
 */
@Data
@Schema(description = "App 注册请求")
public class AppRegisterInDto {

    @NotBlank
    @Email
    @Schema(description = "邮箱")
    private String email;

    @NotBlank
    @Size(min = 8, max = 64)
    @Schema(description = "密码（至少 8 位）")
    private String password;

    @NotBlank
    @Size(max = 100)
    @Schema(description = "昵称")
    private String nickname;

    @NotNull
    @Min(1900)
    @Max(2100)
    @Schema(description = "出生年份（用于年龄门槛校验）")
    private Integer birthYear;

    @Size(max = 10)
    @Schema(description = "国家代码 ISO 3166-1 alpha-2，可空")
    private String countryCode;

    @NotNull
    @AssertTrue(message = "须同意用户协议与隐私政策")
    @Schema(description = "是否已同意协议")
    private Boolean agreedTerms;

    @NotBlank
    @Schema(description = "设备唯一标识")
    private String deviceUuid;

    @NotBlank
    @Schema(description = "设备类型：android / ios 等")
    private String deviceType;
}
