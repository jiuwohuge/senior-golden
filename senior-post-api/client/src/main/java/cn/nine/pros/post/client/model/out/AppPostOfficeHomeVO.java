package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 邮局首页聚合（§11）：一句话状态 + 额度 + 两张摘要计数。
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "邮局首页")
public class AppPostOfficeHomeVO {

    @Schema(description = "问候语（已本地化）")
    private String greeting;

    @Schema(description = "今日提示（已本地化）")
    private String todayHint;

    @Schema(description = "每日写信额度上限")
    private Integer dailyLetterQuota;

    @Schema(description = "今日已发送（含回信）")
    private Integer sentToday;

    @Schema(description = "今日是否已领取免费额度")
    private Boolean quotaClaimedToday;

    @Schema(description = "剩余可发（未领取时为 0）")
    private Integer remainingQuota;

    @Schema(description = "是否已完成首封信引导")
    private Boolean firstLetterDone;

    @Schema(description = "关系消息摘要条数（笔友申请等）")
    private Integer relationMessageCount;

    @Schema(description = "在途摘要：发出未达 + 收到未达 + 未读")
    private Integer inTransitCount;

    @Schema(description = "发出未达")
    private Integer outboundInTransit;

    @Schema(description = "收到未达（向你运输中）")
    private Integer inboundInTransit;

    @Schema(description = "已送达未读")
    private Integer unreadDelivered;
}
