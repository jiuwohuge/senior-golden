package cn.nine.pros.post.biz.controller.app;

import cn.nine.pros.post.biz.service.app.AppAuthService;
import cn.nine.pros.post.client.api.app.AppAuthApi;
import cn.nine.pros.post.client.model.input.AppAuthProfilePatchInDto;
import cn.nine.pros.post.client.model.input.AppForgotPasswordInDto;
import cn.nine.pros.post.client.model.input.AppGoogleCompleteInDto;
import cn.nine.pros.post.client.model.input.AppGoogleLoginInDto;
import cn.nine.pros.post.client.model.input.AppLoginInDto;
import cn.nine.pros.post.client.model.input.AppRegisterInDto;
import cn.nine.pros.post.client.model.input.AppResetPasswordInDto;
import cn.nine.pros.post.client.model.out.AppAuthResultVO;
import cn.nine.pros.post.client.model.out.AppPublicUserVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequiredArgsConstructor
public class AppAuthController implements AppAuthApi {

    private final AppAuthService appAuthService;

    @Override
    public AppAuthResultVO register(AppRegisterInDto body) {
        return appAuthService.register(body);
    }

    @Override
    public AppAuthResultVO login(AppLoginInDto body) {
        return appAuthService.login(body);
    }

    @Override
    public AppAuthResultVO loginWithGoogle(AppGoogleLoginInDto body) {
        return appAuthService.loginWithGoogle(body);
    }

    @Override
    public AppAuthResultVO completeGoogleProfile(AppGoogleCompleteInDto body) {
        return appAuthService.completeGoogleProfile(body);
    }

    @Override
    public void forgotPassword(AppForgotPasswordInDto body) {
        appAuthService.forgotPassword(body);
    }

    @Override
    public void resetPassword(AppResetPasswordInDto body) {
        appAuthService.resetPassword(body);
    }

    @Override
    public AppPublicUserVO me() {
        return appAuthService.me();
    }

    @Override
    public AppPublicUserVO updateProfile(AppAuthProfilePatchInDto body) {
        return appAuthService.updateProfile(body);
    }

    @Override
    public void requestAccountDeletion() {
        appAuthService.requestAccountDeletion();
    }
}
