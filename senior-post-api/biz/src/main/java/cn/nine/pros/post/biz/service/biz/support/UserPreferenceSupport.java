package cn.nine.pros.post.biz.service.biz.support;

import cn.nine.pros.post.biz.model.domain.UserPreferenceDomain;
import cn.nine.pros.post.biz.service.base.UserPreferenceService;
import cn.nine.pros.post.client.model.json.UserPrivacyPrefs;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

/**
 * 读取用户隐私偏好开关。
 */
@Component
@RequiredArgsConstructor
public class UserPreferenceSupport {

    private final UserPreferenceService userPreferenceService;

    public boolean hideRecommendations(long userId) {
        UserPrivacyPrefs privacy = privacyOf(userId);
        return privacy != null && privacy.hideRecommendationsOrFalse();
    }

    public boolean rejectStrangerLetters(long userId) {
        UserPrivacyPrefs privacy = privacyOf(userId);
        return privacy != null && privacy.rejectStrangerLettersOrFalse();
    }

    private UserPrivacyPrefs privacyOf(long userId) {
        UserPreferenceDomain row = userPreferenceService.findOrCreateForUser(userId);
        return row != null ? row.getPrivacyJson() : null;
    }
}
