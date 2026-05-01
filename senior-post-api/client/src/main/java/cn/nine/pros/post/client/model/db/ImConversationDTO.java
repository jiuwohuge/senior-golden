package cn.nine.pros.post.client.model.db;

import cn.nine.commons.data.dto.AbstractAuditableDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * IM会话表（腾讯IM） DTO
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
public class ImConversationDTO extends AbstractAuditableDTO {

    private static final long serialVersionUID = 1L;

    /**
     * 会话ID
     */
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