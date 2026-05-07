package cn.nine.pros.post.client.api.app;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.AppAuthProfilePatchInDto;
import cn.nine.pros.post.client.model.input.AppLoginInDto;
import cn.nine.pros.post.client.model.input.AppRegisterInDto;
import cn.nine.pros.post.client.model.out.AppAuthResultVO;
import cn.nine.pros.post.client.model.out.AppPublicUserVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@Tag(name = "App-认证")
public interface AppAuthApi {

    @Operation(summary = "注册")
    @PostMapping(AppServiceDefine.SERVER_PREFIX + "/auth/register")
    AppAuthResultVO register(@RequestBody @Valid AppRegisterInDto body);

    @Operation(summary = "登录")
    @PostMapping(AppServiceDefine.SERVER_PREFIX + "/auth/login")
    AppAuthResultVO login(@RequestBody @Valid AppLoginInDto body);

    @Operation(summary = "当前登录用户")
    @GetMapping(AppServiceDefine.SERVER_PREFIX + "/auth/me")
    AppPublicUserVO me();

    @Operation(summary = "更新当前用户资料（昵称/国家/简介）")
    @PatchMapping(AppServiceDefine.SERVER_PREFIX + "/auth/profile")
    AppPublicUserVO updateProfile(@RequestBody @Valid AppAuthProfilePatchInDto body);
}
