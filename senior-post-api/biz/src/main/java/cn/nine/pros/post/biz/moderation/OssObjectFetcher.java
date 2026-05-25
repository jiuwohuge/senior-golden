package cn.nine.pros.post.biz.moderation;

import cn.nine.pros.post.biz.config.OssProperties;
import cn.nine.pros.post.biz.service.app.support.OssObjectKeyResolver;
import com.aliyun.oss.OSS;
import com.aliyun.oss.OSSClientBuilder;
import com.aliyun.oss.model.OSSObject;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.io.InputStream;
import java.util.Locale;
import java.util.Optional;

@Slf4j
@Component
@RequiredArgsConstructor
public class OssObjectFetcher {

    private final OssProperties ossProperties;
    private final OssObjectKeyResolver objectKeyResolver;

    public Optional<byte[]> tryFetchBytes(String storedRef) {
        if (!StringUtils.hasText(storedRef)) {
            return Optional.empty();
        }
        Optional<String> keyOpt = objectKeyResolver.tryResolveObjectKey(storedRef);
        if (keyOpt.isEmpty()) {
            log.warn("Cannot resolve OSS key for moderation: ref={}", abbreviate(storedRef));
            return Optional.empty();
        }
        if (!isOssConfigured()) {
            log.warn("OSS not configured; skip fetch for moderation");
            return Optional.empty();
        }
        String objectKey = keyOpt.get();
        OSS client = buildClient();
        try {
            OSSObject obj = client.getObject(ossProperties.getBucketName().trim(), objectKey);
            try (InputStream in = obj.getObjectContent()) {
                return Optional.of(in.readAllBytes());
            }
        } catch (Exception e) {
            log.warn("OSS getObject failed key={}: {}", objectKey, e.getMessage());
            return Optional.empty();
        } finally {
            client.shutdown();
        }
    }

    private boolean isOssConfigured() {
        return StringUtils.hasText(ossProperties.getEndpoint())
                && StringUtils.hasText(ossProperties.getAccessKeyId())
                && StringUtils.hasText(ossProperties.getAccessKeySecret())
                && StringUtils.hasText(ossProperties.getBucketName());
    }

    private OSS buildClient() {
        String endpoint = ossProperties.getEndpoint().trim();
        if (!endpoint.toLowerCase(Locale.ROOT).startsWith("http://")
                && !endpoint.toLowerCase(Locale.ROOT).startsWith("https://")) {
            endpoint = "https://" + endpoint;
        }
        return new OSSClientBuilder()
                .build(endpoint, ossProperties.getAccessKeyId().trim(), ossProperties.getAccessKeySecret().trim());
    }

    private static String abbreviate(String s) {
        if (s == null) {
            return "";
        }
        return s.length() <= 80 ? s : s.substring(0, 80) + "...";
    }
}
