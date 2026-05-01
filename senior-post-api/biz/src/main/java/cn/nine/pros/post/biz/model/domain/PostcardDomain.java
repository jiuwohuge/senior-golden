package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 明信片墙表（用户发布的公开明信片） Domain
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName("bu_postcard")
public class PostcardDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    @Schema(description = "明信片ID")
    private Long id;
    /**
     * 发布用户ID
     */
    @Schema(description = "发布用户ID")
    private Long userId;
    /**
     * 文字内容
     */
    @Schema(description = "文字内容")
    private String content;
    /**
     * 图片URL数组
     */
    @Schema(description = "图片URL数组")
    private Object images;
    /**
     * 状态：1公开 2隐藏 3违规删除
     */
    @Schema(description = "状态：1公开 2隐藏 3违规删除")
    private Object status;
    /**
     * 审核状态：0待审核 1通过 2驳回
     */
    @Schema(description = "审核状态：0待审核 1通过 2驳回")
    private Object reviewStatus;
    /**
     * 发布时间
     */
    @Schema(description = "发布时间")
    private Object publishedAt;

}