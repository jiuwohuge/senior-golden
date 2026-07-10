package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MailboxLetterItemVO {

    @Schema(description = "信件ID")
    private Long letterId;
    @Schema(description = "对端用户")
    private AppPublicUserVO peer;
    @Schema(description = "信件载体类型，整型同 LetterPhysicalType：1=REGISTERED（挂号）2=STANDARD（平邮）")
    private Integer letterType;
    @Schema(description = "发送模式，整型同 LetterSendMode：1=STANDARD_POST 2=REGISTERED_MAIL 3=DIRECT_VIP")
    private Integer sendMode;
    @Schema(description = "业务状态，整型同 LetterBizStatus：0=PENDING 1=DELIVERING 2=DELIVERED 3=REGISTERED 4=MATCHED")
    private Integer status;
    @Schema(description = "产品模式，整型同 LetterMode：1=POST_OFFICE 2=DIRECT 3=SELF_TIME")
    private Integer mode;
    @Schema(description = "审核状态，整型同 LetterAuditStatus：0=PENDING_REVIEW 1=APPROVED 2=REJECTED")
    private Integer auditStatus;
    @Schema(description = "列表摘要")
    private String preview;
    @Schema(description = "全文（仅详情接口返回；列表为 null 以省流量）")
    private String content;
    @Schema(description = "是否本人发出")
    private Boolean fromMe;
    @Schema(description = "发送时间")
    private LocalDateTime sentAt;
    @Schema(description = "更新时间（同步用）")
    private LocalDateTime updatedAt;

    @Schema(description = "预计送达时间（平邮运输中）")
    private LocalDateTime expectedArrivalTime;

    @Schema(description = "实际送达时间")
    private LocalDateTime actualArrivalTime;

    @Schema(description = "收件人视角：运输中平邮正文是否隐藏（提前拆信后为 false）")
    private Boolean contentHidden;

    @Schema(description = "与对端关系展示态，整型同 RelationDisplayState")
    private Integer relationDisplayState;

    @Schema(description = "是否可添加笔友")
    private Boolean canAddPenpal;

    @Schema(description = "收件人是否已读")
    private Boolean recipientRead;
}
