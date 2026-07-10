package cn.nine.pros.post.client.model.db;

import cn.nine.commons.data.dto.AbstractAuditableDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 用户主表 DTO
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
public class UserDTO extends AbstractAuditableDTO {

    private static final long serialVersionUID = 1L;

    /**
     * 用户ID
     */
    @Schema(description = "用户ID")
    private Long id;
    /**
     * 邮箱（登录账号）
     */
    @Schema(description = "邮箱（登录账号）")
    private String email;
    /**
     * 密码哈希
     */
    @Schema(description = "密码哈希")
    private String passwordHash;
    /**
     * 昵称
     */
    @Schema(description = "昵称")
    private String nickname;
    /**
     * 性别：0 未设置，1 男，2 女，3 其他
     */
    @Schema(description = "性别")
    private Integer gender;

    /**
     * 出生年份（用于 age 验证）
     */
    @Schema(description = "出生年份（用于年龄验证）")
    private Integer birthYear;
    /**
     * 国家代码
     */
    @Schema(description = "国家代码")
    private String countryCode;
    /**
     * 个人简介
     */
    @Schema(description = "个人简介")
    private String bio;
    /**
     * 头像URL
     */
    @Schema(description = "头像URL")
    private String avatarUrl;
    /**
     * 头像审核：0待审核 1通过 2驳回
     */
    @Schema(description = "头像审核：0待审核 1通过 2驳回")
    private Integer avatarAuditStatus;
    /**
     * 是否VIP会员（冗余）
     */
    @Schema(description = "是否VIP会员（冗余）")
    private Boolean isVip;
    /**
     * VIP过期时间（冗余）
     */
    @Schema(description = "VIP过期时间（冗余）")
    private Object vipExpireAt;
    /**
     * 状态：1正常 2封禁 3注销
     */
    @Schema(description = "状态：1正常 2封禁 3注销")
    private Object status;
    /**
     * 是否可登录管理后台：0 否；非 0 可登录（暂均为超管）
     */
    @Schema(description = "0 不可登录后台；非 0 可登录管理端（暂均为超管）")
    private Integer staffRole;
    /**
     * 注册IP
     */
    @Schema(description = "注册IP")
    private Object registerIp;
    /**
     * 最后登录时间
     */
    @Schema(description = "最后登录时间")
    private Object lastLoginAt;

    @Schema(description = "申请注销时间（冷静期）")
    private java.time.LocalDateTime deletionRequestedAt;

}