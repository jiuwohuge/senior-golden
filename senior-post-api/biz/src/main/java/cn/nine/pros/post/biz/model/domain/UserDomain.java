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
     * 性别：0 未设置，1 男，2 女
     */
    @Schema(description = "性别：0未设置 1男 2女")
    private Integer gender;

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
    @Schema(description = "城市/地区")
    private String city;
    @Schema(description = "纬度")
    private Double latitude;
    @Schema(description = "经度")
    private Double longitude;
    @Schema(description = "用户语言标签，如 zh-CN")
    private String language;
    @Schema(description = "写作风格：concise|narrative|emotional")
    private String writingStyle;
    @Schema(description = "邮箱是否已验证绑定")
    private Boolean emailVerified;
    @Schema(description = "是否已完成首封信引导")
    private Boolean firstLetterDone;
    @Schema(description = "开户方式：guest | email | google")
    private String signupChannel;
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
    /**
     * 用户申请账号注销的时间（冷静期起点）；成功登录可清空。
     */
    @Schema(description = "申请注销时间")
    private java.time.LocalDateTime deletionRequestedAt;

}