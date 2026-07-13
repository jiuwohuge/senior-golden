package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 邮政 Tab「Connections」好友列表行：数据来源为 {@code bu_friendship}（活跃建联）。
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "邮政好友（笔友）列表项")
public class MailboxFriendItemVO {

    @Schema(description = "好友关系ID")
    private Long friendshipId;

    @Schema(description = "对端用户业务 ID（与 IM userId 一致）")
    private Long peerUserId;

    @Schema(description = "对端昵称")
    private String peerNickname;

    @Schema(description = "对端头像 URL（可能为短时 GET 预签名）")
    private String peerAvatarUrl;

    @Schema(description = "对端国家码 ISO alpha-2")
    private String peerCountryCode;

    @Schema(description = "建联生效时间（取好友关系审计时间）")
    private LocalDateTime connectedAt;
}
