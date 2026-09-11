package cn.nine.pros.post.biz.service.push;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

/**
 * 真实 FCM 占位：未配置凭证时优雅 skipped/failed，不抛未捕获异常。
 */
@Slf4j
@Component
public class RealFcmSender implements FcmSender {

    @Override
    public FcmSendResult send(String token, String title, String body, String dataJson) {
        log.warn("RealFcmSender not configured; marking skipped");
        return FcmSendResult.skipped("fcm_not_configured");
    }

    @Override
    public String provider() {
        return "fcm";
    }
}
