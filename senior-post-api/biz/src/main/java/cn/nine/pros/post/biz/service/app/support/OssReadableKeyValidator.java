package cn.nine.pros.post.biz.service.app.support;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import org.springframework.util.StringUtils;

import java.util.Locale;
import java.util.Set;
import java.util.regex.Pattern;

/**
 * 私有桶读签名：限制 objectKey 必须在配置的 keyPrefix 下，且符合上传路径
 * {@code prefix/(postcard|avatar|letter)/{numericUserId}/{filename}}。
 */
public final class OssReadableKeyValidator {

    private static final Set<String> ALLOWED_SCENE = Set.of("postcard", "avatar", "letter");
    private static final Pattern SAFE_FILENAME = Pattern.compile(
            "^[a-zA-Z0-9][a-zA-Z0-9._-]*\\.(jpg|jpeg|png|webp|gif)$");

    /**
     * 已规范化 objectKey 解析结果（用于读权限判断）。
     */
    public record ParsedOssKey(String sceneLower, long ownerUserId, String fileName) {
    }

    private OssReadableKeyValidator() {
    }

    /**
     * @return 规范化后的 objectKey（无首尾 /、无非法片段）
     */
    public static String normalizeAndValidate(String configuredKeyPrefix, String rawKey, AppMessages msg) {
        if (!StringUtils.hasText(rawKey)) {
            throw new BadRequestException(msg.get("app.error.oss.objectKeyRequired"));
        }
        String key = rawKey.trim().replaceAll("^/+", "");
        if (key.contains("..") || key.contains("//")) {
            throw new BadRequestException(msg.get("app.error.oss.objectKeyInvalid"));
        }
        String prefix = configuredKeyPrefix.replaceAll("^/+|/+$", "");
        if (!StringUtils.hasText(prefix)) {
            throw new BadRequestException(msg.get("app.error.oss.keyPrefixUnset"));
        }
        if (!key.startsWith(prefix + "/")) {
            throw new BadRequestException(msg.get("app.error.oss.keyPrefixMismatch"));
        }
        parseNormalizedBody(prefix, key, msg);
        return key;
    }

    /**
     * 对已通过 {@link #normalizeAndValidate} 的 key 解析 scene、上传者用户 ID、文件名。
     */
    public static ParsedOssKey parseNormalizedKey(String configuredKeyPrefix, String normalizedKey,
            AppMessages msg) {
        String prefix = configuredKeyPrefix.replaceAll("^/+|/+$", "");
        return parseNormalizedBody(prefix, normalizedKey, msg);
    }

    private static ParsedOssKey parseNormalizedBody(String prefix, String key, AppMessages msg) {
        String rest = key.substring(prefix.length() + 1);
        String[] parts = rest.split("/");
        if (parts.length != 3) {
            throw new BadRequestException(msg.get("app.error.oss.objectKeyPathInvalid"));
        }
        if (!ALLOWED_SCENE.contains(parts[0].toLowerCase(Locale.ROOT))) {
            throw new BadRequestException(msg.get("app.error.oss.objectKeySceneInvalid"));
        }
        if (!StringUtils.hasText(parts[1]) || !parts[1].chars().allMatch(Character::isDigit)) {
            throw new BadRequestException(msg.get("app.error.oss.objectKeyUserSegmentInvalid"));
        }
        if (!SAFE_FILENAME.matcher(parts[2]).matches()) {
            throw new BadRequestException(msg.get("app.error.oss.objectKeyFilenameInvalid"));
        }
        return new ParsedOssKey(parts[0].toLowerCase(Locale.ROOT), Long.parseLong(parts[1]), parts[2]);
    }
}
