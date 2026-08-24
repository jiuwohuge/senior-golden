package cn.nine.pros.post.client.model.json;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 普通信件草稿 content_json。
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown = true)
@Schema(description = "普通信件草稿内容")
public class LetterDraftContent {

    @Schema(description = "正文")
    private String content;

    @Schema(description = "信件物理类型：1挂号 2平邮")
    private Integer letterType;

    @Schema(description = "回信父信件 ID")
    private Long parentLetterId;

    @Schema(description = "信纸皮肤")
    private String skinId;

    @Schema(description = "字体")
    private String fontId;

    @Schema(description = "模板")
    private String templateId;

    @Schema(description = "写信主题邮票 sys_tag.id，可空")
    private Integer topicTagId;

    @Schema(description = "时光信送达日 ISO-8601 日期，可空")
    private String deliveryDate;
}
