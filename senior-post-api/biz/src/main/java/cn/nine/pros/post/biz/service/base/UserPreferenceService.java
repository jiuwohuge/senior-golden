package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.UserPreferenceDomain;
import com.baomidou.mybatisplus.extension.service.IService;

public interface UserPreferenceService extends IService<UserPreferenceDomain> {

    UserPreferenceDomain findOrCreateForUser(Long userId);

    UserPreferenceDomain updatePrivacy(Long userId, String privacyJson);

    UserPreferenceDomain updateNotifications(Long userId, String notificationsJson);

    UserPreferenceDomain mergePrivacy(Long userId, java.util.Map<String, Object> patch);

    UserPreferenceDomain mergeNotifications(Long userId, java.util.Map<String, Object> patch);
}
