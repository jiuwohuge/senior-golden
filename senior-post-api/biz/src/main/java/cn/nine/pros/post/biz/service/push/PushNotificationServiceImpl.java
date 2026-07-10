package cn.nine.pros.post.biz.service.push;

import cn.nine.pros.post.biz.model.domain.UserDeviceDomain;
import cn.nine.pros.post.biz.model.domain.UserPreferenceDomain;
import cn.nine.pros.post.biz.service.base.ConfigService;
import cn.nine.pros.post.biz.service.base.UserDeviceService;
import cn.nine.pros.post.biz.service.base.UserPreferenceService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class PushNotificationServiceImpl implements PushNotificationService {

    private static final String KEY_PUSH_ENABLED = "push.enabled";

    private static final String PREF_LETTER_DELIVERED = "letterDelivered";
    private static final String PREF_PENPAL_REQUEST = "penpalRequest";
    private static final String PREF_PENPAL_ACCEPTED = "penpalAccepted";
    private static final String PREF_TIME_LETTER = "timeLetterDelivered";
    private static final String PREF_AUDIT_REJECTED = "auditRejected";

    private final ConfigService configService;
    private final UserPreferenceService userPreferenceService;
    private final UserDeviceService userDeviceService;

    @Override
    @Async
    public void notifyLetterDelivered(long recipientUserId, long letterId) {
        dispatch(recipientUserId, PREF_LETTER_DELIVERED,
                "letter_delivered", "New letter arrived", Map.of("letterId", letterId));
    }

    @Override
    @Async
    public void notifyPenpalRequest(long targetUserId, long requesterUserId, long requestId) {
        dispatch(targetUserId, PREF_PENPAL_REQUEST,
                "penpal_request", "New pen pal request",
                Map.of("requestId", requestId, "requesterUserId", requesterUserId));
    }

    @Override
    @Async
    public void notifyPenpalAccepted(long requesterUserId, long accepterUserId) {
        dispatch(requesterUserId, PREF_PENPAL_ACCEPTED,
                "penpal_accepted", "Pen pal request accepted",
                Map.of("accepterUserId", accepterUserId));
    }

    @Override
    @Async
    public void notifyTimeLetterDelivered(long recipientUserId, long timeLetterId) {
        dispatch(recipientUserId, PREF_TIME_LETTER,
                "time_letter_delivered", "Time letter has arrived",
                Map.of("timeLetterId", timeLetterId));
    }

    @Override
    @Async
    public void notifyAuditRejected(long senderUserId, long letterId) {
        dispatch(senderUserId, PREF_AUDIT_REJECTED,
                "audit_rejected", "Letter was not approved",
                Map.of("letterId", letterId));
    }

    private void dispatch(long userId, String prefKey, String eventType, String title, Map<String, Object> payload) {
        if (!configService.getBoolean(KEY_PUSH_ENABLED, false)) {
            log.debug("push skipped (disabled), userId={}, event={}", userId, eventType);
            return;
        }
        if (!notificationAllowed(userId, prefKey)) {
            log.debug("push skipped (user pref), userId={}, event={}", userId, eventType);
            return;
        }
        List<UserDeviceDomain> devices = userDeviceService.listActiveByUserId(userId);
        boolean anyToken = false;
        for (UserDeviceDomain device : devices) {
            if (device == null || !Boolean.TRUE.equals(device.getPushEnabled())) {
                continue;
            }
            if (!StringUtils.hasText(device.getPushToken())) {
                continue;
            }
            anyToken = true;
            log.info("push dispatch (no-op transport), userId={}, platform={}, event={}, title={}, payload={}",
                    userId, device.getPushPlatform(), eventType, title, payload);
        }
        if (!anyToken) {
            log.debug("push skipped (no token), userId={}, event={}", userId, eventType);
        }
    }

    private boolean notificationAllowed(long userId, String prefKey) {
        UserPreferenceDomain pref = userPreferenceService.findOrCreateForUser(userId);
        if (pref == null || pref.getNotificationsJson() == null) {
            return true;
        }
        return pref.getNotificationsJson().isEventAllowed(prefKey);
    }
}
