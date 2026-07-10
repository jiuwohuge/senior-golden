package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 用户设备记录表（用于风控/拉黑/防刷） Domain
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName("bu_user_device")
public class UserDeviceDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
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

    @Schema(description = "FCM/APNs push token")
    private String pushToken;

    @Schema(description = "推送平台 ios|android")
    private String pushPlatform;

    @Schema(description = "是否启用推送")
    private Boolean pushEnabled;

}