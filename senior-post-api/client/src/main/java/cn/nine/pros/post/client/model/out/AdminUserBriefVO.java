package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 管理端列表用的用户摘要（头像+昵称）。
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "用户摘要")
public class AdminUserBriefVO {

    @Schema(description = "用户ID")
    private Long id;

    @Schema(description = "昵称")
    private String nickname;

    @Schema(description = "头像 objectKey 或 URL")
    private String avatarUrl;
}
