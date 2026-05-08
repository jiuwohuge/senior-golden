package cn.nine.pros.post.biz.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Data
@ConfigurationProperties(prefix = "senior-post.auth")
public class SeniorPostAuthProperties {

    /**
     * 与验证码组合做哈希的密钥，生产务必通过环境变量覆盖。
     */
    private String passwordResetPepper = "dev-only-change-in-production";

    private int passwordResetExpireMinutes = 15;

    private int passwordResetMaxRequestsPerHour = 5;

    private int passwordResetMinIntervalSeconds = 60;
}
