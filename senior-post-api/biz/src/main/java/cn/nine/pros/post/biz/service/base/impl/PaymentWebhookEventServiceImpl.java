package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.mapper.PaymentWebhookEventMapper;
import cn.nine.pros.post.biz.model.domain.PaymentWebhookEventDomain;
import cn.nine.pros.post.biz.service.base.PaymentWebhookEventService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;

/**
 * 支付 webhook 事件 ServiceImpl。
 */
@Slf4j
@Service
public class PaymentWebhookEventServiceImpl
        extends ServiceImpl<PaymentWebhookEventMapper, PaymentWebhookEventDomain>
        implements PaymentWebhookEventService {

    @Override
    public PaymentWebhookEventDomain findByProviderAndEventId(String provider, String eventIdOrMessageId) {
        if (!StringUtils.hasText(provider) || !StringUtils.hasText(eventIdOrMessageId)) {
            return null;
        }
        return getOne(new LambdaQueryWrapper<PaymentWebhookEventDomain>()
                .eq(PaymentWebhookEventDomain::getProvider, provider.trim())
                .eq(PaymentWebhookEventDomain::getEventIdOrMessageId, eventIdOrMessageId.trim())
                .eq(PaymentWebhookEventDomain::isDelFlag, false)
                .last("LIMIT 1"));
    }

    @Override
    public PaymentWebhookEventDomain insertIfAbsent(PaymentWebhookEventDomain row, long actorId) {
        if (row == null || !StringUtils.hasText(row.getProvider()) || !StringUtils.hasText(row.getEventIdOrMessageId())) {
            return null;
        }
        PaymentWebhookEventDomain existing = findByProviderAndEventId(row.getProvider(), row.getEventIdOrMessageId());
        if (existing != null) {
            log.debug("webhook event already present, provider={}, eventId={}",
                    row.getProvider(), row.getEventIdOrMessageId());
            return existing;
        }
        if (row.getReceivedAt() == null) {
            row.setReceivedAt(LocalDateTime.now());
        }
        if (!StringUtils.hasText(row.getProcessStatus())) {
            row.setProcessStatus("received");
        }
        if (row.getRetryCount() == null) {
            row.setRetryCount(0);
        }
        row.initAudit(actorId);
        save(row);
        log.info("webhook event inserted, id={}, provider={}, eventId={}, type={}",
                row.getId(), row.getProvider(), row.getEventIdOrMessageId(), row.getEventType());
        return row;
    }
}
