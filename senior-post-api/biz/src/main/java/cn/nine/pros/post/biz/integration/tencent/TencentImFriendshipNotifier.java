package cn.nine.pros.post.biz.integration.tencent;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

/**
 * 腾讯 IM 服务端 REST（account_import / friend_add 等）占位：生产环境在此接入控制台密钥与 admin 账号。
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class TencentImFriendshipNotifier {

    public void afterFriendshipActive(long userLow, long userHigh) {
        log.info("Tencent IM friendship sync placeholder: userLow={} userHigh={} — configure REST admin + enable calls when ready.",
                userLow, userHigh);
    }
}
