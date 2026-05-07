package cn.nine.pros.post.biz.service.app.impl;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.config.OssProperties;
import cn.nine.pros.post.biz.service.app.AppOssService;
import cn.nine.pros.post.client.model.out.OssPutSignResultVO;
import com.aliyun.oss.HttpMethod;
import com.aliyun.oss.OSS;
import com.aliyun.oss.OSSClientBuilder;
import com.aliyun.oss.model.GeneratePresignedUrlRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.net.URL;
import java.time.Instant;
import java.util.Date;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AppOssServiceImpl implements AppOssService {

    private static final Set<String> ALLOWED_EXT = Set.of("jpg", "jpeg", "png", "webp", "gif");
    private static final Set<String> ALLOWED_SCENE = Set.of("postcard", "avatar", "letter");

    private final OssProperties ossProperties;

    @Override
    public OssPutSignResultVO signPut(long userId, String scene, String ext, String contentType) {
        if (!StringUtils.hasText(ossProperties.getEndpoint())
                || !StringUtils.hasText(ossProperties.getAccessKeyId())
                || !StringUtils.hasText(ossProperties.getAccessKeySecret())
                || !StringUtils.hasText(ossProperties.getBucketName())) {
            throw new BadRequestException("未配置 OSS（senior-post.oss.endpoint/accessKeyId/accessKeySecret/bucketName）");
        }
        if (!StringUtils.hasText(scene) || !ALLOWED_SCENE.contains(scene.toLowerCase(Locale.ROOT))) {
            throw new BadRequestException("scene 须为 postcard、avatar 或 letter");
        }
        String normExt = StringUtils.hasText(ext) ? ext.toLowerCase(Locale.ROOT).replace(".", "") : "jpg";
        if (!ALLOWED_EXT.contains(normExt)) {
            throw new BadRequestException("不支持的文件扩展名");
        }
        String resolvedCt = StringUtils.hasText(contentType)
                ? contentType
                : switch (normExt) {
                    case "jpg", "jpeg" -> "image/jpeg";
                    case "png" -> "image/png";
                    case "webp" -> "image/webp";
                    case "gif" -> "image/gif";
                    default -> "application/octet-stream";
                };

        String prefix = ossProperties.getKeyPrefix().replaceAll("^/+|/+$", "");
        String objectKey = prefix + "/" + scene + "/" + userId + "/" + UUID.randomUUID() + "." + normExt;

        int expire = Math.max(60, Math.min(ossProperties.getPutExpireSeconds(), 3600));
        Date expiration = Date.from(Instant.now().plusSeconds(expire));

        GeneratePresignedUrlRequest req = new GeneratePresignedUrlRequest(
                ossProperties.getBucketName(), objectKey, HttpMethod.PUT);
        req.setExpiration(expiration);
        req.setContentType(resolvedCt);

        String endpoint = withHttpsScheme(ossProperties.getEndpoint().trim());
        OSS ossClient = new OSSClientBuilder().build(
                endpoint,
                ossProperties.getAccessKeyId().trim(),
                ossProperties.getAccessKeySecret().trim());
        try {
            URL signed = ossClient.generatePresignedUrl(req);
            long expireMs = expiration.getTime();
            String readUrl = null;
            if (StringUtils.hasText(ossProperties.getPublicReadBaseUrl())) {
                String base = withHttpsScheme(ossProperties.getPublicReadBaseUrl().trim())
                        .replaceAll("/+$", "");
                readUrl = base + "/" + objectKey;
            }
            return OssPutSignResultVO.builder()
                    .putUrl(signed.toString())
                    .objectKey(objectKey)
                    .contentType(resolvedCt)
                    .expireAtEpochMillis(expireMs)
                    .readUrl(readUrl)
                    .build();
        } finally {
            ossClient.shutdown();
        }
    }

    /** 允许配置为 host 无 scheme（如 oss-ap-southeast-1.aliyuncs.com），SDK 需要 https。 */
    private static String withHttpsScheme(String hostOrUrl) {
        if (!StringUtils.hasText(hostOrUrl)) {
            return hostOrUrl;
        }
        String s = hostOrUrl.trim();
        if (s.startsWith("http://") || s.startsWith("https://")) {
            return s;
        }
        return "https://" + s;
    }
}
