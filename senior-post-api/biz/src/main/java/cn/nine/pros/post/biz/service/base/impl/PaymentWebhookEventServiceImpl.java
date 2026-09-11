package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.mapper.PaymentWebhookEventMapper;
import cn.nine.pros.post.biz.model.domain.PaymentWebhookEventDomain;
import cn.nine.pros.post.biz.service.base.PaymentWebhookEventService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 支付 webhook 事件 ServiceImpl。
 */
@Slf4j
@Service
public class PaymentWebhookEventServiceImpl
        extends ServiceImpl<PaymentWebhookEventMapper, PaymentWebhookEventDomain>
        implements PaymentWebhookEventService {

    private static final int DEFAULT_LOOKUP_LIMIT = 50;

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

    @Override
    public List<PaymentWebhookEventDomain> listForPurchaseLookup(
            String provider, String storeProductId, LocalDateTime from, int limit) {
        if (!StringUtils.hasText(provider)) {
            return List.of();
        }
        int safeLimit = limit > 0 ? Math.min(limit, 200) : DEFAULT_LOOKUP_LIMIT;
        QueryWrapper<PaymentWebhookEventDomain> qw = new QueryWrapper<PaymentWebhookEventDomain>()
                .eq("del_flag", false)
                .eq("provider", provider.trim())
                .orderByDesc("received_at")
                .last("LIMIT " + safeLimit);
        if (from != null) {
            qw.ge("received_at", from);
        }
        if (StringUtils.hasText(storeProductId)) {
            qw.apply("payload_json::text ILIKE {0}", "%" + storeProductId.trim() + "%");
        }
        return list(qw);
    }
}
