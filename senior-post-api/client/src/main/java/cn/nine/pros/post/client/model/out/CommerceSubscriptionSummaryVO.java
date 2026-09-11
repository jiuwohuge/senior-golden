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
@Schema(description = "订阅摘要（管理端只读）")
public class CommerceSubscriptionSummaryVO {

    private Long id;
    private Long purchaseId;
    private Long productId;
    private String provider;
    private String status;
    private LocalDateTime currentPeriodStart;
    private LocalDateTime currentPeriodEnd;
    private Boolean autoRenew;
    private LocalDateTime lastSyncedAt;
    private String storeProductId;
}
