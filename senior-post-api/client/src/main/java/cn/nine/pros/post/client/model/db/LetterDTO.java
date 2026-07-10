package cn.nine.pros.post.client.model.db;

import cn.nine.commons.data.dto.AbstractAuditableDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

import java.time.LocalDateTime;

/**
 * 信件表（挂号信/平邮） DTO
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
public class LetterDTO extends AbstractAuditableDTO {

    private static final long serialVersionUID = 1L;

    /**
     * 信件ID
     */
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
    @Schema(description = "收件人用户ID（POST_OFFICE 可空）")
    private Long toUserId;
    @Schema(description = "类型：1挂号信 2平邮")
    private Object letterType;
    @Schema(description = "状态：0PENDING 1DELIVERING 2DELIVERED 3REGISTERED 4MATCHED")
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
    @Schema(description = "发送模式（运输轨）：1平邮路径 2挂号路径 3直发/VIP")
    private Integer sendMode;

    @Schema(description = "产品模式：1POST_OFFICE 2DIRECT 3SELF_TIME")
    private Integer mode;

    @Schema(description = "审核状态：0PENDING_REVIEW 1APPROVED 2REJECTED")
    private Integer auditStatus;

    @Schema(description = "POST_OFFICE 匹配成功时间")
    private LocalDateTime matchedAt;

    @Schema(description = "收件人提前拆信时间")
    private LocalDateTime recipientEarlyOpenAt;

    @Schema(description = "收件人首次已读时间")
    private LocalDateTime recipientReadAt;

}