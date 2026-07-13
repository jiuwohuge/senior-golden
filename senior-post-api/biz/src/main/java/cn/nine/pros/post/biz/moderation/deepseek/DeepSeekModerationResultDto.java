package cn.nine.pros.post.biz.moderation.deepseek;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

/**
 * LLM 文本机审 JSON 响应体（经 Spring AI 返回的 assistant 内容解析）。
 */
@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class DeepSeekModerationResultDto {

    private Boolean pass;
    private String severity;
    private Object categories;
    private String reason;
}
