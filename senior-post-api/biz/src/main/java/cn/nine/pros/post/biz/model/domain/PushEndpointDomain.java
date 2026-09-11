package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.time.LocalDateTime;

/**
 * FCM/APNs 推送端点 Domain（{@code bu_push_endpoint}）。
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName("bu_push_endpoint")
public class PushEndpointDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    @Schema(description = "用户 ID")
    private Long userId;

    @Schema(description = "设备 UUID（equipmentId）")
    private String deviceUuid;

    @Schema(description = "ios|android")
    private String platform;

    @Schema(description = "FCM/APNs push token")
    private String pushToken;

    private String firebaseInstallationId;

    private String appVersion;

    private String locale;

    @Schema(description = "granted|denied|unknown")
    private String notificationPermission;

    private Boolean enabled;

    private LocalDateTime lastSeenAt;

    private LocalDateTime invalidatedAt;

    private String invalidReason;
}
