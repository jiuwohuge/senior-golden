package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LetterSyncResultVO {

    @Schema(description = "变更或全量信件列表")
    private List<MailboxLetterItemVO> letters;

    @Schema(description = "服务端时间（客户端对账）")
    private LocalDateTime serverTime;
}
