package cn.nine.pros.post.biz.moderation.deepseek;

import cn.nine.pros.post.biz.moderation.ModerationVerdict;
import cn.nine.pros.post.biz.moderation.TextModerationProvider;
import org.springframework.boot.autoconfigure.condition.ConditionalOnExpression;
import org.springframework.stereotype.Component;

/**
 * DeepSeek 未启用时的正文机审兜底（恒 SKIPPED）。
 * <p>与 {@link DeepSeekTextModerationProvider} 互斥：不可用
 * {@code @ConditionalOnMissingBean(TextModerationProvider)} 挂在本类上，
 * 组件扫描会把自身定义算作已存在，导致 NoOp 被跳过、启动缺 Bean。
 */
@Component
@ConditionalOnExpression("'${senior-post.moderation.deepseek.api-key:}'.length() == 0")
public class NoOpTextModerationProvider implements TextModerationProvider {

    @Override
    public TextModerationResult auditText(String content) {
        return TextModerationResult.of(ModerationVerdict.SKIPPED, "", "", "deepseek disabled");
    }
}
