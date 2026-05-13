package cn.nine.pros.post.biz.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Data
@Component
@ConfigurationProperties(prefix = "senior-post.mail.outbox")
public class SeniorPostMailOutboxProperties {

    /**
     * 调度拉取间隔（毫秒）
     */
    private long pollDelayMs = 10_000L;

    /**
     * 单次处理条数上限
     */
    private int batchSize = 20;

    /**
     * 最大尝试次数（超过则标记 failed）
     */
    private int maxAttempts = 8;

    /**
     * 首次失败后的退避秒数（按 2^min(attempts,6) 倍增，封顶 3600）
     */
    private int initialBackoffSeconds = 30;
}
