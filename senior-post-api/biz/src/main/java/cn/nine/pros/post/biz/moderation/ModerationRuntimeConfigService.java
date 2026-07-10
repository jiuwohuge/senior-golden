package cn.nine.pros.post.biz.moderation;

import cn.nine.pros.post.biz.config.ModerationProperties;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.concurrent.atomic.AtomicReference;

@Service
@RequiredArgsConstructor
public class ModerationRuntimeConfigService {

    private static final long CACHE_TTL_MS = 60_000L;

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
        ModerationProperties.Baidu baidu = moderationProperties.getBaidu();
        ModerationProperties.Deepseek deepseek = moderationProperties.getDeepseek();
        boolean baiduReady = StringUtils.hasText(baidu.getAppId())
                && StringUtils.hasText(baidu.getApiKey())
                && StringUtils.hasText(baidu.getApiSecret());
        boolean deepseekReady = StringUtils.hasText(deepseek.getApiKey());
        return new ModerationRuntimeConfig(baiduReady, deepseekReady);
    }

    private record Cached(ModerationRuntimeConfig config, long loadedAtMs) {}
}
