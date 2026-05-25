package cn.nine.pros.post.biz.moderation;

/**
 * 图片内容审核（百度等内容安全）。
 */
public interface ImageModerationProvider {

    /**
     * @param imageBytes 图片二进制
     * @return 审核结论；{@link ModerationVerdict#SKIPPED} 表示未执行机审
     */
    ImageModerationResult auditImage(byte[] imageBytes);

    record ImageModerationResult(ModerationVerdict verdict, String detail) {
        public static ImageModerationResult of(ModerationVerdict verdict, String detail) {
            return new ImageModerationResult(verdict, detail == null ? "" : detail);
        }
    }
}
