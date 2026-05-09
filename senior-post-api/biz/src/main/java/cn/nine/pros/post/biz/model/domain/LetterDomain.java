package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import com.baomidou.mybatisplus.annotation.IdType;
import java.time.LocalDateTime;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 信件表（挂号信/平邮） Domain
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName("bu_letter")
public class LetterDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    @Schema(description = "信件ID")
    private Long id;
    /**
     * 发件人用户ID
     */
    @Schema(description = "发件人用户ID")
    private Long fromUserId;
    /**
     * 收件人用户ID
     */
    @Schema(description = "收件人用户ID")
    private Long toUserId;
    /**
     * 类型：1挂号信（即时） 2平邮（慢信）
     */
    @Schema(description = "类型：1挂号信（即时） 2平邮（慢信）")
    private Object letterType;
    /**
     * 状态：1运输中（仅平邮） 2已送达
     */
    @Schema(description = "状态：1运输中（仅平邮） 2已送达")
    private Object status;
    /**
     * 信件内容
     */
    @Schema(description = "信件内容")
    private String content;
    /**
     * 是否已加速（仅平邮）
     */
    @Schema(description = "是否已加速（仅平邮）")
    private Boolean isAccelerated;
    /**
     * 加速时间
     */
    @Schema(description = "加速时间")
    private Object acceleratedAt;
    /**
     * 预计送达时间（平邮）
     */
    @Schema(description = "预计送达时间（平邮）")
    private Object expectedArrivalTime;
    /**
     * 实际送达时间
     */
    @Schema(description = "实际送达时间")
    private Object actualArrivalTime;
    /**
     * 回复的信件ID（自关联）
     */
    @Schema(description = "回复的信件ID（自关联）")
    private Long parentLetterId;
    /**
     * 发送模式：1平邮路径 2挂号路径 3直发/VIP
     */
    @Schema(description = "发送模式：1平邮路径 2挂号路径 3直发/VIP")
    private Integer sendMode;

    /**
     * 收件人提前拆信（消耗邮票后运输中可读正文）
     */
    @Schema(description = "收件人提前拆信时间")
    @TableField("recipient_early_open_at")
    private LocalDateTime recipientEarlyOpenAt;

}