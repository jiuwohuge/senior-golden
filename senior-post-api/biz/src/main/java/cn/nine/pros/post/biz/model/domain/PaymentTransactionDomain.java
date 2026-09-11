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
 * 支付流水。
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName(value = "bu_payment_transaction", autoResultMap = true)
public class PaymentTransactionDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    @Schema(description = "购买主单 ID")
    private Long purchaseId;

    @Schema(description = "用户 ID")
    private Long userId;

    @Schema(description = "initial_purchase|renewal|refund|chargeback|revocation")
    private String txType;

    private Integer amountCents;

    private String currency;

    @Schema(description = "渠道侧交易 ID")
    private String providerTxId;

    private LocalDateTime occurredAt;

    @Schema(description = "原始快照 JSON")
    @TableField(value = "raw_snapshot_json", typeHandler = PostgresJsonbTypeHandler.class)
    private Object rawSnapshotJson;
}
