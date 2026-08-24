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
@Schema(description = "写信主题邮票选项")
public class LetterTopicOptionVO {

    @Schema(description = "sys_tag.id，客户端发信时回传 topicTagId")
    private Integer id;

    @Schema(description = "稳定业务码，如 heart_talk")
    private String code;

    @Schema(description = "展示文案（已按请求语言）")
    private String title;
}
