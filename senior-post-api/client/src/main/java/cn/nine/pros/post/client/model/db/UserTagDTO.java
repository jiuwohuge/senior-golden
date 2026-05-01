package cn.nine.pros.post.client.model.db;

import cn.nine.commons.data.dto.AbstractAuditableDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 用户兴趣标签关联表 DTO
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
public class UserTagDTO extends AbstractAuditableDTO {

    private static final long serialVersionUID = 1L;

    /**
     * 关联ID
     */
    @Schema(description = "关联ID")
    private Long id;
    /**
     * 用户ID
     */
    @Schema(description = "用户ID")
    private Long userId;
    /**
     * 标签ID
     */
    @Schema(description = "标签ID")
    private Integer tagId;

}