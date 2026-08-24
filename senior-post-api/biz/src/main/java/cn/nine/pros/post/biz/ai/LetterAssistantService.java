package cn.nine.pros.post.biz.ai;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.client.model.input.app.AppLetterAssistantInDto;
import cn.nine.pros.post.client.model.out.AppLetterAssistantVO;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.List;

/**
 * 信件助手：经 Spring AI 润色正文或生成灵感话题（由客户端决定是否替换/追加）。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class LetterAssistantService {

    private final ObjectProvider<ChatClient> chatClientProvider;
    private final ObjectProvider<ChatModel> chatModelProvider;
    private final AppMessages appMessages;
    private final ObjectMapper objectMapper;

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
        String mode = normalizeMode(body.getHelpMode());
        String language = normalizeLanguage(body.getTargetLang());
        // 润色必须有原文；灵感允许空白信纸，给开场话题。
        if (!StringUtils.hasText(source) && !"inspire".equals(mode)) {
            throw new BusinessException(appMessages.get("app.error.letter.contentEmpty"));
        }
        String system = systemPromptFor(mode, language);
        String user = StringUtils.hasText(source)
                ? "【用户原文】\n" + source
                : "【用户原文】\n（尚未落笔。请给出适合刚展开信纸、还没想好写什么的中老年慢邮开场话题。）";

        long start = System.currentTimeMillis();
        try {
            String raw = chatClient
                    .prompt()
                    .system(system)
                    .user(user)
                    .call()
                    .content();
            if (!StringUtils.hasText(raw)) {
                throw new BusinessException(appMessages.get("app.error.letter.assistantFailed"));
            }
            AppLetterAssistantVO vo = buildResult(mode, language, raw.trim());
            log.info(
                    "letter assistant ok, userId={}, helpMode={}, language={}, elapsedMs={}",
                    userId,
                    mode,
                    language,
                    System.currentTimeMillis() - start);
            return vo;
        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            log.warn("letter assistant failed, userId={}, helpMode={}, err={}", userId, mode, e.getMessage());
            throw new BusinessException(appMessages.get("app.error.letter.assistantFailed"));
        }
    }

    /**
     * 将模型输出映射为 VO；inspire 优先解析 JSON 话题列表。
     */
    private AppLetterAssistantVO buildResult(String mode, String language, String raw) {
        if ("inspire".equals(mode)) {
            InspireTopics topics = parseInspireTopics(raw);
            return AppLetterAssistantVO.builder()
                    .helpMode(mode)
                    .suggestion(formatInspireSuggestion(topics, language))
                    .inspireAsk(topics.ask())
                    .inspireShare(topics.share())
                    .build();
        }
        return AppLetterAssistantVO.builder()
                .suggestion(raw)
                .helpMode(mode)
                .build();
    }

    private InspireTopics parseInspireTopics(String raw) {
        String json = stripCodeFence(raw);
        try {
            JsonNode root = objectMapper.readTree(json);
            List<String> ask = readStringList(root.get("ask"));
            List<String> share = readStringList(root.get("share"));
            if (!ask.isEmpty() || !share.isEmpty()) {
                return new InspireTopics(ask, share);
            }
        } catch (Exception e) {
            log.debug("inspire JSON parse fallback to lines: {}", e.getMessage());
        }
        // 降级：按行拆纯文本
        List<String> lines = new ArrayList<>();
        for (String line : raw.split("\\R")) {
            String t = line.replaceFirst("^[•\\-\\d\\.\\s]+", "").trim();
            if (StringUtils.hasText(t) && t.length() < 120) {
                lines.add(t);
            }
        }
        List<String> ask = lines.size() > 3 ? lines.subList(0, 3) : lines;
        List<String> share = lines.size() > 3
                ? lines.subList(3, Math.min(6, lines.size()))
                : List.of();
        return new InspireTopics(new ArrayList<>(ask), new ArrayList<>(share));
    }

    private static List<String> readStringList(JsonNode node) {
        List<String> out = new ArrayList<>();
        if (node == null || !node.isArray()) {
            return out;
        }
        for (JsonNode n : node) {
            if (n != null && n.isTextual() && StringUtils.hasText(n.asText())) {
                out.add(n.asText().trim());
            }
        }
        return out;
    }

    private static String formatInspireSuggestion(InspireTopics topics, String language) {
        StringBuilder sb = new StringBuilder();
        if (!topics.ask().isEmpty()) {
            sb.append("en".equals(language) ? "You could ask:\n" : "可以问问对方：\n");
            for (String a : topics.ask()) {
                sb.append("• ").append(a).append('\n');
            }
        }
        if (!topics.share().isEmpty()) {
            if (!sb.isEmpty()) {
                sb.append('\n');
            }
            sb.append("en".equals(language) ? "You could share:\n" : "还可以分享：\n");
            for (String s : topics.share()) {
                sb.append("• ").append(s).append('\n');
            }
        }
        return sb.toString().trim();
    }

    private static String stripCodeFence(String raw) {
        String t = raw.trim();
        if (!t.startsWith("```")) {
            return t;
        }
        int firstNl = t.indexOf('\n');
        if (firstNl < 0) {
            return t;
        }
        int end = t.lastIndexOf("```");
        if (end <= firstNl) {
            return t.substring(firstNl + 1).trim();
        }
        return t.substring(firstNl + 1, end).trim();
    }

    private static String normalizeMode(String raw) {
        if (!StringUtils.hasText(raw)) {
            return "natural";
        }
        String m = raw.trim().toLowerCase();
        // expand → continue（兼容旧客户端）
        if ("expand".equals(m)) {
            return "continue";
        }
        return switch (m) {
            case "warmer", "natural", "continue", "shorten", "inspire" -> m;
            default -> "natural";
        };
    }

    private static String normalizeLanguage(String raw) {
        if (!StringUtils.hasText(raw)) {
            return "zh";
        }
        return raw.trim().toLowerCase().startsWith("en") ? "en" : "zh";
    }

    private static String systemPromptFor(String mode, String language) {
        String languageRule = "en".equals(language)
                ? "所有面向用户的内容必须只使用自然、地道、适合真实书信的英文；即使原文或系统提示为中文，也不得输出中文。"
                : "所有面向用户的内容必须只使用自然、地道的简体中文。";
        String polishBase =
                "你是温和的书信助手，帮助中老年用户整理慢邮信件。"
                        + "保留用户事实，不编造经历；语气真诚、简洁、易读；只输出整理后的信件正文，不要解释。"
                        + languageRule;
        return switch (mode) {
            case "warmer" -> polishBase + "任务：让内容更真诚、更有情感，略增温度，勿夸张煽情。";
            case "continue" ->
                    polishBase
                            + "任务：在原文事实上自然地「继续聊下去」，补充一两段可接着写的内容，"
                            + "不要写成完整新故事，也不要复述原文；输出应为整封可寄的完整信（含原文要点并续写）。";
            case "shorten" -> polishBase + "任务：删掉废话与重复，保留重点与温度，明显更短。";
            case "inspire" ->
                    "你是慢邮件的聊天教练。根据用户信件内容推荐可继续聊的话题；"
                            + "若原文标明尚未落笔，则给适合开场的通用话题，不要假设用户的具体经历。"
                            + "不要改写信件正文。只输出 JSON，不要 markdown，格式严格为："
                            + "{\"ask\":[\"问对方的短句1\",\"短句2\",\"短句3\"],"
                            + "\"share\":[\"可分享的短句1\",\"短句2\",\"短句3\"]}。"
                            + "每条简短，贴合中老年慢邮场景，具体、好开口。"
                            + languageRule;
            default -> polishBase + "任务：润色表达，让文字更自然，像真人写信，不像作文或 AI。";
        };
    }

    private record InspireTopics(List<String> ask, List<String> share) {}
}
