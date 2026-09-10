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

    @Schema(description = "寄出/创建时间")
    private LocalDateTime sentTime;

    @Schema(description = "预计送达时间")
    private LocalDateTime expectedArrivalTime;

    @Schema(description = "相对预计剩余小时（约）")
    private Double etaRelativeHours;

    @Schema(description = "在途进度 0~1")
    private Double progressRatio;

    @Schema(description = "摘要预览；收到未达时为空（正文密封）")
    private String preview;

    @Schema(description = "是否可在途撤回/改信（仅 outbound 有意义）")
    private Boolean canRecallEdit;

    @Schema(description = "在途撤回/改信窗口截止时间")
    private LocalDateTime recallExpiresAt;

    @Schema(description = "在窗口内但未订阅时为 true（提示升级）")
    private Boolean recallNeedsUpgrade;

    @Schema(description = "是否仍在撤回窗口内")
    private Boolean withinRecallWindow;
}
