package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.UserDeviceMapper;
import cn.nine.pros.post.biz.model.domain.UserDeviceDomain;
import cn.nine.pros.post.biz.model.mapstruct.UserDeviceMapstruct;
import cn.nine.pros.post.biz.service.base.UserDeviceService;
import cn.nine.pros.post.client.model.db.UserDeviceDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 用户设备记录表（用于风控/拉黑/防刷） ServiceImpl
 *
 * @author Administrator
 */
@Service
public class UserDeviceServiceImpl extends ServiceImpl<UserDeviceMapper, UserDeviceDomain>
        implements UserDeviceService {

    @Autowired
    private UserDeviceMapstruct userDeviceMapstruct;

    @Override
    public void upsert(UserDeviceDTO userDeviceDTO) {
        Long id = userDeviceDTO.getId();
        if (id == null) {
            UserDeviceDomain domain = userDeviceMapstruct.toDomain(userDeviceDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        UserDeviceDomain domain = userDeviceMapstruct.toDomain(userDeviceDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public UserDeviceDTO findById(Long id) {
        return userDeviceMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Long> ids) {
        UserDeviceDomain userDeviceDomain = new UserDeviceDomain();
        userDeviceDomain.setDelFlag(true);
        userDeviceDomain.setUpdatedAt(LocalDateTime.now());
        update(userDeviceDomain, new LambdaQueryWrapper<UserDeviceDomain>()
                .in(UserDeviceDomain::getId, ids));
    }

    @Override
    public UserDeviceDomain findActiveByUserIdAndDeviceUuid(long userId, String deviceUuid) {
        return getOne(new LambdaQueryWrapper<UserDeviceDomain>()
                .eq(UserDeviceDomain::getUserId, userId)
                .eq(UserDeviceDomain::getDeviceUuid, deviceUuid)
                .eq(UserDeviceDomain::isDelFlag, false));
    }

    @Override
    public java.util.List<UserDeviceDomain> listActiveByUserId(long userId) {
        return list(new LambdaQueryWrapper<UserDeviceDomain>()
                .eq(UserDeviceDomain::getUserId, userId)
                .eq(UserDeviceDomain::isDelFlag, false)
                .orderByDesc(UserDeviceDomain::getUpdatedAt));
    }

    @Override
    public boolean blockByDeviceUuid(String deviceUuid, Long auditUserId) {
        if (deviceUuid == null || deviceUuid.isBlank()) {
            return false;
        }
        LocalDateTime now = LocalDateTime.now();
        return update(new com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper<UserDeviceDomain>()
                .eq(UserDeviceDomain::getDeviceUuid, deviceUuid.trim())
                .eq(UserDeviceDomain::isDelFlag, false)
                .set(UserDeviceDomain::getStatus, 2)
                .set(UserDeviceDomain::getUpdatedBy, auditUserId)
                .set(UserDeviceDomain::getUpdatedAt, now));
    }

    @Override
    public UserDeviceDomain upsertPushToken(Long userId, String deviceUuid, String platform, String token, boolean enabled) {
        if (userId == null || deviceUuid == null || deviceUuid.isBlank()) {
            return null;
        }
        LocalDateTime now = LocalDateTime.now();
        UserDeviceDomain existing = findActiveByUserIdAndDeviceUuid(userId, deviceUuid.trim());
        if (existing != null) {
            existing.setPushPlatform(platform != null ? platform.trim() : existing.getPushPlatform());
            existing.setPushToken(token != null ? token.trim() : existing.getPushToken());
            existing.setPushEnabled(enabled);
            existing.setUpdatedAt(now);
            existing.setUpdatedBy(userId);
            updateById(existing);
            return existing;
        }
        UserDeviceDomain row = new UserDeviceDomain();
        row.setUserId(userId);
        row.setDeviceUuid(deviceUuid.trim());
        row.setDeviceType(platform != null ? platform.trim() : null);
        row.setPushPlatform(platform != null ? platform.trim() : null);
        row.setPushToken(token != null ? token.trim() : null);
        row.setPushEnabled(enabled);
        row.setStatus(1);
        row.initAudit(userId);
        save(row);
        return row;
    }

}