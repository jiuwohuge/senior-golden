package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "通信名录用户项")
public class DirectoryUserItemVO {

    @Schema(description = "用户 ID")
    private Long id;

    @Schema(description = "昵称")
    private String nickname;

    @Schema(description = "性别：0未设置 1男 2女 3其他")
    private Integer gender;

    @Schema(description = "国家代码")
    private String countryCode;

    @Schema(description = "简介")
    private String bio;

    @Schema(description = "出生年份")
    private Integer birthYear;

    @Schema(description = "头像 URL")
    private String avatarUrl;

    @Schema(description = "是否 VIP")
    private Boolean isVip;

    @Schema(description = "兴趣标签 ID（与 bu_user_tag / sys_tag 一致）")
    private List<Integer> interestTagIds;

    @Schema(description = "兴趣标签名称（与 sys_tag.tag_name 一致，名录筛选 interestNames 用名）")
    private List<String> interestTagNames;
}
