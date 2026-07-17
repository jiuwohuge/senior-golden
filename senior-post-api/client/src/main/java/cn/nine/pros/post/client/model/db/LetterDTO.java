package cn.nine.pros.post.client.model.db;

import cn.nine.commons.data.dto.AbstractAuditableDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

import java.time.LocalDateTime;

/**
 * Letter DTO (bu_letter)
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

    @Schema(description = "letter id")
    private Long id;

    @Schema(description = "from user id")
    private Long fromUserId;

    @Schema(description = "to user id (nullable for POST_OFFICE pool)")
    private Long toUserId;

    @Schema(description = "legacy physical type: 1 registered-shape 2 standard")
    private Object letterType;

    @Schema(description = "status: 0PENDING 1DELIVERING 2DELIVERED 3REGISTERED 4MATCHED")
    private Object status;

    @Schema(description = "letter content")
    private String content;

    @Schema(description = "expected arrival time (distance + relationship delay)")
    private Object expectedArrivalTime;

    @Schema(description = "actual arrival time")
    private Object actualArrivalTime;

    @Schema(description = "parent letter id (reply)")
    private Long parentLetterId;

    @Schema(description = "send mode rail (legacy compatibility)")
    private Integer sendMode;

    @Schema(description = "product mode: 1POST_OFFICE 2DIRECT 3SELF_TIME")
    private Integer mode;

    @Schema(description = "audit status: 0PENDING_REVIEW 1APPROVED 2REJECTED")
    private Integer auditStatus;

    @Schema(description = "POST_OFFICE matched at")
    private LocalDateTime matchedAt;

    @Schema(description = "recipient first read at")
    private LocalDateTime recipientReadAt;

}
