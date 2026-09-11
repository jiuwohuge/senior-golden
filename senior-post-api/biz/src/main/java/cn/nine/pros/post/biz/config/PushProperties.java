package cn.nine.pros.post.biz.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.core.env.Environment;

/**
 * 推送 / FCM 配置（{@code senior-post.push}）。
 * <p>mock 守卫对齐 {@link BillingProperties}：mockEnabled + 非 prod/production。
 */
@Data
@ConfigurationProperties(prefix = "senior-post.push")
public class PushProperties {

    /**
     * 是否允许 Mock FCM / mock-enqueue。
     * 默认 false；在 prod/production profile 下即使为 true 也不生效。
     */
    private boolean mockEnabled = false;

    /**
     * 真实 FCM 凭证路径（可选）；为空则视为未配置，派发走 mock 或 stub。
     */
    private String fcmCredentialsPath = "";

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

    /** 是否已配置真实 FCM 凭证（非空路径）。 */
    public boolean isRealFcmConfigured() {
        return fcmCredentialsPath != null && !fcmCredentialsPath.isBlank();
    }
}
