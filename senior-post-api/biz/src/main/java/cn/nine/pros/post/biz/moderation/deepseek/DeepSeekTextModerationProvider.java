package cn.nine.pros.post.biz.moderation.deepseek;

import cn.nine.pros.post.biz.moderation.ModerationVerdict;
import cn.nine.pros.post.biz.moderation.TextModerationProvider;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.boot.autoconfigure.condition.ConditionalOnBean;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.util.Locale;

/**
 * 文本机审：经 Spring AI {@link ChatModel} 调用 LLM，解析 JSON 判定结果。
 * <p>与 {@link NoOpTextModerationProvider} 互斥（有 ChatModel Bean 时启用）。
 */
@Slf4j
@Component
@ConditionalOnBean(ChatModel.class)
public class DeepSeekTextModerationProvider implements TextModerationProvider {

    private static final int MAX_CONTENT_LEN = 2000;

    private static final String SYSTEM_PROMPT =
            "Respond JSON only: {\"pass\":boolean,\"severity\":\"none|low|high\",\"categories\":[],\"reason\":\"\"}";

    private final ChatClient chatClient;
    private final ObjectMapper objectMapper;

    public DeepSeekTextModerationProvider(ChatClient letterChatClient, ObjectMapper objectMapper) {
        this.chatClient = letterChatClient;
        this.objectMapper = objectMapper;
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
        long start = System.currentTimeMillis();
        try {
            String assistant = chatClient.prompt()
                    .system(SYSTEM_PROMPT)
                    .user(text)
                    .call()
                    .content();
            if (!StringUtils.hasText(assistant)) {
                return TextModerationResult.of(ModerationVerdict.ERROR, "", "", "empty assistant");
            }
            String json = stripCodeFence(assistant.trim());
            DeepSeekModerationResultDto parsed =
                    objectMapper.readValue(json, DeepSeekModerationResultDto.class);
            log.info("text moderation via Spring AI done, elapsedMs={}", System.currentTimeMillis() - start);
            return mapVerdict(parsed);
        } catch (Exception e) {
            log.warn("Spring AI text moderation failed: {}", e.getMessage());
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
        String severity = parsed.getSeverity() == null
                ? "low"
                : parsed.getSeverity().trim().toLowerCase(Locale.ROOT);
        String categories = parsed.getCategories() == null ? "" : String.valueOf(parsed.getCategories());
        String reason = parsed.getReason() == null ? "" : parsed.getReason().trim();
        ModerationVerdict verdict = "high".equals(severity) ? ModerationVerdict.REJECT : ModerationVerdict.REVIEW;
        return TextModerationResult.of(verdict, severity, categories, reason);
    }

    /** 模型偶发包 markdown 代码块时剥掉。 */
    private static String stripCodeFence(String raw) {
        if (!raw.startsWith("```")) {
            return raw;
        }
        int firstNl = raw.indexOf('\n');
        int lastFence = raw.lastIndexOf("```");
        if (firstNl > 0 && lastFence > firstNl) {
            return raw.substring(firstNl + 1, lastFence).trim();
        }
        return raw;
    }
}
