package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;

/**
 * Mock 推送入队响应：outboxId + 可选 Job 投递摘要。
 */
@Data
@Schema(description = "Mock 推送入队结果")
public class PushMockEnqueueVO {

    private Long outboxId;

    private String eventType;

    private Long letterId;

    private Long recipientUserId;

    private Boolean jobTriggered;

    private Integer jobClaimed;

    private Integer jobSent;

    private Integer jobFailed;

    private Integer jobDeliveries;

    private List<DeliveryItem> deliveries = new ArrayList<>();

    @Data
    public static class DeliveryItem {
        private Long deliveryId;
        private Long endpointId;
        private String sendStatus;
        private String provider;
        private String fcmMessageId;
    }
}
