package cn.nine.pros.post.biz.service.app;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.config.SeniorPostAuthProperties;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.mapper.PasswordResetTokenMapper;
import cn.nine.pros.post.biz.model.domain.PasswordResetTokenDomain;
import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.biz.service.app.support.PasswordResetHasher;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.model.db.UserDTO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import cn.nine.pros.post.biz.service.app.mail.MailOutboxService;
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
    private final PasswordResetTokenMapper passwordResetTokenMapper;
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
        long recent = passwordResetTokenMapper.selectCount(
                new LambdaQueryWrapper<PasswordResetTokenDomain>()
                        .eq(PasswordResetTokenDomain::getUserId, user.getId())
                        .ge(PasswordResetTokenDomain::getCreatedAt, hourAgo));
        if (recent >= authProperties.getPasswordResetMaxRequestsPerHour()) {
            throw new BadRequestException(appMessages.get("app.error.passwordReset.rateLimit"));
        }

        PasswordResetTokenDomain last = passwordResetTokenMapper.selectOne(
                new LambdaQueryWrapper<PasswordResetTokenDomain>()
                        .eq(PasswordResetTokenDomain::getUserId, user.getId())
                        .orderByDesc(PasswordResetTokenDomain::getId)
                        .last("LIMIT 1"));
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
        row.setExpiresAt(now.plusMinutes(authProperties.getPasswordResetExpireMinutes()));
        row.setCreatedAt(now);
        passwordResetTokenMapper.insert(row);

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
        List<PasswordResetTokenDomain> candidates = passwordResetTokenMapper.selectList(
                new LambdaQueryWrapper<PasswordResetTokenDomain>()
                        .eq(PasswordResetTokenDomain::getUserId, user.getId())
                        .isNull(PasswordResetTokenDomain::getUsedAt)
                        .gt(PasswordResetTokenDomain::getExpiresAt, now)
                        .orderByDesc(PasswordResetTokenDomain::getId)
                        .last("LIMIT 10"));

        PasswordResetTokenDomain matched = null;
        for (PasswordResetTokenDomain t : candidates) {
            if (constantTimeHexEquals(
                    t.getCodeHash(),
                    PasswordResetHasher.hexHash(authProperties.getPasswordResetPepper(), user.getId(), code))) {
                matched = t;
                break;
            }
        }
        if (matched == null) {
            throw new BadRequestException(appMessages.get("app.error.code.invalid"));
        }

        userService.update(
                new LambdaUpdateWrapper<UserDomain>()
                        .eq(UserDomain::getId, user.getId())
                        .set(UserDomain::getPasswordHash, passwordEncoder.encode(newPassword))
                        .set(UserDomain::getUpdatedAt, now)
                        .set(UserDomain::getUpdatedBy, user.getId()));

        matched.setUsedAt(now);
        passwordResetTokenMapper.updateById(matched);
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
