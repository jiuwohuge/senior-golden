package cn.nine.pros.post.biz.service.biz.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.base.UserDeviceService;
import cn.nine.pros.post.biz.service.biz.AppDeviceBizService;
import cn.nine.pros.post.client.model.input.app.DevicePushTokenInDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Slf4j
@Service
@RequiredArgsConstructor
public class AppDeviceBizServiceImpl implements AppDeviceBizService {

    private final UserDeviceService userDeviceService;
    private final AppMessages appMessages;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void registerPushToken(long userId, DevicePushTokenInDto body) {
        if (body == null || !StringUtils.hasText(body.getToken())) {
            throw new BusinessException(appMessages.get("app.error.device.tokenRequired"));
        }
        String platform = body.getPlatform() != null ? body.getPlatform().trim().toLowerCase() : "";
        if (!"ios".equals(platform) && !"android".equals(platform)) {
            throw new BusinessException(appMessages.get("app.error.device.platformInvalid"));
        }
        String deviceUuid = resolveDeviceUuid();
        boolean enabled = body.getEnabled() == null || Boolean.TRUE.equals(body.getEnabled());
        userDeviceService.upsertPushToken(userId, deviceUuid, platform, body.getToken().trim(), enabled);
        log.info("push token registered, userId={}, platform={}, enabled={}", userId, platform, enabled);
    }

    private String resolveDeviceUuid() {
        var ctx = MyRequestContextHolder.getContext();
        if (ctx != null && StringUtils.hasText(ctx.getEquipmentId())) {
            return ctx.getEquipmentId().trim();
        }
        throw new BadRequestException(appMessages.get("app.error.device.headerRequired"));
    }
}
