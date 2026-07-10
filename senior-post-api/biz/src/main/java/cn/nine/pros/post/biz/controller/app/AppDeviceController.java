package cn.nine.pros.post.biz.controller.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.biz.AppDeviceBizService;
import cn.nine.pros.post.client.api.app.AppDeviceApi;
import cn.nine.pros.post.client.model.input.app.DevicePushTokenInDto;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AppDeviceController implements AppDeviceApi {

    private final AppDeviceBizService appDeviceBizService;
    private final AppMessages appMessages;

    @Override
    public void registerPushToken(DevicePushTokenInDto body) {
        appDeviceBizService.registerPushToken(requireUserId(), body);
    }

    private Long requireUserId() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.notLoggedIn"));
        }
        return uid;
    }
}
