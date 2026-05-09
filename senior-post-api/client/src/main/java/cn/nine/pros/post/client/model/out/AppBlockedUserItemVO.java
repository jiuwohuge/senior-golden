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
@Schema(description = "黑名单列表项")
public class AppBlockedUserItemVO {

    @Schema(description = "被拉黑用户 ID")
    private Long blockedUserId;

    @Schema(description = "对端资料（头像等已换签）")
    private AppPublicUserVO peer;

    @Schema(description = "拉黑时间")
    private LocalDateTime blockedAt;
}
