package cn.nine.pros.post.biz.moderation;

/**
 * 文本内容审核（DeepSeek 等）。
 */
public interface TextModerationProvider {

    TextModerationResult auditPostcardText(String content);

    record TextModerationResult(
            ModerationVerdict verdict,
            String severity,
            String categories,
            String reason) {
        public static TextModerationResult of(
                ModerationVerdict verdict, String severity, String categories, String reason) {
            return new TextModerationResult(
                    verdict,
                    severity == null ? "" : severity,
                    categories == null ? "" : categories,
                    reason == null ? "" : reason);
        }
    }
}
