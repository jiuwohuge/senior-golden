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
@Schema(description = "管理端笔友关系项")
public class AdminPenpalItemVO {

    @Schema(description = "好友关系 ID")
    private Long id;

    @Schema(description = "用户 A（userLow）")
    private Long userA;

    @Schema(description = "用户 B（userHigh）")
    private Long userB;

    @Schema(description = "建立时间")
    private LocalDateTime createdAt;

    @Schema(description = "往来信件数")
    private Long letterCount;
}
