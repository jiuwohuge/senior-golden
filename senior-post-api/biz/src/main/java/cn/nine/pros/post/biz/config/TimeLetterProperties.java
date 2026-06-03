package cn.nine.pros.post.biz.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Data
@ConfigurationProperties(prefix = "senior-post.time-letter")
public class TimeLetterProperties {

    private int stampCost = 1;
    private int maxDeliveryYears = 2;
    private int dailyCreateLimit = 5;
    private int recipient30dLimit = 3;
    private int inFlightLimit = 20;
    private int bodyMaxLength = 1500;
    private int bodySoftHintLength = 800;
    private int cancelWindowHours = 24;
    private int deliveryBatchSize = 200;
    private long deliveryFixedDelayMs = 60_000L;
}
