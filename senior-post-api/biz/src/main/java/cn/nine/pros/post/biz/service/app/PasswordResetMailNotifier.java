package cn.nine.pros.post.biz.service.app;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

/**
 * 配置 {@code spring.mail.host} 且 {@code senior-post.mail.from} 非空时走 SMTP；否则仅打日志（本地开发）。
 */
@Slf4j
@Component
public class PasswordResetMailNotifier {

    @Autowired(required = false)
    private JavaMailSender mailSender;

    @Value("${senior-post.mail.from:}")
    private String from;

    @Value("${senior-post.mail.password-reset-subject:Senior Post 密码重置验证码}")
    private String subject;

    public void sendSixDigitCode(String toEmail, String code, int validMinutes) {
        String body = "您的密码重置验证码为：" + code + "\n有效期 " + validMinutes + " 分钟。如非本人操作请忽略。";
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
                "[password-reset] SMTP 未配置，验证码仅打印在日志。to={} code={} validMinutes={}",
                toEmail,
                code,
                validMinutes);
    }
}
