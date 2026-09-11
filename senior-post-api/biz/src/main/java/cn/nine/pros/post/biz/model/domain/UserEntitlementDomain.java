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

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName("bu_user_entitlement")
public class UserEntitlementDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    @Schema(description = "用户 ID")
    private Long userId;

    @Schema(description = "商品 ID")
    private Long productId;

    @Schema(description = "权益编码，如 plus")
    private String entitlementCode;

    @Schema(description = "关联购买主单 ID")
    private Long purchaseId;

    @Schema(description = "关联订阅 ID（bu_subscription）")
    private Long subscriptionId;

    @Schema(description = "来源 admin_grant|mock_purchase|play|mock")
    private String source;

    @Schema(description = "生效时间")
    private LocalDateTime effectiveAt;

    @Schema(description = "过期时间，null 表示永久")
    private LocalDateTime expiresAt;

    @Schema(description = "撤销时间")
    private LocalDateTime revokedAt;

    @Schema(description = "active|revoked|expired")
    private String status;
}
