package cn.nine.pros.post.biz.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * 腾讯即时通信 IM 控制台密钥（仅服务端持有）。
 */
@Data
@ConfigurationProperties(prefix = "senior-post.tencent-im")
public class TencentImProperties {

    /**
     * 控制台 SDKAppID；为 0 时 {@link cn.nine.pros.post.biz.service.app.AppImService} 拒绝签发。
     */
    private long sdkAppId;

    /**
     * 控制台密钥（UserSig HMAC）。
     */
    private String secretKey = "";

    /**
     * UserSig 有效期（秒），默认 7 天。
     */
    private int userSigExpireSeconds = 604800;
}
