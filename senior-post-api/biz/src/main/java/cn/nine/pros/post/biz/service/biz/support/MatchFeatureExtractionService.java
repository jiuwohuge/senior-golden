package cn.nine.pros.post.biz.service.biz.support;

import cn.nine.pros.post.biz.service.base.ConfigService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

/**
 * 匹配 v2：从信件正文提取 AI 特征（DeepSeek 就绪时可扩展；当前规则降级）。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class MatchFeatureExtractionService {

    private static final String KEY_AI_EMOTION = "match.ai.emotion_enabled";
    private static final String KEY_AI_STYLE = "match.ai.style_enabled";

    private final ConfigService configService;

    public record LetterFeatures(Double emotionScore, Double styleScore) {
    }

    /**
     * 从发件信件正文提取情绪/风格分量（0~1）；AI 未启用时返回 null。
     */
    public LetterFeatures extractFromLetterContent(String content) {
        if (!StringUtils.hasText(content)) {
            return new LetterFeatures(null, null);
        }
        boolean emotionOn = configFlag(KEY_AI_EMOTION, false);
        boolean styleOn = configFlag(KEY_AI_STYLE, false);
        if (!emotionOn && !styleOn) {
            return new LetterFeatures(null, null);
        }
        String text = content.trim();
        double lenNorm = Math.min(1.0, text.length() / 500.0);
        double punct = countChar(text, '!') + countChar(text, '?');
        double emotion = emotionOn ? clamp01(0.3 + lenNorm * 0.4 + Math.min(0.3, punct * 0.05)) : null;
        double style = styleOn ? clamp01(0.4 + (text.contains("\n") ? 0.3 : 0.0) + lenNorm * 0.2) : null;
        return new LetterFeatures(emotion, style);
    }

    private static int countChar(String s, char c) {
        int n = 0;
        for (int i = 0; i < s.length(); i++) {
            if (s.charAt(i) == c) {
                n++;
            }
        }
        return n;
    }

    private static double clamp01(double v) {
        return Math.max(0.0, Math.min(1.0, v));
    }

    private boolean configFlag(String key, boolean defaultValue) {
        var cfg = configService.findActiveByKey(key);
        if (cfg == null || cfg.getConfigValue() == null || cfg.getConfigValue().isBlank()) {
            return defaultValue;
        }
        return "true".equalsIgnoreCase(cfg.getConfigValue().trim());
    }
}
