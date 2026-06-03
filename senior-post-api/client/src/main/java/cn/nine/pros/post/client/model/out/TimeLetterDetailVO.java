package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
@Schema(description = "时光信详情")
public class TimeLetterDetailVO {

    private Long id;
    private Long senderId;
    private Long recipientId;
    private Integer recipientType;
    private Integer status;
    private String body;
    private String contentTag;
    private String emotionTag;
    private String paperTheme;
    private String paperColor;
    private LocalDate deliveryDate;
    private String deliveryTz;
    private LocalDateTime sealedAt;
    private LocalDateTime deliveredAt;
    private LocalDateTime readAt;
    private LocalDateTime cancelDeadlineAt;
    private Boolean starFlag;
    private String writerCity;
    private Integer writeDurationSec;
    private String senderNickname;
    private String senderAvatarUrl;
    private String recipientNickname;
    private String recipientAvatarUrl;
    private Boolean canCancel;
    private Boolean canOpen;
    private Integer estimatedReadMinutes;
}
