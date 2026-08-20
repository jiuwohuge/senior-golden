package cn.nine.pros.post.client.model.input;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * 设备静默创建访客账号。guest 是真实 user，无邮箱 identity。
 */
@Data
@Schema(description = "App 静默访客请求")
public class AppGuestInDto {

    @NotBlank
    @Schema(description = "设备唯一标识")
    private String deviceUuid;

    @Size(max = 32)
    @Schema(description = "设备类型：android / ios 等")
    private String deviceType;

    @Size(max = 32)
    @Schema(description = "可选语言标签，如 zh-CN")
    private String language;

    @Size(max = 10)
    @Schema(description = "可选国家代码")
    private String countryCode;

    @Schema(description = "可选 GPS 纬度")
    private Double latitude;

    @Schema(description = "可选 GPS 经度")
    private Double longitude;
}
