package cn.nine.pros.post.biz.integration.tencent;

import cn.nine.pros.post.biz.config.TencentImProperties;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

/**
 * 业务建联成功后同步腾讯 IM 双向好友（REST account_import + sns/friend_add）（FP-A5d-004）。
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class TencentImFriendshipNotifier {

    private final TencentImProperties tencentImProperties;
    private final TencentImRestApiClient restApiClient;

    public void afterFriendshipActive(long userLow, long userHigh) {
        if (!tencentImProperties.isFriendshipSyncEnabled()) {
            log.debug("Tencent IM friendship sync disabled");
            return;
        }
        if (tencentImProperties.getSdkAppId() <= 0 || !StringUtils.hasText(tencentImProperties.getSecretKey())) {
            log.debug("Tencent IM friendship sync skipped: IM not configured");
            return;
        }
        if (!StringUtils.hasText(tencentImProperties.getRestApiIdentifier())) {
            log.warn("Tencent IM friendship sync skipped: set senior-post.tencent-im.rest-api-identifier (App admin)");
            return;
        }

        String a = String.valueOf(userLow);
        String b = String.valueOf(userHigh);

        if (tencentImProperties.isAccountImportBeforeFriendAdd()) {
            restApiClient.accountImport(a);
            restApiClient.accountImport(b);
        }

        boolean ab = restApiClient.friendAdd(a, b);
        boolean ba = restApiClient.friendAdd(b, a);
        if (!ab || !ba) {
            log.warn("Tencent IM friendship sync incomplete userLow={} userHigh={} abOk={} baOk={}",
                    userLow, userHigh, ab, ba);
        } else {
            log.info("Tencent IM friendship synced userLow={} userHigh={}", userLow, userHigh);
        }
    }
}
