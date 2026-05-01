package cn.nine.pros.post.client.model.db;

import cn.nine.commons.data.dto.AbstractAuditableDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 举报工单表 DTO
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
public class ReportDTO extends AbstractAuditableDTO {

    private static final long serialVersionUID = 1L;

    /**
     * 举报ID
     */
    @Schema(description = "举报ID")
    private Long id;
    /**
     * 举报人用户ID
     */
    @Schema(description = "举报人用户ID")
    private Long reporterUserId;
    /**
     * 举报对象类型（postcard/comment/letter/user）
     */
    @Schema(description = "举报对象类型（postcard/comment/letter/user）")
    private String targetType;
    /**
     * 举报对象ID
     */
    @Schema(description = "举报对象ID")
    private Long targetId;
    /**
     * 举报原因
     */
    @Schema(description = "举报原因")
    private String reason;
    /**
     * 状态：0待处理 1已处理 2驳回
     */
    @Schema(description = "状态：0待处理 1已处理 2驳回")
    private Object status;
    /**
     * 处理人用户ID
     */
    @Schema(description = "处理人用户ID")
    private Long handlerUserId;
    /**
     * 处理备注
     */
    @Schema(description = "处理备注")
    private String handleNote;

}