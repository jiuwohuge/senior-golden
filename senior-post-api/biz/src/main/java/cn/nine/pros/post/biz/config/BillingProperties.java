package cn.nine.pros.post.biz.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.core.env.Environment;

/**
 * 通用计费配置（{@code senior-post.billing}）。
 */
@Data
@ConfigurationProperties(prefix = "senior-post.billing")
public class BillingProperties {

    /**
     * 是否允许 mock 渠道 / mock-sync。
     * 默认 false；在 prod/production profile 下即使为 true 也不生效。
     */
    private boolean mockEnabled = false;

    /**
     * mock 仅在 mockEnabled=true 且活跃 profile 不含 prod/production 时允许。
     */
    public boolean isMockAllowed(Environment env) {
        if (!mockEnabled) {
            return false;
        }
        if (env == null) {
            return true;
        }
        String[] profiles = env.getActiveProfiles();
        if (profiles == null) {
            return true;
        }
        for (String profile : profiles) {
            if (profile == null) {
                continue;
            }
            String normalized = profile.trim();
            if ("prod".equalsIgnoreCase(normalized) || "production".equalsIgnoreCase(normalized)) {
                return false;
            }
        }
        return true;
    }
}
