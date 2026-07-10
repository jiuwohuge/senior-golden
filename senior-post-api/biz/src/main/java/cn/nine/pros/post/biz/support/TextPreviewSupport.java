package cn.nine.pros.post.biz.support;

/**
 * 文本预览截断：信箱 / 时光信等列表摘要共用。
 */
public final class TextPreviewSupport {

    private TextPreviewSupport() {
    }

    /**
     * 截断到 maxLen，超出追加省略号；null 视为空串。
     */
    public static String truncate(String text, int maxLen) {
        String body = text == null ? "" : text;
        if (maxLen < 1 || body.length() <= maxLen) {
            return body;
        }
        return body.substring(0, maxLen) + "…";
    }

    /**
     * 隐藏时返回空串；否则截断预览。
     */
    public static String previewOrHidden(boolean hideBody, String text, int maxLen) {
        if (hideBody) {
            return "";
        }
        return truncate(text, maxLen);
    }

    /**
     * 待投递等场景：需要占位时，空正文用 fallback，否则截断。
     */
    public static String previewOrFallback(boolean useFallback, String text, int maxLen, String fallback) {
        if (!useFallback) {
            return truncate(text, maxLen);
        }
        String body = text == null ? "" : text;
        if (body.isEmpty()) {
            return fallback;
        }
        return truncate(body, maxLen);
    }
}
