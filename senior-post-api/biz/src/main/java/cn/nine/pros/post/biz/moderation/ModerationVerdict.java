package cn.nine.pros.post.biz.moderation;

/**
 * 机审单项结论，映射到明信片 {@code review_status} 编排逻辑。
 */
public enum ModerationVerdict {
    /** 通过 */
    PASS,
    /** 需人工复核 */
    REVIEW,
    /** 明确违规 */
    REJECT,
    /** 调用失败或未启用 */
    ERROR,
    /** 提供方未执行（如百度关闭且有图） */
    SKIPPED
}
