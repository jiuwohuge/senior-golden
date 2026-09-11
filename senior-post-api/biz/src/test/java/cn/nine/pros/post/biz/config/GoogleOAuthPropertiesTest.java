package cn.nine.pros.post.biz.config;

import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * {@link GoogleOAuthProperties#resolveAudiences()} 合并与去重。
 */
class GoogleOAuthPropertiesTest {

    @Test
    void resolveAudiencesMergesAndDedupesPreservingOrder() {
        GoogleOAuthProperties props = new GoogleOAuthProperties();
        props.setClientId(" web-id ");
        props.setAndroidClientId("android-id");
        props.setIosClientId("ios-id");
        props.setClientIds(List.of("web-id", "extra-id", "  ", "android-id"));

        List<String> audiences = props.resolveAudiences();

        assertEquals(List.of("web-id", "android-id", "ios-id", "extra-id"), audiences);
    }
}
