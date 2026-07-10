package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 登录日志表 Domain
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName("log_login")
public class LoginDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    @Schema(description = "日志ID")
    private Long id;
    /**
     * 用户ID（登录成功时有值）
     */
    @Schema(description = "用户ID（登录成功时有值）")
    private Long userId;
    /**
     * 登录IP
     */
    @Schema(description = "登录IP")
    private Object loginIp;
    /**
     * 设备UUID
     */
    @Schema(description = "设备UUID")
    private String deviceUuid;
    /**
     * 结果：1成功 2失败
     */
    @Schema(description = "结果：1成功 2失败")
    private Object loginResult;
    /**
     * 失败原因
     */
    @Schema(description = "失败原因")
    private String failReason;

    @Schema(description = "客户端 User-Agent")
    private String userAgent;

    @Schema(description = "登录 IP 国家码")
    private String ipCountry;

    @Schema(description = "风险：0无 1轻 2中 3高")
    private Integer riskLevel;

}