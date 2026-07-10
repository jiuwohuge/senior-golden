package cn.nine.pros.post.client.model.input.app;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.util.Map;

@Data
@Schema(description = "普通信件草稿保存")
public class LetterDraftSaveInDto {

    @Schema(description = "草稿 ID（更新时传入）")
    private Long id;

    @Schema(description = "发信模式 DIRECT|POST_OFFICE")
    private String mode;

    @Schema(description = "收件人用户 ID（DIRECT）")
    private Long toUserId;

    @Schema(description = "草稿内容 JSON（含 content、letterType 等）")
    private Map<String, Object> contentJson;
}
