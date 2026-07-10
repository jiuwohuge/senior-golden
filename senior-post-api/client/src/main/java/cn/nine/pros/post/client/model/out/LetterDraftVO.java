package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "普通信件草稿")
public class LetterDraftVO {

    private Long id;
    private String mode;
    private Long toUserId;
    private Map<String, Object> contentJson;
    private LocalDateTime updatedAt;
}
