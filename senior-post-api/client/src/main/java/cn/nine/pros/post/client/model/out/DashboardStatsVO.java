package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
@Schema(description = "仪表盘统计数据")
public class DashboardStatsVO {

    @Schema(description = "总用户数")
    private Long totalUsers;

    @Schema(description = "今日新增用户")
    private Long todayNewUsers;

    @Schema(description = "日活用户")
    private Long dailyActiveUsers;

    @Schema(description = "信件总数")
    private Long totalLetters;

    @Schema(description = "VIP用户数")
    private Long vipCount;
}