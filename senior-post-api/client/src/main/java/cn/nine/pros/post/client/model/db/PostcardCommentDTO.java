package cn.nine.pros.post.client.model.db;

import cn.nine.commons.data.dto.AbstractAuditableDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 明信片评论表 DTO
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
public class PostcardCommentDTO extends AbstractAuditableDTO {

    private static final long serialVersionUID = 1L;

    /**
     * 评论ID
     */
    @Schema(description = "评论ID")
    private Long id;
    /**
     * 明信片ID
     */
    @Schema(description = "明信片ID")
    private Long postcardId;
    /**
     * 评论用户ID
     */
    @Schema(description = "评论用户ID")
    private Long userId;
    /**
     * 评论内容
     */
    @Schema(description = "评论内容")
    private String content;
    /**
     * 状态：1正常 2删除
     */
    @Schema(description = "状态：1正常 2删除")
    private Object status;
    /**
     * 审核状态：0待审核 1通过 2驳回
     */
    @Schema(description = "审核状态：0待审核 1通过 2驳回")
    private Object reviewStatus;

}