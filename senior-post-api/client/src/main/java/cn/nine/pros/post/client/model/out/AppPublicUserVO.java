package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * App 侧返回的用户信息（不含密码等敏感字段）。
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "App 用户公开信息")
public class AppPublicUserVO {

    @Schema(description = "用户ID")
    private Long id;
    @Schema(description = "邮箱")
    private String email;
    @Schema(description = "昵称")
    private String nickname;
    @Schema(description = "出生年份")
    private Integer birthYear;
    @Schema(description = "国家代码")
    private String countryCode;
    @Schema(description = "简介")
    private String bio;
    @Schema(description = "头像 URL")
    private String avatarUrl;
    @Schema(description = "邮票余额")
    private Integer stampsBalance;
    @Schema(description = "是否 VIP")
    private Boolean isVip;

    @Schema(description = "用户已选兴趣标签 ID（与 bu_user_tag.tag_id 一致）")
    private List<Integer> interestTagIds;

    @Schema(description = "用户已选兴趣标签名称（展示用，与 sys_tag.tag_name 一致）")
    private List<String> interestTagNames;
}
