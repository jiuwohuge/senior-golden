package cn.nine.pros.post.client.api.app;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.app.DevicePushTokenInDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

@Tag(name = "App-设备")
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/device")
public interface AppDeviceApi {

    @Operation(summary = "注册/更新推送 Token")
    @PostMapping("/push-token")
    void registerPushToken(@RequestBody @Valid DevicePushTokenInDto body);
}
