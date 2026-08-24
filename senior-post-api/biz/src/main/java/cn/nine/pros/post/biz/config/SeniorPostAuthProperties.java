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

    /**
     * 临时调试万能验证码。非空时该明文跳过哈希校验。
     * 生产必须留空；仅 application-local 配置 666666。
     */
    private String debugMasterCode = "";

    /** 是否命中本地调试万能码（trim 后全等）。 */
    public boolean matchesDebugMasterCode(String rawCode) {
        if (debugMasterCode == null || debugMasterCode.isBlank()) {
            return false;
        }
        if (rawCode == null || rawCode.isBlank()) {
            return false;
        }
        return debugMasterCode.equals(rawCode.trim());
    }
}
