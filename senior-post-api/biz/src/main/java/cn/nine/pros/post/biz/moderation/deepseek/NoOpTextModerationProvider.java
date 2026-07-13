package cn.nine.pros.post.biz.moderation.deepseek;

import cn.nine.pros.post.biz.moderation.ModerationVerdict;
import cn.nine.pros.post.biz.moderation.TextModerationProvider;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.stereotype.Component;

/**
 * 无 Spring AI {@link ChatModel} 时的正文机审兜底（恒 SKIPPED）。
 * <p>与 {@link DeepSeekTextModerationProvider} 互斥。
 */
@Component
@ConditionalOnMissingBean(ChatModel.class)
public class NoOpTextModerationProvider implements TextModerationProvider {

    @Override
    public TextModerationResult auditText(String content) {
        return TextModerationResult.of(ModerationVerdict.SKIPPED, "", "", "chat model disabled");
    }
}
