package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 用户行为日志（发布/寄信/加速等） Domain
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName("log_action")
public class ActionDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
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