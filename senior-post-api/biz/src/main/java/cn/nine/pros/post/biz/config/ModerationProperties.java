package cn.nine.pros.post.biz.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Data
@ConfigurationProperties(prefix = "senior-post.moderation")
public class ModerationProperties {

    private final Baidu baidu = new Baidu();
    private final Deepseek deepseek = new Deepseek();
    /** 待审超过该分钟数且未机审完成时，补偿任务重试 */
    private int pendingRetryMinutes = 5;

    @Data
    public static class Baidu {
        private boolean enabled = false;
        private String appId = "";
        private String apiKey = "";
        private String apiSecret = "";
        private int connectionTimeoutMs = 10_000;
        private int socketTimeoutMs = 60_000;
    }

    @Data
    public static class Deepseek {
        private boolean enabled = false;
        private String apiKey = "";
        private String baseUrl = "https://api.deepseek.com";
        private String model = "deepseek-v4-flash";
        private int connectTimeoutMs = 10_000;
        private int readTimeoutMs = 60_000;
    }
}
