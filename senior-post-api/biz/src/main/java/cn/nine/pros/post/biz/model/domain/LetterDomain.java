package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import com.baomidou.mybatisplus.annotation.IdType;
import java.time.LocalDateTime;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

import java.util.Map;

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
@TableName(value = "bu_letter", autoResultMap = true)
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
    @Schema(description = "收件人用户ID（POST_OFFICE 入池时可空）")
    private Long toUserId;
    /**
     * 类型：1挂号信 2平邮（展示形态；速度由 §6.1 决定）
     */
    @Schema(description = "类型：1挂号信 2平邮")
    private Object letterType;
    /**
     * 状态：0待匹配/待启运 1运输中 2已送达 3挂号预留 4已匹配
     */
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

    /**
     * 收件人提前拆信（消耗邮票后运输中可读正文）
     */
    @Schema(description = "收件人提前拆信时间")
    @TableField("recipient_early_open_at")
    private LocalDateTime recipientEarlyOpenAt;

    /**
     * 收件人首次已读（已送达且打开详情；或提前拆信成功时一并写入）
     */
    @Schema(description = "收件人首次已读时间")
    @TableField("recipient_read_at")
    private LocalDateTime recipientReadAt;

    @Schema(description = "皮肤/字体/模板等表达增强元数据")
    @TableField(value = "content_meta_json", typeHandler = JacksonTypeHandler.class)
    private Map<String, Object> contentMetaJson;

}