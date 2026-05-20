package cn.nine.pros.post.client.api.app;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.AppAuthProfilePatchInDto;
import cn.nine.pros.post.client.model.input.AppForgotPasswordInDto;
import cn.nine.pros.post.client.model.input.AppGoogleCompleteInDto;
import cn.nine.pros.post.client.model.input.AppGoogleLoginInDto;
import cn.nine.pros.post.client.model.input.AppLoginInDto;
import cn.nine.pros.post.client.model.input.AppRegisterInDto;
import cn.nine.pros.post.client.model.input.AppResetPasswordInDto;
import cn.nine.pros.post.client.model.out.AppAuthResultVO;
import cn.nine.pros.post.client.model.out.AppPublicUserVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@Tag(name = "App-认证")
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/auth")
public interface AppAuthApi {

    @Operation(summary = "注册")
    @PostMapping("/register")
    AppAuthResultVO register(@RequestBody @Valid AppRegisterInDto body);

    @Operation(summary = "登录")
    @PostMapping("/login")
    AppAuthResultVO login(@RequestBody @Valid AppLoginInDto body);

    @Operation(summary = "Google 登录（Android / Web idToken）")
    @PostMapping("/google")
    AppAuthResultVO loginWithGoogle(@RequestBody @Valid AppGoogleLoginInDto body);

    @Operation(summary = "Google 新用户资料补全")
    @PostMapping("/google/complete")
    AppAuthResultVO completeGoogleProfile(@RequestBody @Valid AppGoogleCompleteInDto body);

    @Operation(summary = "忘记密码：发送邮件验证码（防枚举：未注册邮箱也返回成功）")
    @PostMapping("/forgot-password")
    void forgotPassword(@RequestBody @Valid AppForgotPasswordInDto body);

    @Operation(summary = "重置密码（验证码一次性）")
    @PostMapping("/reset-password")
    void resetPassword(@RequestBody @Valid AppResetPasswordInDto body);

    @Operation(summary = "当前登录用户")
    @GetMapping("/me")
    AppPublicUserVO me();

    @Operation(summary = "更新当前用户资料（昵称/国家/简介）")
    @PatchMapping("/profile")
    AppPublicUserVO updateProfile(@RequestBody @Valid AppAuthProfilePatchInDto body);

    @Operation(summary = "提交账号注销申请（进入7日冷静期；期间再次登录将撤销申请）")
    @PostMapping("/account/deletion-request")
    void requestAccountDeletion();
}
