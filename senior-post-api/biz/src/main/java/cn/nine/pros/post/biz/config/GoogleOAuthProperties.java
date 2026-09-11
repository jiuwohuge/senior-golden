package cn.nine.pros.post.biz.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

import java.util.ArrayList;
import java.util.List;

/**
 * Google OAuth / ID Token 校验配置（{@code senior-post.oauth.google}）。
 */
@Data
@ConfigurationProperties(prefix = "senior-post.oauth.google")
public class GoogleOAuthProperties {

    /** Web OAuth client ID（JWT aud）。 */
    private String clientId = "";

    /** Android 原生 client ID（可选 aud）。 */
    private String androidClientId = "";

    /** iOS 原生 client ID（可选 aud）。 */
    private String iosClientId = "";

    /** 额外受众列表；与上方三个字段合并。 */
    private List<String> clientIds = new ArrayList<>();

    /**
     * 非生产 mock：接受 {@code mock-google:<sub>[:<email>]}。
     * 默认 false；在 {@code prod}/{@code production} profile 下即使为 true 也不生效。
     */
    private boolean mockEnabled = false;

    /**
     * 合并 {@code clientId}、{@code androidClientId}、{@code iosClientId}、{@code clientIds}：
     * trim、丢弃空白、按出现顺序去重。
     *
     * @return 不可变意图的受众列表（新 ArrayList）
     */
    public List<String> resolveAudiences() {
        List<String> audiences = new ArrayList<>();
        appendAudience(audiences, clientId);
        appendAudience(audiences, androidClientId);
        appendAudience(audiences, iosClientId);
        if (clientIds == null) {
            return audiences;
        }
        for (String id : clientIds) {
            appendAudience(audiences, id);
        }
        return audiences;
    }

    private static void appendAudience(List<String> audiences, String raw) {
        if (raw == null) {
            return;
        }
        String trimmed = raw.trim();
        if (trimmed.isEmpty()) {
            return;
        }
        if (audiences.contains(trimmed)) {
            return;
        }
        audiences.add(trimmed);
    }
}
