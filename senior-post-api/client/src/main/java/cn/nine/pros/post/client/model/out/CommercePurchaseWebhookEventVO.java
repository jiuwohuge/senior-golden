package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Webhook 事件（只读，payload 已脱敏）")
public class CommercePurchaseWebhookEventVO {

    private Long id;
    private String provider;
    private String eventIdOrMessageId;
    private String eventType;
    private String processStatus;
    private String errorMessage;
    private Integer retryCount;
    private LocalDateTime receivedAt;
    private LocalDateTime processedAt;
    /** 脱敏后的 payload 字符串，不含完整 purchaseToken */
    private String payloadMasked;
}
