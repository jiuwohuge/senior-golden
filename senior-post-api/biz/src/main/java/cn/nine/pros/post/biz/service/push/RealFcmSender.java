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
        // 凭证未接：记 skipped 且 success=true，避免 Outbox 无限重试；勿在 prod 误走 Mock
        log.warn("RealFcmSender not configured; marking skipped");
        return new FcmSendResult(true, "skipped", null, "fcm_not_configured", false);
    }

    @Override
    public String provider() {
        return "fcm";
    }
}
