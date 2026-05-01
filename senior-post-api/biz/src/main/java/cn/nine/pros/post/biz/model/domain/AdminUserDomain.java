package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 管理员表 Domain
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName("bu_admin_user")
public class AdminUserDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    @Schema(description = "管理员ID")
    private Long id;
    /**
     * 管理员用户名
     */
    @Schema(description = "管理员用户名")
    private String username;
    /**
     * 密码哈希
     */
    @Schema(description = "密码哈希")
    private String passwordHash;
    /**
     * 管理员昵称
     */
    @Schema(description = "管理员昵称")
    private String nickname;
    /**
     * 角色：1超级管理员 2普通管理员
     */
    @Schema(description = "角色：1超级管理员 2普通管理员")
    private Object role;
    /**
     * 状态：1正常 2禁用
     */
    @Schema(description = "状态：1正常 2禁用")
    private Object status;
    /**
     * 最后登录时间
     */
    @Schema(description = "最后登录时间")
    private Object lastLoginAt;
    /**
     * 最后登录IP
     */
    @Schema(description = "最后登录IP")
    private Object lastLoginIp;

}