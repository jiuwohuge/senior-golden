package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 每日额度领取结果。
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "每日额度领取")
public class DailyQuotaClaimVO {

    @Schema(description = "是否已领取（含本次）")
    private Boolean claimed;

    @Schema(description = "当日额度上限")
    private Integer dailyLetterQuota;

    @Schema(description = "今日已发送")
    private Integer sentToday;

    @Schema(description = "剩余可发")
    private Integer remainingQuota;
}
