package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import cn.nine.pros.post.biz.support.mybatis.PostgresJsonbTypeHandler;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 管理员操作日志表 Domain
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName(value = "log_admin_operation", autoResultMap = true)
public class AdminOperationDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
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
     * 操作详情（DB 列为 jsonb；写入需 PostgresJsonbTypeHandler，避免 varchar/jsonb 类型不匹配）
     */
    @Schema(description = "操作详情")
    @TableField(value = "details", typeHandler = PostgresJsonbTypeHandler.class)
    private Object details;
    /**
     * IP地址
     */
    @Schema(description = "IP地址")
    private Object ipAddress;

}