package cn.nine.pros.post.biz.service.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.config.TencentImProperties;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.base.FriendshipService;
import cn.nine.pros.post.client.model.out.AppImUserSigVO;
import com.tencentyun.TLSSigAPIv2;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AppImService {

    private final TencentImProperties tencentImProperties;
    private final FriendshipService friendshipService;
    private final AppMessages appMessages;

    public AppImUserSigVO currentUserSig() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.im.needLogin"));
        }
        // 无邮政好友（Connections）时不签发 UserSig，避免大量注册/未建联用户占用腾讯 IM 在线席位。
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
}
