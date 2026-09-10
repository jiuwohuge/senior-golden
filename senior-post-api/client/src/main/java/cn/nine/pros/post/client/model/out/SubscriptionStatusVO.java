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
@Schema(description = "Plus 订阅状态与权益快照")
public class SubscriptionStatusVO {

    @Schema(description = "none|trial|active|expired")
    private String state;

    @Schema(description = "plus_monthly | plus_yearly")
    private String productId;

    @Schema(description = "权益到期时间")
    private LocalDateTime expiryAt;

    @Schema(description = "是否试用")
    private Boolean isTrial;

    @Schema(description = "play|test_override|admin|unknown")
    private String source;

    @Schema(description = "当前是否享有付费权益（trial/active 且未过期）")
    private Boolean entitled;

    @Schema(description = "本周 AI 配额上限")
    private Integer aiQuotaLimit;

    @Schema(description = "本周 AI 已用")
    private Integer aiQuotaUsed;

    @Schema(description = "本周 AI 剩余")
    private Integer aiQuotaRemaining;

    @Schema(description = "在途撤回/改信窗口（分钟）")
    private Integer recallWindowMinutes;

    @Schema(description = "可购 SKU 列表")
    private List<PlusSkuItemVO> skus;
}
