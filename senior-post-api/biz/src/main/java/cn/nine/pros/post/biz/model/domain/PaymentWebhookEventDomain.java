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
 * 支付 webhook 幂等事件。
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName("bu_payment_webhook_event")
public class PaymentWebhookEventDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    @Schema(description = "google_play|apple_app_store|mock")
    private String provider;

    @Schema(description = "渠道事件/消息 ID")
    private String eventIdOrMessageId;

    private String eventType;

    @Schema(description = "原始 payload JSON 原文")
    private String payloadJson;

    @Schema(description = "received|processed|failed")
    private String processStatus;

    private Integer retryCount;

    private String errorMessage;

    private LocalDateTime receivedAt;

    private LocalDateTime processedAt;
}
