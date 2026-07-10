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
public class PostOfficeInTransitItemVO {

    @Schema(description = "条目类型：1=发出未达 2=收到未达 3=未读已送达")
    private Integer itemType;

    @Schema(description = "信件 ID")
    private Long letterId;

    @Schema(description = "对端用户")
    private AppPublicUserVO peer;

    @Schema(description = "预计送达时间")
    private LocalDateTime expectedArrivalTime;

    @Schema(description = "摘要预览")
    private String preview;
}
