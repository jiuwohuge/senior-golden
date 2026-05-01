package cn.nine.pros.post.client.model.db;

import cn.nine.commons.data.dto.AbstractAuditableDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * IM消息表 DTO
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
public class ImMessageDTO extends AbstractAuditableDTO {

    private static final long serialVersionUID = 1L;

    /**
     * 消息ID
     */
    @Schema(description = "消息ID")
    private Long id;
    /**
     * 会话ID
     */
    @Schema(description = "会话ID")
    private Long conversationId;
    /**
     * 发送者ID
     */
    @Schema(description = "发送者ID")
    private Long senderId;
    /**
     * 消息类型：1文本 2图片 3语音
     */
    @Schema(description = "消息类型：1文本 2图片 3语音")
    private Object msgType;
    /**
     * 消息内容
     */
    @Schema(description = "消息内容")
    private String content;
    /**
     * 腾讯云端消息ID
     */
    @Schema(description = "腾讯云端消息ID")
    private String imMsgId;
    /**
     * 状态：1已发送 2已读
     */
    @Schema(description = "状态：1已发送 2已读")
    private Object status;

}