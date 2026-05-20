package cn.nine.pros.post.client.model.input;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.*;
import lombok.Data;

import java.util.List;

/**
 * App 邮箱注册入参；须提交至少 3 个有效兴趣标签 ID（与 {@code sys_tag} 一致）。
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
    @Min(1)
    @Max(3)
    @Schema(description = "性别：1男 2女 3其他")
    private Integer gender;

    @NotNull
    @Min(1900)
    @Max(2100)
    @Schema(description = "出生年份（用于年龄门槛校验）")
    private Integer birthYear;

    @Size(max = 512)
    @Schema(description = "可选头像 objectKey")
    private String avatarUrl;

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

    @NotNull
    @Size(min = 3, max = 30)
    @Schema(description = "兴趣标签 ID（至少 3 个，写入 bu_user_tag）")
    private List<@NotNull Integer> interestTagIds;
}
