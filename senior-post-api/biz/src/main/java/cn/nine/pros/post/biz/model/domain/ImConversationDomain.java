package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * IM会话表（腾讯IM） Domain
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName("bu_im_conversation")
public class ImConversationDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    @Schema(description = "会话ID")
    private Long id;
    /**
     * 用户ID
     */
    @Schema(description = "用户ID")
    private Long userId;
    /**
     * 对方用户ID
     */
    @Schema(description = "对方用户ID")
    private Long targetUserId;
    /**
     * 腾讯云端会话ID
     */
    @Schema(description = "腾讯云端会话ID")
    private String imConversationId;
    /**
     * 最后消息时间
     */
    @Schema(description = "最后消息时间")
    private Object lastMessageAt;
    /**
     * 最后消息预览
     */
    @Schema(description = "最后消息预览")
    private String lastMessagePreview;
    /**
     * 未读消息数
     */
    @Schema(description = "未读消息数")
    private Integer unreadCount;

}