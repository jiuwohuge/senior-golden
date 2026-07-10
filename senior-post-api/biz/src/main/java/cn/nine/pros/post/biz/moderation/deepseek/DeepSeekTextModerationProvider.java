package cn.nine.pros.post.biz.moderation.deepseek;

import cn.nine.pros.post.biz.config.ModerationProperties;
import cn.nine.pros.post.biz.moderation.ModerationVerdict;
import cn.nine.pros.post.biz.moderation.TextModerationProvider;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnExpression;
import org.springframework.http.MediaType;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestClient;

import java.util.Locale;

@Slf4j
@Component
@ConditionalOnExpression("'${senior-post.moderation.deepseek.api-key:}'.length() > 0")
public class DeepSeekTextModerationProvider implements TextModerationProvider {

    private static final int MAX_CONTENT_LEN = 2000;

    private final RestClient restClient;
    private final ObjectMapper objectMapper;
    private final ModerationProperties.Deepseek deepseek;
    private final String systemPrompt;

    public DeepSeekTextModerationProvider(ModerationProperties moderationProperties, ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
        this.deepseek = moderationProperties.getDeepseek();
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(deepseek.getConnectTimeoutMs());
        factory.setReadTimeout(deepseek.getReadTimeoutMs());
        String base = deepseek.getBaseUrl().trim().replaceAll("/+$", "");
        this.restClient = RestClient.builder().baseUrl(base).requestFactory(factory).build();
        this.systemPrompt = loadSystemPrompt();
    }

    @Override
    public TextModerationResult auditText(String content) {
        if (!StringUtils.hasText(content)) {
            return TextModerationResult.of(ModerationVerdict.PASS, "none", "", "");
        }
        String text = content.trim();
        if (text.length() > MAX_CONTENT_LEN) {
            text = text.substring(0, MAX_CONTENT_LEN);
        }
        try {
            DeepSeekModerationResultDto.ChatCompletionRequest req = buildRequest(text);
            String body = objectMapper.writeValueAsString(req);
            String responseJson = restClient
                    .post()
                    .uri("/v1/chat/completions")
                    .contentType(MediaType.APPLICATION_JSON)
                    .header("Authorization", "Bearer " + deepseek.getApiKey().trim())
                    .body(body)
                    .retrieve()
                    .body(String.class);
            DeepSeekModerationResultDto.ChatCompletionResponse completion =
                    objectMapper.readValue(responseJson, DeepSeekModerationResultDto.ChatCompletionResponse.class);
            if (completion.getChoices() == null || completion.getChoices().length == 0) {
                return TextModerationResult.of(ModerationVerdict.ERROR, "", "", "empty choices");
            }
            String assistant = completion.getChoices()[0].getMessage().getContent();
            DeepSeekModerationResultDto parsed =
                    objectMapper.readValue(assistant, DeepSeekModerationResultDto.class);
            return mapVerdict(parsed);
        } catch (Exception e) {
            log.warn("DeepSeek text moderation failed: {}", e.getMessage());
            return TextModerationResult.of(ModerationVerdict.ERROR, "", "", e.getMessage());
        }
    }

    private TextModerationResult mapVerdict(DeepSeekModerationResultDto parsed) {
        if (parsed == null || parsed.getPass() == null) {
            return TextModerationResult.of(ModerationVerdict.ERROR, "", "", "invalid json");
        }
        if (Boolean.TRUE.equals(parsed.getPass())) {
            return TextModerationResult.of(ModerationVerdict.PASS, "none", "", "");
        }
        String severity = parsed.getSeverity() == null ? "low" : parsed.getSeverity().trim().toLowerCase(Locale.ROOT);
        String categories = parsed.getCategories() == null ? "" : String.valueOf(parsed.getCategories());
        String reason = parsed.getReason() == null ? "" : parsed.getReason().trim();
        ModerationVerdict verdict = "high".equals(severity) ? ModerationVerdict.REJECT : ModerationVerdict.REVIEW;
        return TextModerationResult.of(verdict, severity, categories, reason);
    }

    private DeepSeekModerationResultDto.ChatCompletionRequest buildRequest(String userText) {
        DeepSeekModerationResultDto.ChatCompletionRequest req = new DeepSeekModerationResultDto.ChatCompletionRequest();
        req.setModel(deepseek.getModel());
        req.setTemperature(0);
        req.setResponseFormat(new DeepSeekModerationResultDto.ResponseFormat());
        DeepSeekModerationResultDto.Message system = new DeepSeekModerationResultDto.Message();
        system.setContent(systemPrompt);
        DeepSeekModerationResultDto.Message user = new DeepSeekModerationResultDto.Message();
        user.setContent(userText);
        req.setMessages(new DeepSeekModerationResultDto.Message[] {system, user});
        return req;
    }

    private static final String DEFAULT_SYSTEM_PROMPT =
            "Respond JSON only: {\"pass\":boolean,\"severity\":\"none|low|high\",\"categories\":[],\"reason\":\"\"}";

    private static String loadSystemPrompt() {
        return DEFAULT_SYSTEM_PROMPT;
    }
}
