package cn.nine.pros.post.client.model.db;

import cn.nine.commons.data.dto.AbstractAuditableDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@Schema(description = "时光信 DTO（管理端）")
public class TimeLetterDTO extends AbstractAuditableDTO {

    private Long id;
    private Long senderId;
    private Long recipientId;
    private Integer recipientType;
    private String body;
    private LocalDate deliveryDate;
    private String deliveryTz;
    private Integer status;
    private LocalDateTime sealedAt;
    private LocalDateTime deliveredAt;
    private LocalDateTime readAt;
    private Integer stampCost;
    private Boolean starFlag;
    private String failReason;
    private String takedownReason;
}
