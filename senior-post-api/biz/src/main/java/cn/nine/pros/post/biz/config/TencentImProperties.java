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

    /**
     * 是否在业务侧建联成功后调用腾讯 REST 同步双向好友（FP-A5d-004）。
     * 需配置 {@link #restApiIdentifier} 且在控制台将该账号设为 App 管理员。
     */
    private boolean friendshipSyncEnabled = true;

    /**
     * REST API Host（中国大陆默认 console.tim.qq.com；海外常见 adminapisgp.im.qcloud.com 等，以控制台为准）。
     */
    private String restApiHost = "console.tim.qq.com";

    /**
     * 调用 REST API 的管理员 Identifier（须与控制台「App 管理员」一致；用于签发 REST UserSig）。
     */
    private String restApiIdentifier = "";

    /**
     * REST 管理员 UserSig 有效期（秒），默认 120。
     */
    private int restApiUserSigExpireSeconds = 120;

    /**
     * 建联前是否调用 account_import，确保双方账号已在 IM 注册。
     */
    private boolean accountImportBeforeFriendAdd = true;

    /**
     * REST 调用失败时的最大重试次数（不含首次），间隔约 200ms。
     */
    private int restApiMaxRetries = 2;
}
