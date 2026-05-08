package cn.nine.pros.post.biz.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * 阿里云 OSS（服务端仅签发 PUT 预签名 URL，不代理文件流）。
 */
@Data
@ConfigurationProperties(prefix = "senior-post.oss")
public class OssProperties {

    /**
     * 如 https://oss-cn-hangzhou.aliyuncs.com
     */
    private String endpoint = "";

    private String accessKeyId = "";

    private String accessKeySecret = "";

    private String bucketName = "";

    /**
     * 预签名 PUT 有效期（秒），默认 900（15 分钟）。
     */
    private int putExpireSeconds = 900;

    /**
     * 预签名 GET（读）有效期（秒），默认 900；与 PUT 分离便于单独调短。
     */
    private int getExpireSeconds = 900;

    /**
     * 对象键前缀，如 app/uploads。
     */
    private String keyPrefix = "app/uploads";

    /**
     * 可选：公开访问基址（CDN 或 Bucket 域名），用于客户端拼接读 URL；私有桶可留空。
     */
    private String publicReadBaseUrl = "";
}
