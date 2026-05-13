package cn.nine.pros.post.biz.service.app;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.util.Locale;

/**
 * 配置 {@code spring.mail.host} 且 {@code senior-post.mail.from} 非空时走 SMTP；否则仅打日志（本地开发）。
 * 文案键：{@code app.mail.passwordReset.*}（见 messages/app*.properties）。
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class PasswordResetMailNotifier {

    @Autowired(required = false)
    private JavaMailSender mailSender;

    private final MessageSource messageSource;

    @org.springframework.beans.factory.annotation.Value("${senior-post.mail.from:}")
    private String from;

    public void sendSixDigitCode(String toEmail, String code, int validMinutes) {
        sendSixDigitCode(toEmail, code, validMinutes, Locale.ENGLISH.toLanguageTag());
    }

    /**
     * @param localeTag BCP47，如 zh-CN、en；用于 {@link MessageSource} 选文案
     */
    public void sendSixDigitCode(String toEmail, String code, int validMinutes, String localeTag) {
        Locale locale = toLocale(localeTag);
        String subject = messageSource.getMessage(
                "app.mail.passwordReset.subject", null, "Senior Post — verification code", locale);
        String body = messageSource.getMessage(
                "app.mail.passwordReset.body", new Object[] {code, validMinutes}, locale);
        sendPlain(toEmail, subject, body);
    }

    public void sendPlain(String toEmail, String subject, String body) {
        if (mailSender != null && StringUtils.hasText(from)) {
            try {
                SimpleMailMessage msg = new SimpleMailMessage();
                msg.setFrom(from);
                msg.setTo(toEmail);
                msg.setSubject(subject);
                msg.setText(body);
                mailSender.send(msg);
                return;
            } catch (RuntimeException e) {
                log.error("password reset mail send failed, to={}", toEmail, e);
                throw e;
            }
        }
        log.warn(
                "[password-reset] SMTP 未配置，验证码仅打印在日志。to={} subject={} bodyPreview={}",
                toEmail,
                subject,
                body != null && body.length() > 80 ? body.substring(0, 80) + "…" : body);
    }

    private static Locale toLocale(String localeTag) {
        if (!StringUtils.hasText(localeTag)) {
            return Locale.ENGLISH;
        }
        Locale loc = Locale.forLanguageTag(localeTag.trim().replace('_', '-'));
        if (loc.getLanguage() == null || loc.getLanguage().isEmpty()) {
            return Locale.ENGLISH;
        }
        return loc;
    }
}
