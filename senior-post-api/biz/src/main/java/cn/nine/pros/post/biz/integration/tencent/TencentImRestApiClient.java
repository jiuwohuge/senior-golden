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
import java.util.Collection;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;
import java.util.stream.Collectors;

/**
 * 腾讯 IM REST（新加坡数据中心）：account_import、sns/friend_add。
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

    public boolean isRestConfigured() {
        return props.getSdkAppId() > 0
                && StringUtils.hasText(props.getSecretKey())
                && StringUtils.hasText(props.getRestApiIdentifier());
    }

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

    public boolean accountImportBatch(Collection<String> userIds) {
        List<String> ids = userIds.stream()
                .filter(StringUtils::hasText)
                .distinct()
                .collect(Collectors.toList());
        if (ids.isEmpty()) {
            return false;
        }
        String accountsJson = ids.stream()
                .map(id -> "\"" + escapeJson(id) + "\"")
                .collect(Collectors.joining(","));
        String body = "{\"Accounts\":[" + accountsJson + "]}";
        if (post("/v4/im_open_login_svc/multiaccount_import", body)) {
            return true;
        }
        return ids.stream().allMatch(this::accountImport);
    }

    public boolean accountImported(String userIdStr) {
        if (!StringUtils.hasText(userIdStr)) {
            return false;
        }
        String body = """
                {"CheckItem":[{"UserID":"%s"}]}
                """
                .formatted(escapeJson(userIdStr))
                .trim();
        JsonNode root = postForJson("/v4/im_open_login_svc/account_check", body);
        if (root == null) {
            return false;
        }
        JsonNode items = root.path("ResultItem");
        if (!items.isArray() || items.isEmpty()) {
            return false;
        }
        String status = text(items.get(0), "AccountStatus");
        return "Imported".equalsIgnoreCase(status);
    }

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

    public boolean friendDeleteBoth(String fromAccount, String toAccount) {
        if (!StringUtils.hasText(fromAccount) || !StringUtils.hasText(toAccount)) {
            return false;
        }
        String body = """
                {"From_Account":"%s","To_Account":["%s"],"DeleteType":"Delete_Type_Both"}
                """
                .formatted(escapeJson(fromAccount), escapeJson(toAccount))
                .trim();
        return post("/v4/sns/friend_delete", body);
    }

    private JsonNode postForJson(String path, String jsonBody) {
        if (!isRestConfigured()) {
            log.warn("Tencent IM REST skipped: not configured");
            return null;
        }
        return executePost(path, jsonBody);
    }

    private boolean post(String path, String jsonBody) {
        if (!isRestConfigured()) {
            log.warn("Tencent IM REST skipped: sdk-app-id, secret-key or rest-api-identifier missing");
            return false;
        }
        return executePost(path, jsonBody) != null;
    }

    private JsonNode executePost(String path, String jsonBody) {
        int sdk = (int) Math.min(Integer.MAX_VALUE, Math.max(0, props.getSdkAppId()));
        TLSSigAPIv2 api = new TLSSigAPIv2(sdk, props.getSecretKey().trim());
        String admin = props.getRestApiIdentifier().trim();
        int expire = Math.max(60, props.getRestApiUserSigExpireSeconds());
        String sig = api.genUserSig(admin, expire);
        String host = restHost();

        int attempts = 1 + Math.max(0, props.getRestApiMaxRetries());
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
                    log.warn("Tencent IM REST HTTP {} host={} path={} bodySnippet={}",
                            resp.statusCode(), host, path, snippet(resp.body()));
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
                    return root;
                }
                if (isIdempotentSuccess(path, code)) {
                    return root;
                }
                if (code == 60026) {
                    log.error(
                            "Tencent IM REST ErrorCode=60026: REST host must be Singapore adminapisgp.im.qcloud.com for this app. "
                                    + "Current host={} sdkAppId={}",
                            host,
                            props.getSdkAppId());
                } else {
                    log.warn(
                            "Tencent IM REST biz host={} path={} ActionStatus={} ErrorCode={} ErrorInfo={}",
                            host,
                            path,
                            action,
                            code,
                            info);
                }
                return null;
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                log.warn("Tencent IM REST interrupted path={}", path);
                return null;
            } catch (Exception e) {
                log.warn("Tencent IM REST failure path={}: {}", path, e.getMessage());
                if (i + 1 < attempts) {
                    sleepBackoff(i);
                }
            }
        }
        return null;
    }

    private String restHost() {
        String host = props.getRestApiHost();
        if (!StringUtils.hasText(host)) {
            return "adminapisgp.im.qcloud.com";
        }
        return host.trim().replaceFirst("^https?://", "").replaceAll("/+$", "");
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

    private static boolean isIdempotentSuccess(String path, int errorCode) {
        if (errorCode == 0) {
            return true;
        }
        if ((path.contains("account_import") || path.contains("multiaccount_import"))
                && (errorCode == 70169 || errorCode == 70402 || errorCode == 70500)) {
            return true;
        }
        if (path.contains("friend_add") && (errorCode == 30001 || errorCode == 30015)) {
            return true;
        }
        return false;
    }

    private static String escapeJson(String s) {
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
