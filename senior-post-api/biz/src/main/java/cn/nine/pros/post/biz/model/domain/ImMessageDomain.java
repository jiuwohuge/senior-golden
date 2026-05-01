package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * IM消息表 Domain
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName("bu_im_message")
public class ImMessageDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
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