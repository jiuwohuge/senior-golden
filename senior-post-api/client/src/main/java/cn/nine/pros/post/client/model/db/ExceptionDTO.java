package cn.nine.pros.post.client.model.db;

import cn.nine.commons.data.dto.AbstractAuditableDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 系统异常日志表 DTO
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
public class ExceptionDTO extends AbstractAuditableDTO {

    private static final long serialVersionUID = 1L;

    /**
     * 日志ID
     */
    @Schema(description = "日志ID")
    private Long id;
    /**
     * 用户ID
     */
    @Schema(description = "用户ID")
    private Long userId;
    /**
     * 异常类型
     */
    @Schema(description = "异常类型")
    private String exceptionType;
    /**
     * 错误消息
     */
    @Schema(description = "错误消息")
    private String message;
    /**
     * 堆栈跟踪
     */
    @Schema(description = "堆栈跟踪")
    private String stackTrace;

}