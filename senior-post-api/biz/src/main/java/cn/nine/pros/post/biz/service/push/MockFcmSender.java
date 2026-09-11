package cn.nine.pros.post.biz.service.push;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.UUID;

/**
 * 非 prod Mock FCM：不调 Google，仅记录投递成功。
 * <p>仅在 {@code PushProperties.isMockAllowed} 为 true 时由派发层选用（prod 永不走 mock）。
 */
@Slf4j
@Component
public class MockFcmSender implements FcmSender {

    @Override
    public FcmSendResult send(String token, String title, String body, String dataJson) {
        String messageId = "mock-" + UUID.randomUUID();
        log.info("MockFcmSender sent, messageId={}, titleLen={}, bodyLen={}, dataLen={}",
                messageId,
                title != null ? title.length() : 0,
                body != null ? body.length() : 0,
                dataJson != null ? dataJson.length() : 0);
        return FcmSendResult.ok("mock_sent", messageId);
    }

    @Override
    public String provider() {
        return "mock";
    }
}
