package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.client.model.input.app.DevicePushTokenInDto;

public interface AppDeviceBizService {

    void registerPushToken(long userId, DevicePushTokenInDto body);
}
