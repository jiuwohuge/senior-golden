package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.PaymentWebhookEventDomain;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 * 支付 webhook 事件 Base Service（幂等插入预留）。
 */
public interface PaymentWebhookEventService extends IService<PaymentWebhookEventDomain> {

    PaymentWebhookEventDomain findByProviderAndEventId(String provider, String eventIdOrMessageId);

    /**
     * 幂等插入：已存在同 provider+eventId 则返回已有行，不覆盖。
     */
    PaymentWebhookEventDomain insertIfAbsent(PaymentWebhookEventDomain row, long actorId);
}
