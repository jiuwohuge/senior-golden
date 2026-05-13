package cn.nine.pros.post.biz.service.app.mail;

import cn.nine.pros.post.biz.config.SeniorPostMailOutboxProperties;
import cn.nine.pros.post.biz.mapper.MailOutboxMapper;
import cn.nine.pros.post.biz.model.domain.MailOutboxDomain;
import cn.nine.pros.post.biz.service.app.PasswordResetMailNotifier;
import com.alibaba.fastjson2.JSONObject;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class MailOutboxServiceImpl implements MailOutboxService {

    private final MailOutboxMapper mailOutboxMapper;
    private final PasswordResetMailNotifier passwordResetMailNotifier;
    private final SeniorPostMailOutboxProperties outboxProperties;

    @Override
    public void enqueuePasswordReset(String toEmail, String localeTag, String code, int validMinutes) {
        JSONObject payload = new JSONObject();
        payload.put("code", code);
        payload.put("validMinutes", validMinutes);
        LocalDateTime now = LocalDateTime.now();
        MailOutboxDomain row = new MailOutboxDomain();
        row.setMailType(MailOutboxTypes.PASSWORD_RESET);
        row.setToEmail(toEmail);
        row.setPayloadJson(payload.toJSONString());
        row.setLocaleTag(StringUtils.hasText(localeTag) ? localeTag.trim() : "en");
        row.setStatus("pending");
        row.setAttempts(0);
        row.setNextRetryAt(now);
        row.setLastError(null);
        row.setCreatedAt(now);
        row.setUpdatedAt(now);
        mailOutboxMapper.insert(row);
    }

    @Override
    public void processPendingBatch() {
        int limit = Math.max(1, outboxProperties.getBatchSize());
        LocalDateTime now = LocalDateTime.now();
        List<MailOutboxDomain> rows = mailOutboxMapper.selectList(
                new LambdaQueryWrapper<MailOutboxDomain>()
                        .eq(MailOutboxDomain::getStatus, "pending")
                        .le(MailOutboxDomain::getNextRetryAt, now)
                        .orderByAsc(MailOutboxDomain::getId)
                        .last("LIMIT " + limit));
        for (MailOutboxDomain row : rows) {
            processOne(row, now);
        }
    }

    private void processOne(MailOutboxDomain row, LocalDateTime now) {
        try {
            if (MailOutboxTypes.PASSWORD_RESET.equals(row.getMailType())) {
                JSONObject p = JSONObject.parseObject(row.getPayloadJson());
                String code = p.getString("code");
                int validMinutes = p.getIntValue("validMinutes", 15);
                passwordResetMailNotifier.sendSixDigitCode(
                        row.getToEmail(), code, validMinutes, row.getLocaleTag());
            } else {
                throw new IllegalStateException("unknown mail_type: " + row.getMailType());
            }
            row.setStatus("sent");
            row.setLastError(null);
            row.setUpdatedAt(now);
            mailOutboxMapper.updateById(row);
        } catch (RuntimeException e) {
            log.warn("mail outbox send failed id={} to={}", row.getId(), row.getToEmail(), e);
            int att = row.getAttempts() + 1;
            row.setAttempts(att);
            String msg = e.getMessage() != null ? e.getMessage() : e.getClass().getSimpleName();
            if (msg.length() > 2000) {
                msg = msg.substring(0, 2000);
            }
            row.setLastError(msg);
            if (att >= outboxProperties.getMaxAttempts()) {
                row.setStatus("failed");
            } else {
                row.setStatus("pending");
                row.setNextRetryAt(now.plusSeconds(backoffSeconds(att)));
            }
            row.setUpdatedAt(LocalDateTime.now());
            mailOutboxMapper.updateById(row);
        }
    }

    private long backoffSeconds(int attemptsAfterFailure) {
        int cap = 3600;
        int base = Math.max(5, outboxProperties.getInitialBackoffSeconds());
        int exp = Math.min(attemptsAfterFailure - 1, 6);
        long v = base;
        for (int i = 0; i < exp; i++) {
            v = Math.min(cap, v * 2L);
        }
        return v;
    }
}
