package cn.nine.pros.post.biz.service.biz;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.config.TencentImProperties;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.integration.tencent.TencentImPostalPeerSyncService;
import cn.nine.pros.post.biz.service.base.FriendshipService;
import cn.nine.pros.post.client.model.out.AppImUserSigVO;
import com.tencentyun.TLSSigAPIv2;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

/**
 * 腾讯 IM：UserSig 签发 + 打开聊天前的 IM 补偿同步（对端 account_import）。
 */
@Service
@RequiredArgsConstructor
public class AppImService {

    private final TencentImProperties tencentImProperties;
    private final FriendshipService friendshipService;
    private final TencentImPostalPeerSyncService postalPeerSyncService;
    private final AppMessages appMessages;

    public AppImUserSigVO currentUserSig() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.im.needLogin"));
        }
        if (friendshipService.listActiveFriendshipsForUser(uid).isEmpty()) {
            throw new BadRequestException(appMessages.get("app.error.im.noPostalFriends"));
        }
        if (tencentImProperties.getSdkAppId() <= 0
                || tencentImProperties.getSecretKey() == null
                || tencentImProperties.getSecretKey().isBlank()) {
            throw new BadRequestException(appMessages.get("app.error.im.tencentNotConfigured"));
        }
        int sdk = (int) Math.min(Integer.MAX_VALUE, Math.max(0, tencentImProperties.getSdkAppId()));
        TLSSigAPIv2 api = new TLSSigAPIv2(sdk, tencentImProperties.getSecretKey().trim());
        String userId = String.valueOf(uid);
        int expire = Math.max(300, tencentImProperties.getUserSigExpireSeconds());
        String sig = api.genUserSig(userId, expire);
        return AppImUserSigVO.builder()
                .sdkAppId(tencentImProperties.getSdkAppId())
                .userId(userId)
                .userSig(sig)
                .expireInSeconds(expire)
                .build();
    }

    /**
     * 业务已是邮政好友，但 IM 可能未导入对端：补偿 account_import + friend_add（幂等，不抛导入失败）。
     */
    public void compensateChatPeer(Long peerUserId) {
        Long viewerId = MyRequestContextHolder.userId();
        if (viewerId == null) {
            throw new BadRequestException(appMessages.get("app.error.im.needLogin"));
        }
        if (peerUserId == null || peerUserId <= 0) {
            throw new BadRequestException(appMessages.get("app.error.im.invalidPeer"));
        }
        if (!friendshipService.areActiveFriends(viewerId, peerUserId)) {
            throw new BadRequestException(appMessages.get("app.error.im.notFriends"));
        }
        postalPeerSyncService.syncPair(viewerId, peerUserId);
    }
}
