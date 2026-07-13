package cn.nine.pros.post.biz.ai;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.boot.autoconfigure.condition.ConditionalOnBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * 全站 LLM 统一走 Spring AI：业务只依赖 {@link ChatModel} / {@link ChatClient}。
 */
@Slf4j
@Configuration
public class SpringAiChatConfiguration {

    @Bean
    @ConditionalOnBean(ChatModel.class)
    ChatClient letterChatClient(ChatModel chatModel) {
        log.info("Spring AI ChatClient ready for letter assistant / text moderation");
        return ChatClient.builder(chatModel).build();
    }
}
