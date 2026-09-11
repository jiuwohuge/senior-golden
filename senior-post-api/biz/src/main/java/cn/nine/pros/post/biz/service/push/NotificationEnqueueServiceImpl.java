package cn.nine.pros.post.biz.service.push;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.NotificationOutboxDomain;
import cn.nine.pros.post.biz.service.base.NotificationOutboxService;
import com.alibaba.fastjson2.JSONObject;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 信件推送入队：校验白名单、拒绝支付类、dedupe 幂等。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationEnqueueServiceImpl implements NotificationEnqueueService {

    private final NotificationOutboxService notificationOutboxService;
    private final AppMessages appMessages;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public long enqueueLetterEvent(String eventType, long letterId, long recipientUserId) {
        if (!StringUtils.hasText(eventType)) {
            throw new BusinessException(appMessages.get("app.error.push.eventTypeInvalid"));
        }
        String type = eventType.trim();
        if (NotificationEventTypes.isPaymentLike(type)) {
            log.warn("push enqueue refused payment-like eventType={}, letterId={}, recipient={}",
                    type, letterId, recipientUserId);
            throw new BusinessException(appMessages.get("app.error.push.paymentForbidden"));
        }
        if (!NotificationEventTypes.isAllowedLetterType(type)) {
            log.warn("push enqueue refused unknown eventType={}, letterId={}, recipient={}",
                    type, letterId, recipientUserId);
            throw new BusinessException(appMessages.get("app.error.push.eventTypeInvalid"));
        }

        String dedupeKey = NotificationEventTypes.dedupeKey(type, letterId, recipientUserId);
        NotificationOutboxDomain existing = notificationOutboxService.findByDedupeKey(dedupeKey);
        if (existing != null && existing.getId() != null) {
            log.info("push enqueue dedupe hit, outboxId={}, eventType={}, letterId={}, recipient={}",
                    existing.getId(), type, letterId, recipientUserId);
            return existing.getId();
        }

        String title;
        String body;
        String screen;
        String templateKey;
        if (NotificationEventTypes.LETTER_MATCHED_IN_TRANSIT.equals(type)) {
            title = NotificationEventTypes.TITLE_IN_TRANSIT;
            body = NotificationEventTypes.BODY_IN_TRANSIT;
            screen = NotificationEventTypes.SCREEN_IN_TRANSIT;
            templateKey = "letter_matched_in_transit";
        } else {
            title = NotificationEventTypes.TITLE_ARRIVED;
            body = NotificationEventTypes.BODY_ARRIVED;
            screen = NotificationEventTypes.SCREEN_ARRIVED;
            templateKey = "letter_arrived";
        }

        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("eventType", type);
        payload.put("letterId", letterId);
        payload.put("route", "app://letter/" + letterId);
        payload.put("screen", screen);

        LocalDateTime now = LocalDateTime.now();
        NotificationOutboxDomain row = new NotificationOutboxDomain();
        row.setEventType(type);
        row.setRecipientUserId(recipientUserId);
        row.setTemplateKey(templateKey);
        row.setTitle(title);
        row.setBody(body);
        row.setPayloadJson(JSONObject.from(payload));
        row.setDedupeKey(dedupeKey);
        row.setStatus("pending");
        row.setAttempts(0);
        row.setNextRetryAt(now);
        row.setScheduledAt(now);
        row.initAudit(recipientUserId);

        try {
            notificationOutboxService.insertPending(row);
        } catch (DataIntegrityViolationException e) {
            // 并发下唯一索引冲突 → 返回已有行，不抛错
            NotificationOutboxDomain raced = notificationOutboxService.findByDedupeKey(dedupeKey);
            if (raced != null && raced.getId() != null) {
                log.info("push enqueue race dedupe, outboxId={}, eventType={}, letterId={}",
                        raced.getId(), type, letterId);
                return raced.getId();
            }
            throw e;
        }

        log.info("push enqueued, outboxId={}, eventType={}, letterId={}, recipient={}",
                row.getId(), type, letterId, recipientUserId);
        return row.getId();
    }
}
