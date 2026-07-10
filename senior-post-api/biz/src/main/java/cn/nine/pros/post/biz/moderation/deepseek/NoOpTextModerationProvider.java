package cn.nine.pros.post.biz.moderation.deepseek;

import cn.nine.pros.post.biz.moderation.ModerationVerdict;
import cn.nine.pros.post.biz.moderation.TextModerationProvider;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.stereotype.Component;

/**
 * DeepSeek 未启用时的正文机审兜底（恒 SKIPPED）。
 * <p>按接口缺省装配，避免引用具体实现类导致 ClassNotFound（条件 Bean 未打进包时）。
 */
@Component
@ConditionalOnMissingBean(TextModerationProvider.class)
public class NoOpTextModerationProvider implements TextModerationProvider {

    @Override
    public TextModerationResult auditText(String content) {
        return TextModerationResult.of(ModerationVerdict.SKIPPED, "", "", "deepseek disabled");
    }
}
