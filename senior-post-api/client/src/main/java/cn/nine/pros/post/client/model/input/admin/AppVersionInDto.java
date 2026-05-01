package cn.nine.pros.post.client.model.input.admin;

import cn.nine.commons.data.dto.AbstractDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "版本创建/更新入参")
public class AppVersionInDto extends AbstractDTO {

    @Schema(description = "版本ID（更新时传入）")
    private Integer id;

    @NotBlank(message = "版本号不能为空")
    @Schema(description = "版本号")
    private String version;

    @NotNull(message = "平台不能为空")
    @Schema(description = "平台：1-iOS 2-Android")
    private Integer platform;

    @NotBlank(message = "下载地址不能为空")
    @Schema(description = "下载地址")
    private String downloadUrl;

    @Schema(description = "更新内容")
    private String updateContent;

    @NotNull(message = "是否强制更新不能为空")
    @Schema(description = "是否强制更新")
    private Boolean isForceUpdate;

    @Schema(description = "最小版本号（可选）")
    private String minVersion;
}