package cn.nine.pros.post.biz.service.push;

import cn.nine.pros.post.biz.config.PushProperties;
import cn.nine.pros.post.biz.model.domain.NotificationDeliveryDomain;
import cn.nine.pros.post.biz.model.domain.NotificationOutboxDomain;
import cn.nine.pros.post.biz.model.domain.PushEndpointDomain;
import cn.nine.pros.post.biz.model.domain.UserDeviceDomain;
import cn.nine.pros.post.biz.service.base.NotificationDeliveryService;
import cn.nine.pros.post.biz.service.base.NotificationOutboxService;
import cn.nine.pros.post.biz.service.base.PushEndpointService;
import cn.nine.pros.post.biz.service.base.UserDeviceService;
import com.alibaba.fastjson2.JSON;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Outbox 派发：认领 → 解析端点 → FcmSender → 写 delivery → 更新 outbox。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationOutboxDispatchService {

    private static final int MAX_ATTEMPTS = 5;

    private final NotificationOutboxService notificationOutboxService;
    private final NotificationDeliveryService notificationDeliveryService;
    private final PushEndpointService pushEndpointService;
    private final UserDeviceService userDeviceService;
    private final MockFcmSender mockFcmSender;
    private final RealFcmSender realFcmSender;
    private final PushProperties pushProperties;
    private final Environment environment;

    /**
     * 处理一批 pending；返回本批汇总。
     */
    @Transactional(rollbackFor = Exception.class)
    public DispatchSummary processBatch(int batchSize) {
        List<NotificationOutboxDomain> claimed = notificationOutboxService.claimPendingBatch(batchSize);
        int sent = 0;
        int failed = 0;
        int deliveries = 0;
        for (NotificationOutboxDomain row : claimed) {
            try {
                int n = processOne(row);
                deliveries += n;
                sent++;
            } catch (RuntimeException e) {
                failed++;
                log.warn("notification outbox process failed, outboxId={}", row.getId(), e);
                String msg = e.getMessage() != null ? e.getMessage() : e.getClass().getSimpleName();
                int attempts = row.getAttempts() != null ? row.getAttempts() : 0;
                boolean terminal = attempts + 1 >= MAX_ATTEMPTS;
                notificationOutboxService.markFailed(row.getId(), msg, terminal);
            }
        }
        if (!claimed.isEmpty()) {
            log.info("notification outbox batch done, claimed={}, sent={}, failed={}, deliveries={}",
                    claimed.size(), sent, failed, deliveries);
        }
        return new DispatchSummary(claimed.size(), sent, failed, deliveries);
    }

    private int processOne(NotificationOutboxDomain row) {
        Long userId = row.getRecipientUserId();
        if (userId == null) {
            notificationOutboxService.markFailed(row.getId(), "missing_recipient", true);
            return 0;
        }
        List<EndpointTarget> targets = resolveTargets(userId);
        if (targets.isEmpty()) {
            // 无端点：记一条 skipped delivery，outbox 仍标 sent（避免无限重试）
            writeSkippedNoEndpoint(row, userId);
            notificationOutboxService.markSent(row.getId());
            log.info("notification outbox no endpoint, outboxId={}, userId={}", row.getId(), userId);
            return 1;
        }

        FcmSender sender = resolveSender();
        String dataJson = payloadToJson(row.getPayloadJson());
        int count = 0;
        boolean anySuccess = false;
        String lastError = null;
        for (EndpointTarget target : targets) {
            FcmSender.FcmSendResult result = sender.send(
                    target.token(), row.getTitle(), row.getBody(), dataJson);
            writeDelivery(row, userId, target.endpointId(), sender.provider(), result);
            count++;
            if (result.success()) {
                anySuccess = true;
            } else {
                lastError = result.errorMessage();
            }
            if (result.invalidToken() && target.endpointId() != null) {
                pushEndpointService.markInvalidated(target.endpointId(), result.errorMessage());
            }
        }
        if (anySuccess) {
            notificationOutboxService.markSent(row.getId());
            return count;
        }
        int attempts = row.getAttempts() != null ? row.getAttempts() : 0;
        boolean terminal = attempts + 1 >= MAX_ATTEMPTS;
        notificationOutboxService.markFailed(row.getId(),
                lastError != null ? lastError : "all_endpoints_failed", terminal);
        return count;
    }

    private FcmSender resolveSender() {
        // mock 仅在 isMockAllowed（非 prod + flag）；否则走 Real（未配凭证时 stub skipped）
        if (pushProperties.isMockAllowed(environment)) {
            return mockFcmSender;
        }
        return realFcmSender;
    }

    private List<EndpointTarget> resolveTargets(long userId) {
        List<PushEndpointDomain> endpoints = pushEndpointService.listActiveEnabledByUserId(userId);
        List<EndpointTarget> targets = new ArrayList<>();
        if (endpoints != null) {
            for (PushEndpointDomain ep : endpoints) {
                if (ep == null || !StringUtils.hasText(ep.getPushToken())) {
                    continue;
                }
                targets.add(new EndpointTarget(ep.getId(), ep.getPushToken()));
            }
        }
        if (!targets.isEmpty()) {
            return targets;
        }
        // 回退 bu_user_device
        List<UserDeviceDomain> devices = userDeviceService.listActiveByUserId(userId);
        if (devices == null) {
            return targets;
        }
        for (UserDeviceDomain d : devices) {
            if (d == null || !Boolean.TRUE.equals(d.getPushEnabled())) {
                continue;
            }
            if (!StringUtils.hasText(d.getPushToken())) {
                continue;
            }
            targets.add(new EndpointTarget(null, d.getPushToken()));
        }
        return targets;
    }

    private void writeSkippedNoEndpoint(NotificationOutboxDomain row, long userId) {
        NotificationDeliveryDomain delivery = new NotificationDeliveryDomain();
        delivery.setOutboxId(row.getId());
        delivery.setEndpointId(null);
        delivery.setUserId(userId);
        delivery.setSendStatus("skipped");
        delivery.setErrorMessage("no_active_endpoint");
        delivery.setProvider(resolveSender().provider());
        delivery.setSentAt(LocalDateTime.now());
        delivery.initAudit(userId);
        notificationDeliveryService.insertDelivery(delivery);
    }

    private void writeDelivery(NotificationOutboxDomain row, long userId, Long endpointId,
                               String provider, FcmSender.FcmSendResult result) {
        NotificationDeliveryDomain delivery = new NotificationDeliveryDomain();
        delivery.setOutboxId(row.getId());
        delivery.setEndpointId(endpointId);
        delivery.setUserId(userId);
        delivery.setFcmMessageId(result.messageId());
        delivery.setSendStatus(result.sendStatus());
        delivery.setErrorMessage(result.errorMessage());
        delivery.setProvider(provider);
        delivery.setSentAt(LocalDateTime.now());
        delivery.initAudit(userId);
        notificationDeliveryService.insertDelivery(delivery);
    }

    private static String payloadToJson(Object payloadJson) {
        if (payloadJson == null) {
            return "{}";
        }
        if (payloadJson instanceof String s) {
            return s;
        }
        return JSON.toJSONString(payloadJson);
    }

    public record DispatchSummary(int claimed, int sent, int failed, int deliveries) {
    }

    private record EndpointTarget(Long endpointId, String token) {
    }
}
