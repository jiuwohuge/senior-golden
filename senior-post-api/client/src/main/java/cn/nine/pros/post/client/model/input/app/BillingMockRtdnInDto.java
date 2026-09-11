package cn.nine.pros.post.client.model.input.app;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * Mock RTDN 回放入参（仅 billing.mock-enabled 且非 prod）。
 */
@Data
@Schema(description = "Mock RTDN 订阅通知回放")
public class BillingMockRtdnInDto {

    @NotBlank
    @Schema(description = "模拟 Pub/Sub messageId，用于幂等", requiredMode = Schema.RequiredMode.REQUIRED)
    private String messageId;

    @NotBlank
    @Schema(description = "已绑定的 purchaseToken", requiredMode = Schema.RequiredMode.REQUIRED)
    private String purchaseToken;

    @NotBlank
    @Schema(description = "RTDN notificationType，如 SUBSCRIPTION_RENEWED", requiredMode = Schema.RequiredMode.REQUIRED)
    private String notificationType;

    @Schema(description = "plus_monthly | plus_yearly；可选，缺省从 token/订阅解析")
    private String productId;
}
