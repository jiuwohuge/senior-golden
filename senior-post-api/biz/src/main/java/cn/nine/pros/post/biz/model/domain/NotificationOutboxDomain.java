package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import cn.nine.pros.post.biz.support.mybatis.PostgresJsonbTypeHandler;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.time.LocalDateTime;

/**
 * 推送通知 Outbox Domain（{@code bu_notification_outbox}）。
 * <p>仅信件事件；支付类 event_type 在入队层拒绝。
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName(value = "bu_notification_outbox", autoResultMap = true)
public class NotificationOutboxDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    @Schema(description = "letter_matched_in_transit|letter_arrived")
    private String eventType;

    private Long recipientUserId;

    private String templateKey;

    private String title;

    private String body;

    @Schema(description = "payload JSON（含 eventType/letterId/route/screen）")
    @TableField(value = "payload_json", typeHandler = PostgresJsonbTypeHandler.class)
    private Object payloadJson;

    @Schema(description = "幂等键")
    private String dedupeKey;

    @Schema(description = "pending|processing|sent|failed|cancelled")
    private String status;

    private Integer attempts;

    private LocalDateTime nextRetryAt;

    private String lastError;

    private LocalDateTime scheduledAt;

    private LocalDateTime processedAt;
}
