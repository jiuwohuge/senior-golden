package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.UserPreferenceDomain;
import cn.nine.pros.post.client.model.json.UserNotificationPrefs;
import cn.nine.pros.post.client.model.json.UserPrivacyPrefs;
import com.baomidou.mybatisplus.extension.service.IService;

public interface UserPreferenceService extends IService<UserPreferenceDomain> {

    UserPreferenceDomain findOrCreateForUser(Long userId);

    UserPreferenceDomain updatePrivacy(Long userId, UserPrivacyPrefs privacy);

    UserPreferenceDomain updateNotifications(Long userId, UserNotificationPrefs notifications);

    UserPreferenceDomain mergePrivacy(Long userId, UserPrivacyPrefs patch);

    UserPreferenceDomain mergeNotifications(Long userId, UserNotificationPrefs patch);
}
