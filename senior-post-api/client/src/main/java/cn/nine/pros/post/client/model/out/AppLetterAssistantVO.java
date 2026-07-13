package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "信件助手整理结果")
public class AppLetterAssistantVO {

    @Schema(description = "助手整理后的建议正文")
    private String suggestion;

    @Schema(description = "回显帮助模式")
    private String helpMode;
}
