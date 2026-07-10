package cn.nine.pros.post.biz.moderation.deepseek;

import cn.nine.pros.post.biz.moderation.ModerationVerdict;
import cn.nine.pros.post.biz.moderation.TextModerationProvider;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.stereotype.Component;

@Component
@ConditionalOnMissingBean(DeepSeekTextModerationProvider.class)
public class NoOpTextModerationProvider implements TextModerationProvider {

    @Override
    public TextModerationResult auditText(String content) {
        return TextModerationResult.of(ModerationVerdict.SKIPPED, "", "", "deepseek disabled");
    }
}
