package cn.nine.pros.post.biz.service.app;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;

/**
 * App 用户 JWT（与请求头 {@code Token} 对齐；生产环境请配置足够长的 secret 并与网关/框架验签策略一致）。
 */
@Service
public class AppJwtService {

    @Value("${senior-post.app.jwt.secret:dev-senior-post-jwt-secret-change-me-in-prod!!}")
    private String secret;

    @Value("${senior-post.app.jwt.expire-days:7}")
    private long expireDays;

    public String createToken(long userId) {
        Instant now = Instant.now();
        Instant exp = now.plus(expireDays, ChronoUnit.DAYS);
        return Jwts.builder()
                .subject(String.valueOf(userId))
                .issuedAt(Date.from(now))
                .expiration(Date.from(exp))
                .signWith(signingKey())
                .compact();
    }

    private SecretKey signingKey() {
        byte[] raw = secret.getBytes(StandardCharsets.UTF_8);
        try {
            raw = MessageDigest.getInstance("SHA-256").digest(raw);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
        return Keys.hmacShaKeyFor(raw);
    }
}
