package cn.nine.pros.post.biz.moderation.deepseek;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class DeepSeekModerationResultDto {

    private Boolean pass;
    private String severity;
    private Object categories;
    private String reason;

    @Data
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class ChatCompletionResponse {
        private Choice[] choices;
    }

    @Data
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Choice {
        private Message message;
    }

    @Data
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Message {
        private String content;
    }

    @Data
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class ChatCompletionRequest {
        private String model;
        private Message[] messages;
        private double temperature;
        @JsonProperty("response_format")
        private ResponseFormat responseFormat;
    }

    @Data
    public static class ResponseFormat {
        private String type = "json_object";
    }
}
