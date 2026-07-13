package cn.nine.pros.post.biz.ai;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.boot.autoconfigure.condition.ConditionalOnBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Spring AI 装配与出站 HTTP 安全配置。
 * <p>信件助手 / 文本机审在缺少 ChatClient Bean 时会用 {@link ChatModel} 现场
 * {@code ChatClient.builder(model).build()}，不依赖本配置必定成功。
 * <p>注意：不要在本类上使用类级 {@code @ConditionalOnBean(ChatModel)}——用户
 * {@code @Configuration} 早于 Spring AI 自动配置求值，会导致永远不装配。
 */
@Slf4j
@Configuration
public class SpringAiChatConfiguration {

    /**
     * 仅在 ChatModel 已存在时创建；用方法参数硬依赖保证顺序（先有 ChatModel）。
     * 若 {@code SPRING_AI_MODEL_CHAT=none} 则无 ChatModel，本 Bean 不会创建（缺少依赖被跳过需配合条件）。
     */
    @Bean
    @ConditionalOnBean(ChatModel.class)
    ChatClient letterChatClient(ChatModel chatModel) {
        log.info("Spring AI ChatClient ready for letter assistant / text moderation");
        return ChatClient.builder(chatModel).build();
    }


    /**
     * 启动时打印 ChatModel 是否就绪，便于排查「信件助手暂时不可用」。
     */
    @Bean
    SpringAiChatModelProbe springAiChatModelProbe(ObjectProvider<ChatModel> chatModelProvider) {
        return new SpringAiChatModelProbe(chatModelProvider);
    }

    @Slf4j
    static final class SpringAiChatModelProbe
            implements org.springframework.boot.ApplicationRunner {

        private final ObjectProvider<ChatModel> chatModelProvider;

        SpringAiChatModelProbe(ObjectProvider<ChatModel> chatModelProvider) {
            this.chatModelProvider = chatModelProvider;
        }

        @Override
        public void run(org.springframework.boot.ApplicationArguments args) {
            ChatModel model = chatModelProvider.getIfAvailable();
            if (model == null) {
                log.warn(
                        "Spring AI ChatModel NOT available — set SPRING_AI_MODEL_CHAT=deepseek and " +
                                "SPRING_AI_DEEPSEEK_API_KEY");
            } else {
                log.info("Spring AI ChatModel available: {}", model.getClass().getSimpleName());
            }
        }
    }
}
