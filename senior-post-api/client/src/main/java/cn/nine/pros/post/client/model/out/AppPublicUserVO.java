package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import java.time.LocalDateTime;
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

    @Schema(description = "性别：0未设置 1男 2女 3其他")
    private Integer gender;
    @Schema(description = "出生年份")
    private Integer birthYear;
    @Schema(description = "国家代码")
    private String countryCode;
    @Schema(description = "简介")
    private String bio;
    @Schema(description = "头像 URL")
    private String avatarUrl;
    @Schema(description = "头像审核：0待审核 1通过 2驳回（仅本人资料接口返回）")
    private Integer avatarAuditStatus;
    @Schema(description = "邮票余额")
    private Integer stampsBalance;
    @Schema(description = "是否 VIP")
    private Boolean isVip;

    @Schema(description = "用户已选兴趣标签 ID（与 bu_user_tag.tag_id 一致）")
    private List<Integer> interestTagIds;

    @Schema(description = "用户已选兴趣标签名称（展示用，与 sys_tag.tag_name 一致）")
    private List<String> interestTagNames;

    @Schema(description = "申请注销时间（未申请则为 null）")
    private LocalDateTime deletionRequestedAt;

    @Schema(description = "注销预计生效时间（申请时间+7天，仅当 deletionRequestedAt 非空时有值）")
    private LocalDateTime deletionEffectiveAt;
}
