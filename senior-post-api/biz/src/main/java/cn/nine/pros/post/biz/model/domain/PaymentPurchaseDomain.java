package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import cn.nine.pros.post.biz.support.mybatis.PostgresJsonbTypeHandler;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
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
 * 支付购买主单。
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName(value = "bu_payment_purchase", autoResultMap = true)
public class PaymentPurchaseDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    @Schema(description = "内部购买号（无短横 UUID）")
    private String purchaseNo;

    @Schema(description = "用户 ID")
    private Long userId;

    @Schema(description = "内部商品 ID")
    private Long productId;

    @Schema(description = "支付渠道 provider")
    private String provider;

    @Schema(description = "商店商品 ID")
    private String storeProductId;

    @Schema(description = "purchaseToken SHA-256 hex")
    private String purchaseTokenHash;

    @Schema(description = "可选密文；生产须 vault/AES")
    private String purchaseTokenCipher;

    @Schema(description = "截断预览 first4…last4")
    private String purchaseTokenPreview;

    @Schema(description = "外部订单号")
    private String externalOrderId;

    @Schema(description = "pending|purchased|canceled|refunded|revoked")
    private String status;

    private LocalDateTime purchasedAt;

    private LocalDateTime paidAt;

    @Schema(description = "sandbox|production")
    private String environment;

    @Schema(description = "渠道快照 JSON")
    @TableField(value = "channel_snapshot_json", typeHandler = PostgresJsonbTypeHandler.class)
    private Object channelSnapshotJson;
}
