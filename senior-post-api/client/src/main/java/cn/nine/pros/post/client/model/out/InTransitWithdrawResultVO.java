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
@Schema(description = "在途撤回结果：正文落入草稿，原信软删")
public class InTransitWithdrawResultVO {

    @Schema(description = "新建草稿 ID")
    private Long draftId;

    @Schema(description = "已撤回的信件 ID")
    private Long letterId;
}
