package cn.nine.pros.post.biz.service.biz.support.oauth;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.config.GoogleOAuthProperties;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.client.common.constant.AuthProvider;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;

/**
 * Google ID Token 校验：生产走 Google API Client；本机可启用 mock 前缀（非 prod）。
 * <p>替代原 {@code GoogleIdTokenVerifierService}；不记录 Token 或邮箱全文。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class GoogleIdentityVerifier implements ExternalIdentityVerifier {

    static final String MOCK_PREFIX = "mock-google:";

    private final AppMessages appMessages;
    private final GoogleOAuthProperties properties;
    private final Environment environment;

    /**
     * 校验 Google idToken（或本机 mock 串），返回已验证身份。
     *
     * @param idTokenString 客户端 idToken；空白非法
     * @return provider=google、subject=sub、可选小写 email
     */
    @Override
    public VerifiedExternalIdentity verify(String idTokenString) {
        if (!StringUtils.hasText(idTokenString)) {
            throw new BadRequestException(appMessages.get("app.error.oauth.invalidToken"));
        }
        String token = idTokenString.trim();
        if (token.startsWith(MOCK_PREFIX)) {
            return verifyMockToken(token);
        }
        return verifyGoogleJwt(token);
    }

    /**
     * 本机 QA mock：仅在 mockEnabled 且非 prod/production profile 时接受。
     * mock 被禁用或生产 profile 时一律 invalidToken，且不把 mock 串交给 Google。
     */
    private VerifiedExternalIdentity verifyMockToken(String token) {
        if (!isMockAllowed()) {
            throw new BadRequestException(appMessages.get("app.error.oauth.invalidToken"));
        }
        String remainder = token.substring(MOCK_PREFIX.length());
        String[] parts = remainder.split(":", 2);
        String sub = parts.length > 0 ? parts[0] : "";
        if (!StringUtils.hasText(sub)) {
            throw new BadRequestException(appMessages.get("app.error.oauth.invalidToken"));
        }
        String email = null;
        if (parts.length > 1 && StringUtils.hasText(parts[1])) {
            email = parts[1].trim().toLowerCase();
        }
        String subject = sub.trim();
        log.info("google mock identity accepted, subject={}", subject);
        return new VerifiedExternalIdentity(AuthProvider.GOOGLE, subject, email);
    }

    /** mockEnabled 为 true，且活跃 profile 不含 prod/production（忽略大小写）。 */
    private boolean isMockAllowed() {
        if (!properties.isMockEnabled()) {
            return false;
        }
        String[] profiles = environment.getActiveProfiles();
        if (profiles == null) {
            return true;
        }
        for (String profile : profiles) {
            if (profile == null) {
                continue;
            }
            String normalized = profile.trim();
            if ("prod".equalsIgnoreCase(normalized) || "production".equalsIgnoreCase(normalized)) {
                return false;
            }
        }
        return true;
    }

    /** 真实 JWT：需已配置至少一个 audience；校验签名/aud/iss/exp 与 email_verified。 */
    private VerifiedExternalIdentity verifyGoogleJwt(String token) {
        List<String> audiences = properties.resolveAudiences();
        if (audiences.isEmpty()) {
            throw new BadRequestException(appMessages.get("app.error.oauth.googleNotConfigured"));
        }
        try {
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                    new NetHttpTransport(), GsonFactory.getDefaultInstance())
                    .setAudience(audiences)
                    .build();
            GoogleIdToken idToken = verifier.verify(token);
            if (idToken == null) {
                throw new BadRequestException(appMessages.get("app.error.oauth.invalidToken"));
            }
            GoogleIdToken.Payload payload = idToken.getPayload();
            String sub = payload.getSubject();
            if (!StringUtils.hasText(sub)) {
                throw new BadRequestException(appMessages.get("app.error.oauth.invalidToken"));
            }
            Boolean emailVerified = payload.getEmailVerified();
            if (emailVerified != null && !emailVerified) {
                throw new BadRequestException(appMessages.get("app.error.oauth.emailNotVerified"));
            }
            String email = payload.getEmail();
            String normalizedEmail = email != null ? email.trim().toLowerCase() : null;
            log.info("google id token verified, subject={}", sub.trim());
            return new VerifiedExternalIdentity(AuthProvider.GOOGLE, sub.trim(), normalizedEmail);
        } catch (BadRequestException e) {
            throw e;
        } catch (Exception e) {
            log.warn("google id token verify failed: {}", e.getMessage());
            throw new BadRequestException(appMessages.get("app.error.oauth.invalidToken"));
        }
    }
}
