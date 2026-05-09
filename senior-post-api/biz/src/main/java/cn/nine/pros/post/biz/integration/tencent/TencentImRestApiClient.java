package cn.nine.pros.post.biz.integration.tencent;

import cn.nine.pros.post.biz.config.TencentImProperties;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tencentyun.TLSSigAPIv2;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.concurrent.ThreadLocalRandom;

/**
 * 腾讯 IM REST（HTTPS JSON）：account_import、sns/friend_add。
 * 文档：<a href="https://www.tencentcloud.com/document/product/1047/34620">RESTful API Overview</a>
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class TencentImRestApiClient {

    private final TencentImProperties props;
    private final ObjectMapper objectMapper;

    private static final HttpClient HTTP = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    /**
     * @return true 表示 HTTP 成功且 ErrorCode==0；否则 false（已打日志）
     */
    public boolean accountImport(String userIdStr) {
        if (!StringUtils.hasText(userIdStr)) {
            return false;
        }
        String body = """
                {"Identifier":"%s"}
                """
                .formatted(escapeJson(userIdStr))
                .trim();
        return post("/v4/im_open_login_svc/account_import", body);
    }

    /**
     * From_Account 添加 To_Account 为好友（单向；双向需调用两次）。
     */
    public boolean friendAdd(String fromAccount, String toAccount) {
        if (!StringUtils.hasText(fromAccount) || !StringUtils.hasText(toAccount)) {
            return false;
        }
        String body = """
                {"From_Account":"%s","AddFriendItem":[{"To_Account":"%s","AddSource":"AddSource_Type_Unknow","AddWording":"SeniorPost"}]}
                """
                .formatted(escapeJson(fromAccount), escapeJson(toAccount))
                .trim();
        return post("/v4/sns/friend_add", body);
    }

    private boolean post(String path, String jsonBody) {
        if (props.getSdkAppId() <= 0 || !StringUtils.hasText(props.getSecretKey())) {
            log.warn("Tencent IM REST skipped: sdk-app-id or secret-key missing");
            return false;
        }
        if (!StringUtils.hasText(props.getRestApiIdentifier())) {
            log.warn("Tencent IM REST skipped: senior-post.tencent-im.rest-api-identifier empty");
            return false;
        }
        int sdk = (int) Math.min(Integer.MAX_VALUE, Math.max(0, props.getSdkAppId()));
        TLSSigAPIv2 api = new TLSSigAPIv2(sdk, props.getSecretKey().trim());
        String admin = props.getRestApiIdentifier().trim();
        int expire = Math.max(60, props.getRestApiUserSigExpireSeconds());
        String sig = api.genUserSig(admin, expire);

        int attempts = 1 + Math.max(0, props.getRestApiMaxRetries());
        String host = props.getRestApiHost().trim().replaceFirst("^https?://", "").replaceAll("/+$", "");
        for (int i = 0; i < attempts; i++) {
            long random = ThreadLocalRandom.current().nextLong(0, 1L << 31);
            String qs =
                    "sdkappid="
                            + URLEncoder.encode(String.valueOf(props.getSdkAppId()), StandardCharsets.UTF_8)
                            + "&identifier="
                            + URLEncoder.encode(admin, StandardCharsets.UTF_8)
                            + "&usersig="
                            + URLEncoder.encode(sig, StandardCharsets.UTF_8)
                            + "&random="
                            + random
                            + "&contenttype=json";
            String url = "https://" + host + path + "?" + qs;
            try {
                HttpRequest req = HttpRequest.newBuilder()
                        .uri(URI.create(url))
                        .timeout(Duration.ofSeconds(25))
                        .header("Content-Type", "application/json; charset=utf-8")
                        .POST(HttpRequest.BodyPublishers.ofString(jsonBody, StandardCharsets.UTF_8))
                        .build();
                HttpResponse<String> resp = HTTP.send(req, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
                if (resp.statusCode() < 200 || resp.statusCode() >= 300) {
                    log.warn("Tencent IM REST HTTP {} path={} bodySnippet={}", resp.statusCode(), path, snippet(resp.body()));
                    if (i + 1 < attempts) {
                        sleepBackoff(i);
                    }
                    continue;
                }
                JsonNode root = objectMapper.readTree(resp.body());
                String action = text(root, "ActionStatus");
                int code = root.path("ErrorCode").asInt(-1);
                String info = text(root, "ErrorInfo");
                if ("OK".equalsIgnoreCase(action) && code == 0) {
                    log.debug("Tencent IM REST OK path={}", path);
                    return true;
                }
                log.warn("Tencent IM REST biz path={} ActionStatus={} ErrorCode={} ErrorInfo={} bodySnippet={}",
                        path, action, code, info, snippet(resp.body()));
                // 常见：已是好友等幂等场景 ErrorCode 可能非 0，视为已尽力同步
                return false;
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                log.warn("Tencent IM REST interrupted path={}", path);
                return false;
            } catch (Exception e) {
                log.warn("Tencent IM REST failure path={}: {}", path, e.getMessage());
                if (i + 1 < attempts) {
                    sleepBackoff(i);
                }
            }
        }
        return false;
    }

    private static void sleepBackoff(int attemptIndex) {
        try {
            Thread.sleep(200L * (attemptIndex + 1));
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    private static String text(JsonNode n, String field) {
        JsonNode v = n.get(field);
        return v == null || v.isNull() ? "" : v.asText();
    }

    private static String snippet(String s) {
        if (s == null) {
            return "";
        }
        String t = s.replace('\n', ' ');
        return t.length() > 280 ? t.substring(0, 280) + "…" : t;
    }

    private static String escapeJson(String s) {
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
