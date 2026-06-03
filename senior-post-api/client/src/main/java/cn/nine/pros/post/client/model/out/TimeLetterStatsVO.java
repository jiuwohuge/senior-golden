package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
@Schema(description = "时光信私密统计")
public class TimeLetterStatsVO {

    private int inFlightCount;
    private int deliveredUnreadCount;
    private int memorialCount;
    private int todayDeliveredCount;
}
