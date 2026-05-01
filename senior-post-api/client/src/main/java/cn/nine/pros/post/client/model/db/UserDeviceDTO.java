package cn.nine.pros.post.client.model.db;

import cn.nine.commons.data.dto.AbstractAuditableDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 用户设备记录表（用于风控/拉黑/防刷） DTO
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
public class UserDeviceDTO extends AbstractAuditableDTO {

    private static final long serialVersionUID = 1L;

    /**
     * 设备记录ID
     */
    @Schema(description = "设备记录ID")
    private Long id;
    /**
     * 用户ID
     */
    @Schema(description = "用户ID")
    private Long userId;
    /**
     * 设备唯一标识（IDFA/IDFV/Android ID）
     */
    @Schema(description = "设备唯一标识（IDFA/IDFV/Android ID）")
    private String deviceUuid;
    /**
     * 设备类型（ios/android）
     */
    @Schema(description = "设备类型（ios/android）")
    private String deviceType;
    /**
     * 最后登录时间
     */
    @Schema(description = "最后登录时间")
    private Object lastLoginAt;
    /**
     * 状态：1正常 2黑名单
     */
    @Schema(description = "状态：1正常 2黑名单")
    private Object status;

}