package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import com.baomidou.mybatisplus.annotation.IdType;
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
 * 推送投递结果 Domain（{@code bu_notification_delivery}）。
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName("bu_notification_delivery")
public class NotificationDeliveryDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long outboxId;

    private Long endpointId;

    private Long userId;

    private String fcmMessageId;

    @Schema(description = "mock_sent|sent|failed|skipped")
    private String sendStatus;

    private String errorMessage;

    @Schema(description = "mock|fcm")
    private String provider;

    private LocalDateTime sentAt;
}
