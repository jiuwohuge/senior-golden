package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import cn.nine.pros.post.biz.support.mybatis.PostgresJsonbTypeHandler;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.time.LocalDateTime;

/**
 * Payment webhook idempotent event.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName(value = "bu_payment_webhook_event", autoResultMap = true)
public class PaymentWebhookEventDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    @Schema(description = "google_play / apple_app_store / mock")
    private String provider;

    @Schema(description = "external event or message id")
    private String eventIdOrMessageId;

    private String eventType;

    /**
     * Raw payload (DB column jsonb). Must use PostgresJsonbTypeHandler
     * to avoid varchar vs jsonb type mismatch on insert.
     */
    @Schema(description = "raw payload JSON")
    @TableField(value = "payload_json", typeHandler = PostgresJsonbTypeHandler.class)
    private String payloadJson;

    @Schema(description = "received / processed / failed")
    private String processStatus;

    private Integer retryCount;

    private String errorMessage;

    private LocalDateTime receivedAt;

    private LocalDateTime processedAt;
}
