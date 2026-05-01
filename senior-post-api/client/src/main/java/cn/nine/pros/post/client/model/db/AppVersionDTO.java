package cn.nine.pros.post.client.model.db;

import cn.nine.commons.data.dto.AbstractAuditableDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * App版本控制表 DTO
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
public class AppVersionDTO extends AbstractAuditableDTO {

    private static final long serialVersionUID = 1L;

    /**
     * 版本ID
     */
    @Schema(description = "版本ID")
    private Integer id;
    /**
     * 平台（ios/android）
     */
    @Schema(description = "平台（ios/android）")
    private String appPlatform;
    /**
     * 版本号
     */
    @Schema(description = "版本号")
    private String versionCode;
    /**
     * 最低支持版本
     */
    @Schema(description = "最低支持版本")
    private String minSupportedVersion;
    /**
     * 是否强制更新
     */
    @Schema(description = "是否强制更新")
    private Boolean forceUpdate;
    /**
     * 更新包地址
     */
    @Schema(description = "更新包地址")
    private String updateUrl;
    /**
     * 更新日志
     */
    @Schema(description = "更新日志")
    private String releaseNote;

}