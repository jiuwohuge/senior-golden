package cn.nine.pros.post.biz.service.app.support;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.Collections;

@Service
@RequiredArgsConstructor
public class GoogleIdTokenVerifierService {

    private final AppMessages appMessages;

    @Value("${senior-post.oauth.google.client-id:}")
    private String googleWebClientId;

    public VerifiedGoogleIdentity verify(String idTokenString) {
        if (!StringUtils.hasText(googleWebClientId)) {
            throw new BadRequestException(appMessages.get("app.error.oauth.googleNotConfigured"));
        }
        if (!StringUtils.hasText(idTokenString)) {
            throw new BadRequestException(appMessages.get("app.error.oauth.invalidToken"));
        }
        try {
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                    new NetHttpTransport(), GsonFactory.getDefaultInstance())
                    .setAudience(Collections.singletonList(googleWebClientId.trim()))
                    .build();
            GoogleIdToken idToken = verifier.verify(idTokenString.trim());
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
            return new VerifiedGoogleIdentity(sub.trim(), email != null ? email.trim().toLowerCase() : null);
        } catch (BadRequestException e) {
            throw e;
        } catch (Exception e) {
            throw new BadRequestException(appMessages.get("app.error.oauth.invalidToken"));
        }
    }

    public record VerifiedGoogleIdentity(String sub, String email) {
    }
}
