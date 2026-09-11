package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.mapper.PushEndpointMapper;
import cn.nine.pros.post.biz.model.domain.PushEndpointDomain;
import cn.nine.pros.post.biz.service.base.PushEndpointService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;

/**
 * {@link PushEndpointService} 实现：Wrapper 仅在此层。
 */
@Slf4j
@Service
public class PushEndpointServiceImpl extends ServiceImpl<PushEndpointMapper, PushEndpointDomain>
        implements PushEndpointService {

    @Override
    public PushEndpointDomain upsertEndpoint(long userId, String deviceUuid, String platform,
                                             String pushToken, boolean enabled) {
        if (!StringUtils.hasText(deviceUuid) || !StringUtils.hasText(pushToken)) {
            return null;
        }
        String uuid = deviceUuid.trim();
        String token = pushToken.trim();
        LocalDateTime now = LocalDateTime.now();
        PushEndpointDomain existing = getOne(new LambdaQueryWrapper<PushEndpointDomain>()
                .eq(PushEndpointDomain::getUserId, userId)
                .eq(PushEndpointDomain::getDeviceUuid, uuid)
                .eq(PushEndpointDomain::isDelFlag, false)
                .last("LIMIT 1"), false);
        if (existing != null) {
            existing.setPlatform(platform != null ? platform.trim() : existing.getPlatform());
            existing.setPushToken(token);
            existing.setEnabled(enabled);
            existing.setInvalidatedAt(null);
            existing.setInvalidReason(null);
            existing.setLastSeenAt(now);
            existing.setNotificationPermission(enabled ? "granted" : "denied");
            existing.updateAudit(userId);
            updateById(existing);
            log.info("push endpoint updated, userId={}, endpointId={}, enabled={}",
                    userId, existing.getId(), enabled);
            return existing;
        }
        PushEndpointDomain row = new PushEndpointDomain();
        row.setUserId(userId);
        row.setDeviceUuid(uuid);
        row.setPlatform(platform != null ? platform.trim() : null);
        row.setPushToken(token);
        row.setEnabled(enabled);
        row.setNotificationPermission(enabled ? "granted" : "unknown");
        row.setLastSeenAt(now);
        row.initAudit(userId);
        save(row);
        log.info("push endpoint created, userId={}, endpointId={}, enabled={}",
                userId, row.getId(), enabled);
        return row;
    }

    @Override
    public List<PushEndpointDomain> listActiveEnabledByUserId(long userId) {
        List<PushEndpointDomain> list = list(new LambdaQueryWrapper<PushEndpointDomain>()
                .eq(PushEndpointDomain::getUserId, userId)
                .eq(PushEndpointDomain::getEnabled, true)
                .isNull(PushEndpointDomain::getInvalidatedAt)
                .eq(PushEndpointDomain::isDelFlag, false)
                .orderByDesc(PushEndpointDomain::getUpdatedAt));
        return list != null ? list : Collections.emptyList();
    }

    @Override
    public boolean unbindByUserAndDevice(long userId, String deviceUuid) {
        if (!StringUtils.hasText(deviceUuid)) {
            return false;
        }
        LocalDateTime now = LocalDateTime.now();
        boolean ok = update(new LambdaUpdateWrapper<PushEndpointDomain>()
                .eq(PushEndpointDomain::getUserId, userId)
                .eq(PushEndpointDomain::getDeviceUuid, deviceUuid.trim())
                .eq(PushEndpointDomain::isDelFlag, false)
                .set(PushEndpointDomain::getEnabled, false)
                .set(PushEndpointDomain::getPushToken, "")
                .set(PushEndpointDomain::getInvalidatedAt, now)
                .set(PushEndpointDomain::getInvalidReason, "logout")
                .set(PushEndpointDomain::getUpdatedBy, userId)
                .set(PushEndpointDomain::getUpdatedAt, now));
        if (ok) {
            log.info("push endpoint unbound on logout, userId={}", userId);
        }
        return ok;
    }

    @Override
    public boolean markInvalidated(long endpointId, String reason) {
        LocalDateTime now = LocalDateTime.now();
        String msg = reason != null && reason.length() > 256 ? reason.substring(0, 256) : reason;
        return update(new LambdaUpdateWrapper<PushEndpointDomain>()
                .eq(PushEndpointDomain::getId, endpointId)
                .eq(PushEndpointDomain::isDelFlag, false)
                .set(PushEndpointDomain::getEnabled, false)
                .set(PushEndpointDomain::getInvalidatedAt, now)
                .set(PushEndpointDomain::getInvalidReason, msg)
                .set(PushEndpointDomain::getUpdatedAt, now));
    }
}
