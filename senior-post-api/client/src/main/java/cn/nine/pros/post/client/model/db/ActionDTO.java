package cn.nine.pros.post.client.model.db;

import cn.nine.commons.data.dto.AbstractAuditableDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 用户行为日志（发布/寄信/加速等） DTO
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
public class ActionDTO extends AbstractAuditableDTO {

    private static final long serialVersionUID = 1L;

    /**
     * 日志ID
     */
    @Schema(description = "日志ID")
    private Long id;
    /**
     * 操作用户ID
     */
    @Schema(description = "操作用户ID")
    private Long userId;
    /**
     * 行为类型
     */
    @Schema(description = "行为类型")
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
     * 详情（JSON格式）
     */
    @Schema(description = "详情（JSON格式）")
    private Object details;

}