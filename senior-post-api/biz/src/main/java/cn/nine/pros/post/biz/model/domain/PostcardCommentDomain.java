package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 明信片评论表 Domain
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName("bu_postcard_comment")
public class PostcardCommentDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
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

    @Schema(description = "父评论ID，顶级为 NULL")
    private Long parentId;

    @Schema(description = "所属顶级评论ID")
    private Long rootId;

    @Schema(description = "被回复用户ID")
    private Long replyToUserId;

    @Schema(description = "点赞数")
    private Integer likeCount;

}