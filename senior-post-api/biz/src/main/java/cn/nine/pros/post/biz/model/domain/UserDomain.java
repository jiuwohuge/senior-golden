package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 用户主表 Domain
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName("bu_user")
public class UserDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
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
     * 出生年份（用于年龄验证）
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
     * 邮票余额
     */
    @Schema(description = "邮票余额")
    private Integer stampsBalance;
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
     * 是否可登录管理后台：0 否；非 0 可登录（暂均为超管，不做角色细分）
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

}