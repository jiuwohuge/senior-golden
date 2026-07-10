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
public class PostOfficeRelationMessageVO {

    @Schema(description = "消息类型：1=笔友请求 2=关系提醒")
    private Integer messageType;

    @Schema(description = "申请 ID（类型 1）")
    private Long requestId;

    @Schema(description = "对端用户")
    private AppPublicUserVO peer;

    @Schema(description = "往来信件数")
    private Integer letterCount;

    @Schema(description = "是否可发起添加笔友（类型 2）")
    private Boolean canAddPenpal;
}
