package cn.nine.pros.post.biz.moderation;

import cn.nine.pros.post.biz.config.ModerationProperties;
import cn.nine.pros.post.biz.model.domain.ConfigDomain;
import cn.nine.pros.post.biz.service.base.ConfigService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicReference;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ModerationRuntimeConfigService {

    private static final long CACHE_TTL_MS = 60_000L;

    private final ConfigService configService;
    private final ModerationProperties moderationProperties;
    private final AtomicReference<Cached> cache = new AtomicReference<>();

    public ModerationRuntimeConfig get() {
        Cached c = cache.get();
        long now = System.currentTimeMillis();
        if (c != null && now - c.loadedAtMs < CACHE_TTL_MS) {
            return c.config;
        }
        ModerationRuntimeConfig fresh = loadFromDb();
        cache.set(new Cached(fresh, now));
        return fresh;
    }

    public void invalidateCache() {
        cache.set(null);
    }

    public ModerationRuntimeConfig loadFromDb() {
        List<ConfigDomain> rows = configService.list(new LambdaQueryWrapper<ConfigDomain>()
                .eq(ConfigDomain::isDelFlag, false)
                .eq(ConfigDomain::getConfigGroup, ModerationConfigKeys.GROUP)
                .in(
                        ConfigDomain::getConfigKey,
                        ModerationConfigKeys.POSTCARD_IMAGE_ENABLED,
                        ModerationConfigKeys.POSTCARD_TEXT_ENABLED));
        Map<String, String> map = rows.stream()
                .filter(r -> r.getConfigKey() != null && r.getConfigValue() != null)
                .collect(Collectors.toMap(ConfigDomain::getConfigKey, ConfigDomain::getConfigValue, (a, b) -> b));
        boolean imageOn = parseBoolean(map.get(ModerationConfigKeys.POSTCARD_IMAGE_ENABLED), false);
        boolean textOn = parseBoolean(map.get(ModerationConfigKeys.POSTCARD_TEXT_ENABLED), false);
        ModerationProperties.Baidu baidu = moderationProperties.getBaidu();
        ModerationProperties.Deepseek deepseek = moderationProperties.getDeepseek();
        boolean baiduReady = StringUtils.hasText(baidu.getAppId())
                && StringUtils.hasText(baidu.getApiKey())
                && StringUtils.hasText(baidu.getApiSecret());
        boolean deepseekReady = StringUtils.hasText(deepseek.getApiKey());
        return new ModerationRuntimeConfig(imageOn, textOn, baiduReady, deepseekReady);
    }

    private static boolean parseBoolean(String raw, boolean defaultValue) {
        if (!StringUtils.hasText(raw)) {
            return defaultValue;
        }
        String v = raw.trim().toLowerCase();
        return "true".equals(v) || "1".equals(v) || "yes".equals(v) || "on".equals(v);
    }

    private record Cached(ModerationRuntimeConfig config, long loadedAtMs) {}
}
