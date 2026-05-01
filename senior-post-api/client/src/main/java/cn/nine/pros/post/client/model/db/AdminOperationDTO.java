package cn.nine.pros.post.client.model.db;

import cn.nine.commons.data.dto.AbstractAuditableDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 管理员操作日志表 DTO
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
public class AdminOperationDTO extends AbstractAuditableDTO {

    private static final long serialVersionUID = 1L;

    /**
     * 日志ID
     */
    @Schema(description = "日志ID")
    private Long id;
    /**
     * 管理员ID
     */
    @Schema(description = "管理员ID")
    private Long adminId;
    /**
     * 操作类型
     */
    @Schema(description = "操作类型")
    private String actionType;
    /**
     * 目标类型
     */
    @Schema(description = "目标类型")
    private String targetType;
    /**
     * 目标ID
     */
    @Schema(description = "目标ID")
    private Long targetId;
    /**
     * 操作详情
     */
    @Schema(description = "操作详情")
    private Object details;
    /**
     * IP地址
     */
    @Schema(description = "IP地址")
    private Object ipAddress;

}