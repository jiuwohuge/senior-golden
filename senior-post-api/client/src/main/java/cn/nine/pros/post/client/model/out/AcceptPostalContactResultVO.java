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
public class AcceptPostalContactResultVO {

    @Schema(description = "好友关系ID")
    private Long friendshipId;

    @Schema(description = "对端用户ID（TIM userID 同源）")
    private Long peerUserId;
}
