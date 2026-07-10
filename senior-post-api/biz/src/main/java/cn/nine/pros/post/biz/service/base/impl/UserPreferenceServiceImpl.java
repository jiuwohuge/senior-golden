package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.mapper.UserPreferenceMapper;
import cn.nine.pros.post.biz.model.domain.UserPreferenceDomain;
import cn.nine.pros.post.biz.service.base.UserPreferenceService;
import cn.nine.pros.post.client.model.json.UserNotificationPrefs;
import cn.nine.pros.post.client.model.json.UserPrivacyPrefs;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;

@Service
public class UserPreferenceServiceImpl extends ServiceImpl<UserPreferenceMapper, UserPreferenceDomain>
        implements UserPreferenceService {

    @Override
    public UserPreferenceDomain findOrCreateForUser(Long userId) {
        if (userId == null) {
            return null;
        }
        UserPreferenceDomain existing = findActiveByUserId(userId);
        if (existing != null) {
            return existing;
        }
        UserPreferenceDomain row = new UserPreferenceDomain();
        row.setUserId(userId);
        row.setPrivacyJson(new UserPrivacyPrefs());
        row.setNotificationsJson(new UserNotificationPrefs());
        row.initAudit(userId);
        save(row);
        return row;
    }

    @Override
    public UserPreferenceDomain updatePrivacy(Long userId, UserPrivacyPrefs privacy) {
        UserPreferenceDomain row = findOrCreateForUser(userId);
        row.setPrivacyJson(privacy != null ? privacy : new UserPrivacyPrefs());
        row.updateAudit(userId);
        updateById(row);
        return row;
    }

    @Override
    public UserPreferenceDomain updateNotifications(Long userId, UserNotificationPrefs notifications) {
        UserPreferenceDomain row = findOrCreateForUser(userId);
        row.setNotificationsJson(notifications != null ? notifications : new UserNotificationPrefs());
        row.updateAudit(userId);
        updateById(row);
        return row;
    }

    @Override
    public UserPreferenceDomain mergePrivacy(Long userId, UserPrivacyPrefs patch) {
        UserPreferenceDomain row = findOrCreateForUser(userId);
        UserPrivacyPrefs current = row.getPrivacyJson() != null ? row.getPrivacyJson() : new UserPrivacyPrefs();
        current.mergeFrom(patch);
        row.setPrivacyJson(current);
        row.updateAudit(userId);
        updateById(row);
        return row;
    }

    @Override
    public UserPreferenceDomain mergeNotifications(Long userId, UserNotificationPrefs patch) {
        UserPreferenceDomain row = findOrCreateForUser(userId);
        UserNotificationPrefs current =
                row.getNotificationsJson() != null ? row.getNotificationsJson() : new UserNotificationPrefs();
        current.mergeFrom(patch);
        row.setNotificationsJson(current);
        row.updateAudit(userId);
        updateById(row);
        return row;
    }

    private UserPreferenceDomain findActiveByUserId(Long userId) {
        return getOne(new LambdaQueryWrapper<UserPreferenceDomain>()
                .eq(UserPreferenceDomain::getUserId, userId)
                .eq(UserPreferenceDomain::isDelFlag, false)
                .last("LIMIT 1"));
    }
}
