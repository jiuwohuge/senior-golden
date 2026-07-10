package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.pros.post.biz.mapper.UserPreferenceMapper;
import cn.nine.pros.post.biz.model.domain.UserPreferenceDomain;
import cn.nine.pros.post.biz.service.base.UserPreferenceService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class UserPreferenceServiceImpl extends ServiceImpl<UserPreferenceMapper, UserPreferenceDomain>
        implements UserPreferenceService {

    private static final TypeReference<Map<String, Object>> MAP_TYPE = new TypeReference<>() {
    };

    private final ObjectMapper objectMapper;

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
        row.setPrivacyJson(new HashMap<>());
        row.setNotificationsJson(new HashMap<>());
        row.initAudit(userId);
        save(row);
        return row;
    }

    @Override
    public UserPreferenceDomain updatePrivacy(Long userId, String privacyJson) {
        UserPreferenceDomain row = findOrCreateForUser(userId);
        row.setPrivacyJson(parseJsonMap(privacyJson));
        row.updateAudit(userId);
        updateById(row);
        return row;
    }

    @Override
    public UserPreferenceDomain updateNotifications(Long userId, String notificationsJson) {
        UserPreferenceDomain row = findOrCreateForUser(userId);
        row.setNotificationsJson(parseJsonMap(notificationsJson));
        row.updateAudit(userId);
        updateById(row);
        return row;
    }

    @Override
    public UserPreferenceDomain mergePrivacy(Long userId, Map<String, Object> patch) {
        UserPreferenceDomain row = findOrCreateForUser(userId);
        Map<String, Object> merged = new HashMap<>();
        if (row.getPrivacyJson() != null) {
            merged.putAll(row.getPrivacyJson());
        }
        if (patch != null) {
            merged.putAll(patch);
        }
        row.setPrivacyJson(merged);
        row.updateAudit(userId);
        updateById(row);
        return row;
    }

    @Override
    public UserPreferenceDomain mergeNotifications(Long userId, Map<String, Object> patch) {
        UserPreferenceDomain row = findOrCreateForUser(userId);
        Map<String, Object> merged = new HashMap<>();
        if (row.getNotificationsJson() != null) {
            merged.putAll(row.getNotificationsJson());
        }
        if (patch != null) {
            merged.putAll(patch);
        }
        row.setNotificationsJson(merged);
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

    private Map<String, Object> parseJsonMap(String json) {
        if (!StringUtils.hasText(json)) {
            return new HashMap<>();
        }
        try {
            return objectMapper.readValue(json.trim(), MAP_TYPE);
        } catch (Exception e) {
            throw new BusinessException("Invalid preference JSON");
        }
    }
}
