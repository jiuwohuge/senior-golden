package cn.nine.pros.post.biz.service.biz.impl;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.pros.post.biz.config.PushProperties;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.NotificationDeliveryDomain;
import cn.nine.pros.post.biz.schedule.job.NotificationOutboxJob;
import cn.nine.pros.post.biz.service.base.NotificationDeliveryService;
import cn.nine.pros.post.biz.service.biz.AppPushBizService;
import cn.nine.pros.post.biz.service.push.NotificationEnqueueService;
import cn.nine.pros.post.biz.service.push.NotificationOutboxDispatchService;
import cn.nine.pros.post.client.model.input.app.PushMockEnqueueInDto;
import cn.nine.pros.post.client.model.out.PushMockEnqueueVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * App 推送 Biz：QA mock-enqueue 走 Outbox + 可选 Job。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AppPushBizServiceImpl implements AppPushBizService {

    private final PushProperties pushProperties;
    private final Environment environment;
    private final AppMessages appMessages;
    private final NotificationEnqueueService notificationEnqueueService;
    private final NotificationOutboxJob notificationOutboxJob;
    private final NotificationDeliveryService notificationDeliveryService;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public PushMockEnqueueVO mockEnqueue(long currentUserId, PushMockEnqueueInDto body) {
        if (!pushProperties.isMockAllowed(environment)) {
            throw new BusinessException(appMessages.get("app.error.push.mockDisabled"));
        }
        if (body == null || body.getLetterId() == null) {
            throw new BusinessException(appMessages.get("app.error.push.invalidRequest"));
        }
        long recipient = body.getRecipientUserId() != null ? body.getRecipientUserId() : currentUserId;
        long outboxId = notificationEnqueueService.enqueueLetterEvent(
                body.getEventType(), body.getLetterId(), recipient);

        PushMockEnqueueVO vo = new PushMockEnqueueVO();
        vo.setOutboxId(outboxId);
        vo.setEventType(body.getEventType());
        vo.setLetterId(body.getLetterId());
        vo.setRecipientUserId(recipient);

        boolean trigger = body.getTriggerJob() == null || Boolean.TRUE.equals(body.getTriggerJob());
        vo.setJobTriggered(trigger);
        if (!trigger) {
            log.info("push mock-enqueue done (no job), outboxId={}, eventType={}, letterId={}",
                    outboxId, body.getEventType(), body.getLetterId());
            return vo;
        }

        NotificationOutboxDispatchService.DispatchSummary summary = notificationOutboxJob.run();
        vo.setJobClaimed(summary.claimed());
        vo.setJobSent(summary.sent());
        vo.setJobFailed(summary.failed());
        vo.setJobDeliveries(summary.deliveries());

        List<NotificationDeliveryDomain> rows = notificationDeliveryService.listByOutboxId(outboxId);
        for (NotificationDeliveryDomain d : rows) {
            PushMockEnqueueVO.DeliveryItem item = new PushMockEnqueueVO.DeliveryItem();
            item.setDeliveryId(d.getId());
            item.setEndpointId(d.getEndpointId());
            item.setSendStatus(d.getSendStatus());
            item.setProvider(d.getProvider());
            item.setFcmMessageId(d.getFcmMessageId());
            vo.getDeliveries().add(item);
        }
        log.info("push mock-enqueue+job done, outboxId={}, claimed={}, deliveries={}",
                outboxId, summary.claimed(), vo.getDeliveries().size());
        return vo;
    }
}
