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
public class RelationSnapshotVO {

    @Schema(description = "对端用户 ID")
    private Long peerUserId;

    @Schema(description = "展示态，整型同 RelationDisplayState")
    private Integer displayState;

    @Schema(description = "有效往来信件数")
    private Integer letterCount;

    @Schema(description = "是否可显示添加笔友")
    private Boolean canAddPenpal;

    @Schema(description = "进行中的申请 ID（若有）")
    private Long pendingRequestId;

    @Schema(description = "是否已是笔友")
    private Boolean penpal;
}
