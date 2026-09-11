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
 * 支付订阅权威行（表 bu_subscription；与 bu_vip_subscription 兼容镜像分离）。
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName("bu_subscription")
public class PaymentSubscriptionDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    @Schema(description = "用户 ID")
    private Long userId;

    @Schema(description = "内部商品 ID")
    private Long productId;

    @Schema(description = "购买主单 ID")
    private Long purchaseId;

    @Schema(description = "支付渠道 provider")
    private String provider;

    @Schema(description = "pending|active|grace_period|on_hold|paused|canceled|expired|revoked")
    private String status;

    private LocalDateTime currentPeriodStart;

    private LocalDateTime currentPeriodEnd;

    private Boolean autoRenew;

    @Schema(description = "purchaseToken SHA-256 hex")
    private String purchaseTokenHash;

    @Schema(description = "关联旧 token hash（升级/替换）")
    private String linkedPurchaseTokenHash;

    private String cancelReason;

    private LocalDateTime lastSyncedAt;

    private Boolean isTrial;

    @Schema(description = "商店商品 ID")
    private String storeProductId;
}
