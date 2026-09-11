package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "购买详情（只读）")
public class CommercePurchaseDetailVO {

    private CommercePurchaseVO purchase;
    private CommerceSubscriptionSummaryVO subscription;
    private List<CommerceEntitlementVO> entitlements;
    private List<CommercePurchaseTimelineItemVO> timeline;
    private List<CommercePurchaseWebhookEventVO> webhooks;
}
