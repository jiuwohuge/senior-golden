package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "信件助手整理结果")
public class AppLetterAssistantVO {

    @Schema(description = "助手整理后的建议正文（润色类）；inspire 时可为空，以话题列表为准")
    private String suggestion;

    @Schema(description = "回显帮助模式：warmer|natural|continue|shorten|inspire")
    private String helpMode;

    @Schema(description = "灵感：可向对方提问的话题（仅 inspire）")
    private List<String> inspireAsk;

    @Schema(description = "灵感：可主动分享的话题（仅 inspire）")
    private List<String> inspireShare;
}
