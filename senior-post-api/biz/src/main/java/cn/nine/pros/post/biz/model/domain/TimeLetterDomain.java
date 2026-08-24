package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName(value = "bu_time_letter", autoResultMap = true)
public class TimeLetterDomain extends AbstractAuditableDomain {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long senderId;
    private Long recipientId;
    private Integer recipientType;
    private String body;
    private String contentTag;
    private String emotionTag;
    private String paperTheme;
    private String paperColor;
    private LocalDate deliveryDate;
    private String deliveryTz;
    private Integer status;
    private LocalDateTime sealedAt;
    private LocalDateTime deliveredAt;
    private LocalDateTime readAt;
    private LocalDateTime cancelDeadlineAt;
    private LocalDateTime cancelledAt;
    private Integer stampCost;

    @TableField(value = "sender_snapshot_json", typeHandler = JacksonTypeHandler.class)
    private Map<String, Object> senderSnapshotJson;

    private String writerCity;
    private Integer writeDurationSec;
    private Integer privacyLevel;
    private Boolean starFlag;
    private Long replyToId;
    private String sealRequestId;
    private String failReason;
    private String takedownReason;

    /** 写信主题邮票，可空；本轮匹配不读此列。 */
    private Integer topicTagId;
}
