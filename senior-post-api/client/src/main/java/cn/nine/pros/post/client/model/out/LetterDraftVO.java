package cn.nine.pros.post.client.model.out;

import cn.nine.pros.post.client.model.json.LetterDraftContent;
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
@Schema(description = "普通信件草稿")
public class LetterDraftVO {

    private Long id;
    private String mode;
    private Long toUserId;
    private LetterDraftContent contentJson;
    private LocalDateTime updatedAt;
}
