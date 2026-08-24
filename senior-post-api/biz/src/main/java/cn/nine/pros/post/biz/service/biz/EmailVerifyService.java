package cn.nine.pros.post.biz.service.biz;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.config.SeniorPostAuthProperties;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.PasswordResetTokenDomain;
import cn.nine.pros.post.biz.model.domain.UserIdentityDomain;
import cn.nine.pros.post.biz.service.base.MailOutboxService;
import cn.nine.pros.post.biz.service.base.PasswordResetTokenService;
import cn.nine.pros.post.biz.service.base.UserIdentityService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.biz.service.biz.support.PasswordResetHasher;
import cn.nine.pros.post.client.model.db.UserDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Locale;

/**
 * 邮箱验证绑定（§2.9）与中风险登录二次验证码。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class EmailVerifyService {

    public static final String PURPOSE_EMAIL_VERIFY = "email_verify";
    public static final String PURPOSE_LOGIN_CHALLENGE = "login_challenge";
    public static final String PURPOSE_BIND_EMAIL = "bind_email";

    private static final SecureRandom RANDOM = new SecureRandom();

    private final UserService userService;
    private final UserIdentityService userIdentityService;
    private final PasswordResetTokenService passwordResetTokenService;
    private final MailOutboxService mailOutboxService;
    private final SeniorPostAuthProperties authProperties;
    private final AppMessages appMessages;

    /**
     * 向当前邮箱账号发送验证绑定码；三方账号无邮箱 identity 时拒绝。
     */
    @Transactional(rollbackFor = Exception.class)
    public void sendEmailVerifyCode(long userId) {
        UserIdentityDomain emailIdent = requireEmailIdentity(userId);
        UserDTO user = userService.findById(userId);
        if (user == null) {
            throw new BadRequestException(appMessages.get("app.error.session.invalid"));
        }
        if (Boolean.TRUE.equals(user.getEmailVerified())) {
            log.info("email verify skip: already verified, userId={}", userId);
            return;
        }
        issueCode(userId, emailIdent.getProviderUid(), PURPOSE_EMAIL_VERIFY);
        log.info("email verify code enqueued, userId={}", userId);
    }

    /**
     * 访客绑定邮箱：向目标邮箱发码（identity 尚未存在）。
     * 哈希混入邮箱，防止用 A 的验证码绑定 B。
     */
    @Transactional(rollbackFor = Exception.class)
    public void sendBindEmailCode(long userId, String toEmail) {
        issueCode(userId, toEmail, PURPOSE_BIND_EMAIL, toEmail);
        log.info("bind-email code enqueued, userId={}", userId);
    }

    /** 消费绑定邮箱验证码；邮箱须与发码时一致。 */
    @Transactional(rollbackFor = Exception.class)
    public void consumeBindEmailCode(long userId, String toEmail, String rawCode) {
        consumeCode(userId, rawCode, PURPOSE_BIND_EMAIL, toEmail);
    }

    @Transactional(rollbackFor = Exception.class)
    public void confirmEmailVerify(long userId, String rawCode) {
        consumeCode(userId, rawCode, PURPOSE_EMAIL_VERIFY);
        userService.markEmailVerified(userId);
        log.info("email verified, userId={}", userId);
    }

    /** 中风险登录：向邮箱发挑战码（无需已登录）。 */
    @Transactional(rollbackFor = Exception.class)
    public void sendLoginChallenge(String rawEmail) {
        String email = rawEmail.trim().toLowerCase();
        UserIdentityDomain ident = userIdentityService.findActiveEmailByUid(email);
        if (ident == null || userService.findById(ident.getUserId()) == null) {
            log.debug("login challenge: unknown email (silent)");
            return;
        }
        issueCode(ident.getUserId(), email, PURPOSE_LOGIN_CHALLENGE);
        log.info("login challenge code enqueued, userId={}", ident.getUserId());
    }

    /**
     * 校验登录挑战码；成功返回 userId。
     */
    @Transactional(rollbackFor = Exception.class)
    public long confirmLoginChallenge(String rawEmail, String rawCode) {
        String email = rawEmail.trim().toLowerCase();
        UserIdentityDomain ident = userIdentityService.findActiveEmailByUid(email);
        if (ident == null || userService.findById(ident.getUserId()) == null) {
            throw new BadRequestException(appMessages.get("app.error.code.invalid"));
        }
        consumeCode(ident.getUserId(), rawCode, PURPOSE_LOGIN_CHALLENGE);
        return ident.getUserId();
    }

    private UserIdentityDomain requireEmailIdentity(long userId) {
        UserIdentityDomain ident = userIdentityService.findActiveEmailIdentity(userId);
        if (ident == null || !StringUtils.hasText(ident.getProviderUid())) {
            throw new BadRequestException(appMessages.get("app.error.emailVerify.notEmailAccount"));
        }
        return ident;
    }

    private void issueCode(long userId, String toEmail, String purpose) {
        issueCode(userId, toEmail, purpose, null);
    }

    private void issueCode(long userId, String toEmail, String purpose, String hashExtra) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime hourAgo = now.minusHours(1);
        long recent = passwordResetTokenService.countCreatedSince(userId, purpose, hourAgo);
        if (recent >= authProperties.getPasswordResetMaxRequestsPerHour()) {
            throw new BadRequestException(appMessages.get("app.error.passwordReset.rateLimit"));
        }
        int n = 100_000 + RANDOM.nextInt(900_000);
        String code = String.valueOf(n);
        String hashMaterial = bindHashMaterial(code, hashExtra);
        String hash = PasswordResetHasher.hexHash(authProperties.getPasswordResetPepper(), userId, hashMaterial);
        PasswordResetTokenDomain row = new PasswordResetTokenDomain();
        row.setUserId(userId);
        row.setCodeHash(hash);
        row.setPurpose(purpose);
        row.setExpiresAt(now.plusMinutes(authProperties.getPasswordResetExpireMinutes()));
        row.setCreatedAt(now);
        passwordResetTokenService.save(row);

        Locale loc = LocaleContextHolder.getLocale();
        String localeTag = loc != null ? loc.toLanguageTag() : "en";
        mailOutboxService.enqueueEmailVerify(
                toEmail, localeTag, code, authProperties.getPasswordResetExpireMinutes());
    }

    private void consumeCode(long userId, String rawCode, String purpose) {
        consumeCode(userId, rawCode, purpose, null);
    }

    private void consumeCode(long userId, String rawCode, String purpose, String hashExtra) {
        if (!StringUtils.hasText(rawCode)) {
            throw new BadRequestException(appMessages.get("app.error.code.invalid"));
        }
        String code = rawCode.trim();
        // 本地调试：666666 跳过哈希，无需真实邮件。生产 debug-master-code 必须为空。
        if (authProperties.matchesDebugMasterCode(code)) {
            log.warn("email verify debug master code accepted, userId={}, purpose={}", userId, purpose);
            return;
        }
        LocalDateTime now = LocalDateTime.now();
        String hashMaterial = bindHashMaterial(code, hashExtra);
        String expectHash = PasswordResetHasher.hexHash(
                authProperties.getPasswordResetPepper(), userId, hashMaterial);
        PasswordResetTokenDomain tok = passwordResetTokenService.findValidByUserPurposeAndHash(
                userId, purpose, expectHash, now);
        if (tok == null) {
            throw new BadRequestException(appMessages.get("app.error.code.invalid"));
        }
        tok.setUsedAt(now);
        passwordResetTokenService.updateById(tok);
    }

    /** 绑定邮箱时把目标邮箱编进哈希，避免串用验证码。 */
    private static String bindHashMaterial(String code, String hashExtra) {
        if (!StringUtils.hasText(hashExtra)) {
            return code;
        }
        return code + "\n" + hashExtra.trim().toLowerCase();
    }
}
