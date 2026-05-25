package cn.nine.pros.post.biz.moderation.baidu;

import cn.nine.pros.post.biz.config.ModerationProperties;
import com.baidu.aip.contentcensor.AipContentCensor;
import org.springframework.boot.autoconfigure.condition.ConditionalOnExpression;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConditionalOnExpression(
        "'${senior-post.moderation.baidu.api-key:}'.length() > 0"
                + " && '${senior-post.moderation.baidu.api-secret:}'.length() > 0"
                + " && '${senior-post.moderation.baidu.app-id:}'.length() > 0")
public class BaiduModerationConfiguration {

    @Bean
    public AipContentCensor aipContentCensor(ModerationProperties moderationProperties) {
        ModerationProperties.Baidu baidu = moderationProperties.getBaidu();
        AipContentCensor client = new AipContentCensor(baidu.getAppId(), baidu.getApiKey(), baidu.getApiSecret());
        client.setConnectionTimeoutInMillis(baidu.getConnectionTimeoutMs());
        client.setSocketTimeoutInMillis(baidu.getSocketTimeoutMs());
        return client;
    }
}
