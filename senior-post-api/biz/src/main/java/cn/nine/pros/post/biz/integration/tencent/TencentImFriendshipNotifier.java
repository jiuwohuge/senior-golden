package cn.nine.pros.post.biz.integration.tencent;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

/**
 * 业务邮政好友激活/失效时，委托 {@link TencentImPostalPeerSyncService} 同步腾讯 IM。
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class TencentImFriendshipNotifier {

    private final TencentImPostalPeerSyncService postalPeerSyncService;
    private final TencentImRestApiClient restApiClient;
    private final cn.nine.pros.post.biz.config.TencentImProperties tencentImProperties;

    public void afterFriendshipActive(long userLow, long userHigh) {
        postalPeerSyncService.syncPair(userLow, userHigh);
    }

    public void afterFriendshipRemoved(long userLow, long userHigh) {
        if (!tencentImProperties.isFriendshipSyncEnabled()) {
            log.debug("Tencent IM friendship sync disabled (skip friend_delete)");
            return;
        }
        if (tencentImProperties.getSdkAppId() <= 0
                || !org.springframework.util.StringUtils.hasText(tencentImProperties.getSecretKey())) {
            log.debug("Tencent IM friend_delete skipped: IM not configured");
            return;
        }
        if (!restApiClient.isRestConfigured()) {
            log.warn("Tencent IM friend_delete skipped: REST admin not configured");
            return;
        }
        String a = String.valueOf(userLow);
        String b = String.valueOf(userHigh);
        boolean ok = restApiClient.friendDeleteBoth(a, b);
        if (!ok) {
            log.warn("Tencent IM friend_delete incomplete userLow={} userHigh={}", userLow, userHigh);
        } else {
            log.info("Tencent IM friendship removed userLow={} userHigh={}", userLow, userHigh);
        }
    }
}
