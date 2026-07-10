package cn.nine.pros.post.biz.service.biz.support;

import cn.nine.pros.post.biz.model.domain.UserPreferenceDomain;
import cn.nine.pros.post.biz.service.base.UserPreferenceService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * 读取用户隐私/通知偏好 JSON 中的布尔开关。
 */
@Component
@RequiredArgsConstructor
public class UserPreferenceSupport {

    private final UserPreferenceService userPreferenceService;

    public boolean hideRecommendations(long userId) {
        return readPrivacyBool(userId, "hide_recommendations", false);
    }

    public boolean rejectStrangerLetters(long userId) {
        return readPrivacyBool(userId, "reject_stranger_letters", false);
    }

    private boolean readPrivacyBool(long userId, String key, boolean defaultValue) {
        UserPreferenceDomain row = userPreferenceService.findOrCreateForUser(userId);
        Map<String, Object> privacy = row.getPrivacyJson();
        if (privacy == null || !privacy.containsKey(key)) {
            return defaultValue;
        }
        Object raw = privacy.get(key);
        if (raw instanceof Boolean b) {
            return b;
        }
        if (raw instanceof Number n) {
            return n.intValue() != 0;
        }
        if (raw instanceof String s) {
            return "true".equalsIgnoreCase(s.trim()) || "1".equals(s.trim());
        }
        return defaultValue;
    }
}
