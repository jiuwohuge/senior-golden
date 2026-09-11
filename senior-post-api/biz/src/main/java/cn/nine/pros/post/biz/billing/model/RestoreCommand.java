package cn.nine.pros.post.biz.billing.model;

/**
 * 恢复购买命令。
 */
public record RestoreCommand(
        long userId,
        String packageName
) {
}
