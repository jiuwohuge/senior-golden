package cn.nine.pros.post.client.model.input.app;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 本地 mock 购买同步入参（仅 billing.mock-enabled 且非 prod）。
 */
@Data
@Schema(description = "Mock 购买同步")
public class BillingMockSyncInDto {

    @NotBlank
    @Schema(description = "PURCHASED|PENDING|RENEW|CANCEL|EXPIRE|REFUND|REVOKE",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private String scenario;

    @Schema(description = "plus_monthly | plus_yearly；默认 plus_yearly")
    private String productId;

    @Schema(description = "可选；空白则生成 mock:{productId}:{scenario}:{uuid}")
    private String purchaseToken;
}
