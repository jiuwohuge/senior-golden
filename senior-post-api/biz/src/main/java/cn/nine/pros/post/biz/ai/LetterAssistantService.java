package cn.nine.pros.post.biz.ai;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.client.model.input.app.AppLetterAssistantInDto;
import cn.nine.pros.post.client.model.out.AppLetterAssistantVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

/**
 * 信件助手：经 Spring AI 整理用户原文，返回建议稿（由客户端决定是否替换）。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class LetterAssistantService {

    private final ObjectProvider<ChatClient> chatClientProvider;
    private final ObjectProvider<ChatModel> chatModelProvider;
    private final AppMessages appMessages;

    public AppLetterAssistantVO assist(long userId, AppLetterAssistantInDto body) {
        ChatModel chatModel = chatModelProvider.getIfAvailable();
        ChatClient chatClient = chatClientProvider.getIfAvailable();
        if (chatModel == null) {
            log.warn("letter assistant unavailable: ChatModel bean missing (check SPRING_AI_MODEL_CHAT=deepseek)");
            throw new BusinessException(appMessages.get("app.error.letter.assistantUnavailable"));
        }
        // ChatClient 可能因装配顺序未单独成 Bean；有 ChatModel 时现场构建
        if (chatClient == null) {
            chatClient = ChatClient.builder(chatModel).build();
        }
        String source = body.getSourceText() == null ? "" : body.getSourceText().trim();
        if (!StringUtils.hasText(source)) {
            throw new BusinessException(appMessages.get("app.error.letter.contentEmpty"));
        }
        String mode = normalizeMode(body.getHelpMode());
        if ("custom".equals(mode) && !StringUtils.hasText(body.getCustomInstruction())) {
            throw new BusinessException(appMessages.get("app.error.letter.assistantCustomRequired"));
        }
        String targetLang = StringUtils.hasText(body.getTargetLang()) ? body.getTargetLang().trim() : "en";
        String system = systemPromptFor(mode, targetLang);
        String user = buildUserMessage(source, mode, body.getCustomInstruction());

        long start = System.currentTimeMillis();
        try {
            String suggestion = chatClient
                    .prompt()
                    .system(system)
                    .user(user)
                    .call()
                    .content();
            if (!StringUtils.hasText(suggestion)) {
                throw new BusinessException(appMessages.get("app.error.letter.assistantFailed"));
            }
            log.info(
                    "letter assistant ok, userId={}, helpMode={}, elapsedMs={}",
                    userId,
                    mode,
                    System.currentTimeMillis() - start);
            return AppLetterAssistantVO.builder()
                    .suggestion(suggestion.trim())
                    .helpMode(mode)
                    .build();
        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            log.warn("letter assistant failed, userId={}, helpMode={}, err={}", userId, mode, e.getMessage());
            throw new BusinessException(appMessages.get("app.error.letter.assistantFailed"));
        }
    }

    private static String normalizeMode(String raw) {
        if (!StringUtils.hasText(raw)) {
            return "natural";
        }
        String m = raw.trim().toLowerCase();
        return switch (m) {
            case "warmer", "natural", "expand", "polite", "translate", "custom" -> m;
            default -> "natural";
        };
    }

    private static String systemPromptFor(String mode, String targetLang) {
        String base =
                "你是温和的书信助手，帮助中老年用户整理慢邮信件。"
                        + "保留用户事实，不编造经历；语气真诚、简洁、易读；只输出整理后的信件正文，不要解释。";
        return switch (mode) {
            case "warmer" -> base + "任务：让内容更有感情，略增温度，勿夸张煽情。";
            case "expand" -> base + "任务：在事实基础上适度扩展成更完整的小故事，仍保持书信长度。";
            case "polite" -> base + "任务：检查并改得更礼貌得体，去除可能冒犯的说法。";
            case "translate" ->
                    base + "任务：将信件翻译成" + targetLang + "，保持原意与书信语气，只输出译文。";
            case "custom" -> base + "任务：按用户的自定义需求整理原文。";
            default -> base + "任务：让文字更自然流畅，像真人写信。";
        };
    }

    private static String buildUserMessage(String source, String mode, String custom) {
        StringBuilder sb = new StringBuilder();
        sb.append("【用户原文】\n").append(source);
        if ("custom".equals(mode) && StringUtils.hasText(custom)) {
            sb.append("\n\n【自定义需求】\n").append(custom.trim());
        }
        return sb.toString();
    }
}
