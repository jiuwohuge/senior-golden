package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "强制同步结果（仅重查，不退款）")
public class AdminCommercePurchaseForceSyncResultVO {

    private Long purchaseId;
    private boolean synced;
    private String message;
    private SubscriptionStatusVO subscriptionStatus;
}
