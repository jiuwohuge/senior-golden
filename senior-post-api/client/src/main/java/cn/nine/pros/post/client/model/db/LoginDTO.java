package cn.nine.pros.post.client.model.db;

import cn.nine.commons.data.dto.AbstractAuditableDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 登录日志表 DTO
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
public class LoginDTO extends AbstractAuditableDTO {

    private static final long serialVersionUID = 1L;

    /**
     * 日志ID
     */
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

}