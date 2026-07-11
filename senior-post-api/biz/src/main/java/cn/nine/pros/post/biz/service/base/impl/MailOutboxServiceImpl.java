package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.config.SeniorPostMailOutboxProperties;
import cn.nine.pros.post.biz.mapper.MailOutboxMapper;
import cn.nine.pros.post.biz.model.domain.MailOutboxDomain;
import cn.nine.pros.post.biz.service.base.MailOutboxService;
import cn.nine.pros.post.biz.service.biz.PasswordResetMailNotifier;
import cn.nine.pros.post.biz.service.biz.mail.MailOutboxTypes;
import cn.nine.pros.post.biz.support.PageQueryNormalize;
import com.alibaba.fastjson2.JSONObject;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class MailOutboxServiceImpl extends ServiceImpl<MailOutboxMapper, MailOutboxDomain>
        implements MailOutboxService {

    private final PasswordResetMailNotifier passwordResetMailNotifier;
    private final SeniorPostMailOutboxProperties outboxProperties;

    @Override
    public void enqueuePasswordReset(String toEmail, String localeTag, String code, int validMinutes) {
        enqueueCodeMail(MailOutboxTypes.PASSWORD_RESET, toEmail, localeTag, code, validMinutes);
    }

    @Override
    public void enqueueEmailVerify(String toEmail, String localeTag, String code, int validMinutes) {
        enqueueCodeMail(MailOutboxTypes.EMAIL_VERIFY, toEmail, localeTag, code, validMinutes);
    }

    private void enqueueCodeMail(String mailType, String toEmail, String localeTag, String code, int validMinutes) {
        JSONObject payload = new JSONObject();
        payload.put("code", code);
        payload.put("validMinutes", validMinutes);
        LocalDateTime now = LocalDateTime.now();
        MailOutboxDomain row = new MailOutboxDomain();
        row.setMailType(mailType);
        row.setToEmail(toEmail);
        row.setPayloadJson(payload.toJSONString());
        row.setLocaleTag(StringUtils.hasText(localeTag) ? localeTag.trim() : "en");
        row.setStatus("pending");
        row.setAttempts(0);
        row.setNextRetryAt(now);
        row.setLastError(null);
        row.setCreatedAt(now);
        row.setUpdatedAt(now);
        save(row);
    }

    @Override
    public void processPendingBatch() {
        int limit = Math.max(1, outboxProperties.getBatchSize());
        LocalDateTime now = LocalDateTime.now();
        List<MailOutboxDomain> rows = list(
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
            if (MailOutboxTypes.PASSWORD_RESET.equals(row.getMailType())
                    || MailOutboxTypes.EMAIL_VERIFY.equals(row.getMailType())) {
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
            updateById(row);
        } catch (RuntimeException e) {
            log.warn("mail outbox send failed id={} to={}", row.getId(), row.getToEmail(), e);
            int att = row.getAttempts() + 1;
            row.setAttempts(att);
            String msg = e.getMessage() != null ? e.getMessage() : e.getClass().getSimpleName();
            if (msg.length() > 2000) {
                msg = msg.substring(0, 2000);
            }
            row.setLastError(msg);
            int maxAttempts = Math.max(1, outboxProperties.getMaxAttempts());
            if (att >= maxAttempts) {
                row.setStatus("failed");
            } else {
                long delaySec = Math.min(3600L, 30L * (1L << Math.min(att, 6)));
                row.setNextRetryAt(now.plusSeconds(delaySec));
            }
            row.setUpdatedAt(now);
            updateById(row);
        }
    }

    @Override
    public Page<MailOutboxDomain> pageForAdmin(
            cn.nine.commons.data.page.PageQuery pageQuery,
            String toEmail, String mailType, String status,
            LocalDateTime createdFrom, LocalDateTime createdTo, String keyword) {
        LambdaQueryWrapper<MailOutboxDomain> qw = new LambdaQueryWrapper<MailOutboxDomain>()
                .orderByDesc(MailOutboxDomain::getCreatedAt);
        if (StringUtils.hasText(toEmail)) {
            qw.like(MailOutboxDomain::getToEmail, toEmail.trim());
        }
        if (StringUtils.hasText(mailType)) {
            qw.eq(MailOutboxDomain::getMailType, mailType.trim());
        }
        if (StringUtils.hasText(status)) {
            qw.eq(MailOutboxDomain::getStatus, status.trim());
        }
        if (createdFrom != null) {
            qw.ge(MailOutboxDomain::getCreatedAt, createdFrom);
        }
        if (createdTo != null) {
            qw.le(MailOutboxDomain::getCreatedAt, createdTo);
        }
        if (StringUtils.hasText(keyword)) {
            String kw = keyword.trim();
            qw.and(w -> w.like(MailOutboxDomain::getToEmail, kw)
                    .or()
                    .like(MailOutboxDomain::getPayloadJson, kw));
        }
        return page(PageQueryNormalize.mpPage(pageQuery, PageQueryNormalize.ADMIN_MAX_SIZE), qw);
    }

    @Override
    public MailOutboxDomain findById(Long id) {
        if (id == null) {
            return null;
        }
        return getById(id);
    }

    @Override
    public boolean retryFailed(long id) {
        LocalDateTime now = LocalDateTime.now();
        return update(new LambdaUpdateWrapper<MailOutboxDomain>()
                .eq(MailOutboxDomain::getId, id)
                .set(MailOutboxDomain::getStatus, "pending")
                .set(MailOutboxDomain::getLastError, null)
                .set(MailOutboxDomain::getNextRetryAt, now)
                .set(MailOutboxDomain::getUpdatedAt, now));
    }

    @Override
    public long countByStatus(String status) {
        if (!StringUtils.hasText(status)) {
            return 0;
        }
        return count(new LambdaQueryWrapper<MailOutboxDomain>()
                .eq(MailOutboxDomain::getStatus, status.trim()));
    }
}
