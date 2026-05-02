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
    @Schema(description = "1挂号 2平邮")
    private Integer letterType;
    @Schema(description = "发送模式：1平邮路径 2挂号路径 3直发")
    private Integer sendMode;
    @Schema(description = "1运输中 2已送达 3已挂号")
    private Integer status;
    @Schema(description = "列表摘要")
    private String preview;
    @Schema(description = "是否本人发出")
    private Boolean fromMe;
    @Schema(description = "发送时间")
    private LocalDateTime sentAt;
    @Schema(description = "更新时间（同步用）")
    private LocalDateTime updatedAt;
}
