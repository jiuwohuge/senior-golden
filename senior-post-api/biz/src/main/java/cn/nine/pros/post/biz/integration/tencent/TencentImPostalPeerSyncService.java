package cn.nine.pros.post.biz.integration.tencent;

import cn.nine.pros.post.biz.config.TencentImProperties;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * 腾讯 IM 与邮政好友对齐，仅两条业务规则：
 * <ol>
 *   <li>建联成功：为 A、B 执行 {@code account_import}，再双向 {@code friend_add}</li>
 *   <li>补偿：若 B 从未 TIM 登录（客户端 tinyid / invalid receiver），再次对双方 import + friend_add（幂等）</li>
 * </ol>
 * UserSig 签发不需要 REST；本服务依赖 {@code TENCENT_IM_REST_IDENTIFIER} 与正确的 {@code TENCENT_IM_REST_HOST}。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class TencentImPostalPeerSyncService {

    private final TencentImProperties tencentImProperties;
    private final TencentImRestApiClient restApiClient;

    /**
     * 场景 1 + 2：注册双方 + IM 好友。失败只记日志，不抛异常（由调用方决定是否阻断 UI）。
     */
    public void syncPair(long userIdA, long userIdB) {
        if (userIdA <= 0 || userIdB <= 0 || userIdA == userIdB) {
            return;
        }
        if (!tencentImProperties.isFriendshipSyncEnabled()) {
            return;
        }
        if (!restApiClient.isRestConfigured()) {
            log.warn(
                    "TIM sync skipped: set TENCENT_IM_REST_IDENTIFIER; REST host should be adminapisgp.im.qcloud.com (Singapore)");
            return;
        }

        String a = String.valueOf(userIdA);
        String b = String.valueOf(userIdB);

        boolean importA = restApiClient.accountImport(a);
        boolean importB = restApiClient.accountImport(b);
        boolean ab = restApiClient.friendAdd(a, b);
        boolean ba = restApiClient.friendAdd(b, a);

        if (importA && importB && ab && ba) {
            log.info("TIM sync OK userA={} userB={}", userIdA, userIdB);
        } else {
            log.warn(
                    "TIM sync partial userA={} userB={} importA={} importB={} friendAB={} friendBA={}",
                    userIdA,
                    userIdB,
                    importA,
                    importB,
                    ab,
                    ba);
        }
    }
}
