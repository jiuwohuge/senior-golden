package cn.nine.pros.post.biz.service.biz.support;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.config.OssProperties;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.client.model.out.OssGetSignItemVO;
import com.aliyun.oss.HttpMethod;
import com.aliyun.oss.OSS;
import com.aliyun.oss.OSSClientBuilder;
import com.aliyun.oss.model.GeneratePresignedUrlRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.net.URL;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * 生成私有桶 GET 预签名 URL（仅技术签名，不含业务鉴权）。
 */
@Component
@RequiredArgsConstructor
public class OssGetPresigner {

    private final OssProperties ossProperties;
    private final AppMessages appMessages;

    public List<OssGetSignItemVO> signGetUrls(List<String> normalizedObjectKeys) {
        ensureOssConfigured();
        if (normalizedObjectKeys == null || normalizedObjectKeys.isEmpty()) {
            return List.of();
        }
        int expireSec = Math.max(60, Math.min(ossProperties.getGetExpireSeconds(), 3600));
        Date expiration = Date.from(Instant.now().plusSeconds(expireSec));
        long expireMs = expiration.getTime();

        OSS ossClient = buildOssClient();
        try {
            List<OssGetSignItemVO> out = new ArrayList<>();
            for (String objectKey : normalizedObjectKeys) {
                GeneratePresignedUrlRequest req = new GeneratePresignedUrlRequest(
                        ossProperties.getBucketName(), objectKey, HttpMethod.GET);
                req.setExpiration(expiration);
                URL signed = ossClient.generatePresignedUrl(req);
                out.add(OssGetSignItemVO.builder()
                        .objectKey(objectKey)
                        .signedUrl(signed.toString())
                        .expireAtEpochMillis(expireMs)
                        .build());
            }
            return out;
        } finally {
            ossClient.shutdown();
        }
    }

    private void ensureOssConfigured() {
        if (!StringUtils.hasText(ossProperties.getEndpoint())
                || !StringUtils.hasText(ossProperties.getAccessKeyId())
                || !StringUtils.hasText(ossProperties.getAccessKeySecret())
                || !StringUtils.hasText(ossProperties.getBucketName())) {
            throw new BadRequestException(appMessages.get("app.error.oss.notConfigured"));
        }
    }

    private OSS buildOssClient() {
        String endpoint = withHttpsScheme(ossProperties.getEndpoint().trim());
        return new OSSClientBuilder().build(
                endpoint,
                ossProperties.getAccessKeyId().trim(),
                ossProperties.getAccessKeySecret().trim());
    }

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
