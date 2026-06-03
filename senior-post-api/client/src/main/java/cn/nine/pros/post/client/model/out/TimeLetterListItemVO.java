package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
@Schema(description = "时光信列表项")
public class TimeLetterListItemVO {

    private Long id;
    private Long senderId;
    private Long recipientId;
    private Integer recipientType;
    private Integer status;
    private String bodyPreview;
    private LocalDate deliveryDate;
    private String deliveryTz;
    private LocalDateTime sealedAt;
    private LocalDateTime deliveredAt;
    private LocalDateTime readAt;
    private LocalDateTime cancelDeadlineAt;
    private Boolean starFlag;
    private String contentTag;
    private String emotionTag;
    private String peerNickname;
    private String peerAvatarUrl;
    private Integer daysUntilDelivery;
    private Boolean canCancel;
}
