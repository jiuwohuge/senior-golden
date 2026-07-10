package cn.nine.pros.post.biz.controller.app;

import cn.nine.pros.post.biz.service.biz.AppAuthService;
import cn.nine.pros.post.biz.service.biz.EmailVerifyService;
import cn.nine.pros.post.client.api.app.AppAuthApi;
import cn.nine.pros.post.client.model.input.AppAuthProfilePatchInDto;
import cn.nine.pros.post.client.model.input.AppEmailVerifyConfirmInDto;
import cn.nine.pros.post.client.model.input.AppForgotPasswordInDto;
import cn.nine.pros.post.client.model.input.AppGoogleCompleteInDto;
import cn.nine.pros.post.client.model.input.AppGoogleLoginInDto;
import cn.nine.pros.post.client.model.input.AppLoginChallengeConfirmInDto;
import cn.nine.pros.post.client.model.input.AppLoginChallengeSendInDto;
import cn.nine.pros.post.client.model.input.AppLoginInDto;
import cn.nine.pros.post.client.model.input.AppRegisterInDto;
import cn.nine.pros.post.client.model.input.AppResetPasswordInDto;
import cn.nine.pros.post.client.model.out.AppAuthResultVO;
import cn.nine.pros.post.client.model.out.AppPublicUserVO;
import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequiredArgsConstructor
public class AppAuthController implements AppAuthApi {

    private final AppAuthService appAuthService;
    private final EmailVerifyService emailVerifyService;
    private final AppMessages appMessages;

    @Override
    public AppAuthResultVO register(AppRegisterInDto body) {
        return appAuthService.register(body);
    }

    @Override
    public AppAuthResultVO login(AppLoginInDto body) {
        return appAuthService.login(body);
    }

    @Override
    public void validateRegisterEmail(String email) {
        appAuthService.validateRegisterEmail(email);
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

    @Override
    public void sendEmailVerifyCode() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.session.invalid"));
        }
        emailVerifyService.sendEmailVerifyCode(uid);
    }

    @Override
    public void confirmEmailVerify(AppEmailVerifyConfirmInDto body) {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.session.invalid"));
        }
        emailVerifyService.confirmEmailVerify(uid, body.getCode());
    }

    @Override
    public void sendLoginChallenge(AppLoginChallengeSendInDto body) {
        emailVerifyService.sendLoginChallenge(body.getEmail());
    }

    @Override
    public AppAuthResultVO confirmLoginChallenge(AppLoginChallengeConfirmInDto body) {
        return appAuthService.confirmLoginChallenge(body);
    }
}
