package cn.nine.pros.post.biz.service.app.support;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.config.OssProperties;
import cn.nine.pros.post.biz.i18n.AppMessages;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.net.URI;
import java.util.Locale;
import java.util.Optional;

/**
 * 将客户端传入的「纯 objectKey」或「可信域名下的 OSS URL」解析为规范化 objectKey。
 */
@Component
@RequiredArgsConstructor
public class OssObjectKeyResolver {

    private final OssProperties ossProperties;
    private final AppMessages appMessages;

    /**
     * App 换签接口：必须是合法 objectKey 或可信 OSS/CDN URL。
     */
    public String requireObjectKey(String raw) {
        if (!StringUtils.hasText(raw)) {
            throw new BadRequestException(appMessages.get("app.error.oss.objectKeyRequired"));
        }
        String t = raw.trim();
        String prefix = ossProperties.getKeyPrefix().replaceAll("^/+|/+$", "");
        try {
            return OssReadableKeyValidator.normalizeAndValidate(prefix, t, appMessages);
        } catch (BadRequestException ignored) {
            // fall through
        }
        if (t.toLowerCase(Locale.ROOT).startsWith("http://") || t.toLowerCase(Locale.ROOT).startsWith("https://")) {
            return fromTrustedHttpUrl(t, prefix);
        }
        throw new BadRequestException(appMessages.get("app.error.oss.objectKeyUnparsable"));
    }

    /**
     * 出站展示：非 OSS 或不可信地址返回 empty，由调用方原样返回 URL。
     */
    public Optional<String> tryResolveObjectKey(String stored) {
        if (!StringUtils.hasText(stored)) {
            return Optional.empty();
        }
        String t = stored.trim();
        String prefix = ossProperties.getKeyPrefix().replaceAll("^/+|/+$", "");
        try {
            return Optional.of(OssReadableKeyValidator.normalizeAndValidate(prefix, t, appMessages));
        } catch (BadRequestException ignored) {
            // continue
        }
        if (t.toLowerCase(Locale.ROOT).startsWith("http://") || t.toLowerCase(Locale.ROOT).startsWith("https://")) {
            try {
                if (!isTrustedHost(extractHost(t))) {
                    return Optional.empty();
                }
                URI uri = URI.create(t);
                String path = uri.getPath();
                if (path == null || path.isEmpty()) {
                    return Optional.empty();
                }
                String noLeading = path.startsWith("/") ? path.substring(1) : path;
                return Optional.of(OssReadableKeyValidator.normalizeAndValidate(prefix, noLeading, appMessages));
            } catch (BadRequestException | IllegalArgumentException ignored) {
                return Optional.empty();
            }
        }
        return Optional.empty();
    }

    private String fromTrustedHttpUrl(String raw, String prefix) {
        if (!isTrustedHost(extractHost(raw))) {
            throw new BadRequestException(appMessages.get("app.error.oss.hostNotAllowed"));
        }
        URI uri = URI.create(raw.trim());
        String path = uri.getPath();
        if (path == null || path.isEmpty()) {
            throw new BadRequestException(appMessages.get("app.error.oss.objectKeyUnparsable"));
        }
        String noLeading = path.startsWith("/") ? path.substring(1) : path;
        return OssReadableKeyValidator.normalizeAndValidate(prefix, noLeading, appMessages);
    }

    private boolean isTrustedHost(String host) {
        if (!StringUtils.hasText(host)) {
            return false;
        }
        String h = host.toLowerCase(Locale.ROOT).trim();
        String epHost = extractHost(ossProperties.getEndpoint());
        String bucket = ossProperties.getBucketName() == null ? "" : ossProperties.getBucketName().trim().toLowerCase(Locale.ROOT);
        if (StringUtils.hasText(epHost) && h.equals(epHost)) {
            return true;
        }
        if (StringUtils.hasText(epHost) && StringUtils.hasText(bucket) && h.equals(bucket + "." + epHost)) {
            return true;
        }
        if (StringUtils.hasText(ossProperties.getPublicReadBaseUrl())) {
            String pub = extractHost(ossProperties.getPublicReadBaseUrl());
            if (StringUtils.hasText(pub) && h.equals(pub)) {
                return true;
            }
        }
        return false;
    }

    private static String extractHost(String endpointOrUrl) {
        if (!StringUtils.hasText(endpointOrUrl)) {
            return "";
        }
        String s = endpointOrUrl.trim();
        if (!s.toLowerCase(Locale.ROOT).startsWith("http://") && !s.toLowerCase(Locale.ROOT).startsWith("https://")) {
            s = "https://" + s;
        }
        try {
            URI u = URI.create(s);
            return u.getHost() == null ? "" : u.getHost().toLowerCase(Locale.ROOT);
        } catch (IllegalArgumentException e) {
            return "";
        }
    }
}
