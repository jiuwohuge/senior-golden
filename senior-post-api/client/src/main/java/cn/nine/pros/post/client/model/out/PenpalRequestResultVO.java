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
public class PenpalRequestResultVO {

    @Schema(description = "申请 ID")
    private Long requestId;

    @Schema(description = "对端用户 ID")
    private Long peerUserId;

    @Schema(description = "状态，整型同 PenpalRequestStatus")
    private Integer status;

    @Schema(description = "创建时间")
    private LocalDateTime createdAt;
}
