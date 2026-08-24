package cn.nine.pros.post.biz.service.biz;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.config.SeniorPostAuthProperties;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.PasswordResetTokenDomain;
import cn.nine.pros.post.biz.model.domain.UserIdentityDomain;
import cn.nine.pros.post.biz.service.biz.support.PasswordResetHasher;
import cn.nine.pros.post.biz.service.base.PasswordResetTokenService;
import cn.nine.pros.post.biz.service.base.UserIdentityService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.biz.service.base.MailOutboxService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Locale;

@Slf4j
@Service
@RequiredArgsConstructor
public class PasswordResetService {

    private static final SecureRandom RANDOM = new SecureRandom();

    private final UserService userService;
    private final UserIdentityService userIdentityService;
    private final PasswordResetTokenService passwordResetTokenService;
    private final PasswordEncoder passwordEncoder;
    private final MailOutboxService mailOutboxService;
    private final SeniorPostAuthProperties authProperties;
    private final AppMessages appMessages;

    /**
     * 防枚举：邮箱不存在或账号不可用时与成功返回一致（无异常）。
     */
    @Transactional(rollbackFor = Exception.class)
    public void requestForgotPassword(String rawEmail) {
        String email = rawEmail.trim().toLowerCase();
        UserDTO user = userService.findByEmail(email);
        if (user == null) {
            log.debug("password reset: unknown email (silent)");
            return;
        }
        if (!isLoginAllowed(user)) {
            log.debug("password reset: user not active (silent)");
            return;
        }

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime hourAgo = now.minusHours(1);
        long recent = passwordResetTokenService.countCreatedSince(user.getId(), null, hourAgo);
        if (recent >= authProperties.getPasswordResetMaxRequestsPerHour()) {
            throw new BadRequestException(appMessages.get("app.error.passwordReset.rateLimit"));
        }

        PasswordResetTokenDomain last = passwordResetTokenService.findLatestByUserId(user.getId());
        if (last != null
                && last.getCreatedAt() != null
                && last.getCreatedAt().isAfter(now.minusSeconds(authProperties.getPasswordResetMinIntervalSeconds()))) {
            throw new BadRequestException(appMessages.get("app.error.passwordReset.cooldown"));
        }

        int n = 100_000 + RANDOM.nextInt(900_000);
        String code = String.valueOf(n);
        String hash = PasswordResetHasher.hexHash(authProperties.getPasswordResetPepper(), user.getId(), code);

        PasswordResetTokenDomain row = new PasswordResetTokenDomain();
        row.setUserId(user.getId());
        row.setCodeHash(hash);
        row.setPurpose("password_reset");
        row.setExpiresAt(now.plusMinutes(authProperties.getPasswordResetExpireMinutes()));
        row.setCreatedAt(now);
        passwordResetTokenService.save(row);

        Locale loc = LocaleContextHolder.getLocale();
        String localeTag = loc != null ? loc.toLanguageTag() : "en";
        mailOutboxService.enqueuePasswordReset(
                email, localeTag, code, authProperties.getPasswordResetExpireMinutes());
    }

    @Transactional(rollbackFor = Exception.class)
    public void completeReset(String rawEmail, String rawCode, String newPassword) {
        if (newPassword == null || newPassword.length() < 8) {
            throw new BadRequestException(appMessages.get("app.error.password.tooShort"));
        }
        String email = rawEmail.trim().toLowerCase();
        String code = rawCode.trim();
        if (code.isEmpty()) {
            throw new BadRequestException(appMessages.get("app.error.code.invalid"));
        }

        UserDTO user = userService.findByEmail(email);
        if (user == null || !isLoginAllowed(user)) {
            throw new BadRequestException(appMessages.get("app.error.code.invalid"));
        }

        LocalDateTime now = LocalDateTime.now();
        PasswordResetTokenDomain matched = findMatchedResetToken(user.getId(), code, now);
        if (matched == null && !authProperties.matchesDebugMasterCode(code)) {
            throw new BadRequestException(appMessages.get("app.error.code.invalid"));
        }
        if (matched == null) {
            log.warn("password reset debug master code accepted, userId={}", user.getId());
        }

        UserIdentityDomain emailIdent = userIdentityService.findActiveEmailIdentity(user.getId());
        if (emailIdent == null) {
            throw new BadRequestException(appMessages.get("app.error.code.invalid"));
        }
        userIdentityService.updatePasswordHash(
                emailIdent.getId(), passwordEncoder.encode(newPassword), user.getId(), now);
        userService.touchUpdatedAt(user.getId());

        if (matched != null) {
            matched.setUsedAt(now);
            passwordResetTokenService.updateById(matched);
        }
    }

    private PasswordResetTokenDomain findMatchedResetToken(long userId, String code, LocalDateTime now) {
        List<PasswordResetTokenDomain> candidates =
                passwordResetTokenService.listValidPasswordResetCandidates(userId, now, 10);
        for (PasswordResetTokenDomain t : candidates) {
            if (constantTimeHexEquals(
                    t.getCodeHash(),
                    PasswordResetHasher.hexHash(authProperties.getPasswordResetPepper(), userId, code))) {
                return t;
            }
        }
        return null;
    }

    private static boolean isLoginAllowed(UserDTO dto) {
        Object st = dto.getStatus();
        int v;
        if (st instanceof Number n) {
            v = n.intValue();
        } else if (st instanceof String s) {
            v = Integer.parseInt(s);
        } else {
            return false;
        }
        return v == 1;
    }

    private static boolean constantTimeHexEquals(String a, String b) {
        if (a == null || b == null || a.length() != b.length()) {
            return false;
        }
        return MessageDigest.isEqual(a.getBytes(StandardCharsets.US_ASCII), b.getBytes(StandardCharsets.US_ASCII));
    }
}
