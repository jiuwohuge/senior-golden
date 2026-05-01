package cn.nine.pros.post.client.model.db;

import cn.nine.commons.data.dto.AbstractAuditableDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 访客记录表 DTO
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
public class VisitorRecordDTO extends AbstractAuditableDTO {

    private static final long serialVersionUID = 1L;

    /**
     * 记录ID
     */
    @Schema(description = "记录ID")
    private Long id;
    /**
     * 访问者ID
     */
    @Schema(description = "访问者ID")
    private Long visitorId;
    /**
     * 被访问者ID
     */
    @Schema(description = "被访问者ID")
    private Long visitedId;
    /**
     * 访问类型：1查看资料 2查看明信片
     */
    @Schema(description = "访问类型：1查看资料 2查看明信片")
    private Object visitType;

}