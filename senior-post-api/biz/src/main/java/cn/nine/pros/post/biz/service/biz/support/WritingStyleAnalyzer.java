package cn.nine.pros.post.biz.service.biz.support;

import org.springframework.util.StringUtils;

import java.util.Locale;
import java.util.Set;
import java.util.regex.Pattern;

/**
 * 写作风格规则版（PRD §3.7）：平均句长 + 情绪词比例 → concise|narrative|emotional。
 */
public final class WritingStyleAnalyzer {

    public static final String CONCISE = "concise";
    public static final String NARRATIVE = "narrative";
    public static final String EMOTIONAL = "emotional";

    private static final Pattern SENTENCE_SPLIT = Pattern.compile("[.!?。！？]+");
    private static final Set<String> EMOTION_WORDS = Set.of(
            "love", "happy", "sad", "miss", "hope", "fear", "joy", "lonely", "grateful", "angry",
            "爱", "开心", "难过", "想你", "希望", "害怕", "快乐", "孤独", "感谢", "生气", "温暖", "思念");

    private WritingStyleAnalyzer() {
    }

    public static String classify(String text) {
        if (!StringUtils.hasText(text)) {
            return CONCISE;
        }
        String normalized = text.trim();
        String[] sentences = SENTENCE_SPLIT.split(normalized);
        int sentenceCount = 0;
        int totalWords = 0;
        for (String s : sentences) {
            String t = s.trim();
            if (t.isEmpty()) {
                continue;
            }
            sentenceCount++;
            totalWords += countWords(t);
        }
        if (sentenceCount == 0) {
            return CONCISE;
        }
        double avgLen = (double) totalWords / sentenceCount;
        double emotionRatio = emotionHits(normalized) / (double) Math.max(totalWords, 1);

        if (emotionRatio >= 0.08) {
            return EMOTIONAL;
        }
        if (avgLen >= 18) {
            return NARRATIVE;
        }
        return CONCISE;
    }

    private static int countWords(String sentence) {
        // 中文按字近似，英文按空白分词
        if (sentence.codePoints().anyMatch(cp -> Character.UnicodeScript.of(cp) == Character.UnicodeScript.HAN)) {
            return (int) sentence.codePoints().filter(cp -> !Character.isWhitespace(cp)).count();
        }
        String[] parts = sentence.trim().split("\\s+");
        return parts.length;
    }

    private static int emotionHits(String text) {
        String lower = text.toLowerCase(Locale.ROOT);
        int hits = 0;
        for (String w : EMOTION_WORDS) {
            if (lower.contains(w.toLowerCase(Locale.ROOT))) {
                hits++;
            }
        }
        return hits;
    }
}
