package cn.nine.pros.post.biz.controller.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.biz.AppBillingBizService;
import cn.nine.pros.post.client.api.app.AppBillingApi;
import cn.nine.pros.post.client.model.input.app.BillingMockSyncInDto;
import cn.nine.pros.post.client.model.input.app.BillingTestOverrideInDto;
import cn.nine.pros.post.client.model.input.app.PlayPurchaseVerifyInDto;
import cn.nine.pros.post.client.model.input.app.PlayRestoreInDto;
import cn.nine.pros.post.client.model.out.SubscriptionStatusVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AppBillingController implements AppBillingApi {

    private final AppBillingBizService appBillingBizService;
    private final AppMessages appMessages;

    @Override
    public SubscriptionStatusVO subscription() {
        return appBillingBizService.getSubscriptionStatus(requireUserId());
    }

    @Override
    public SubscriptionStatusVO verifyPurchase(PlayPurchaseVerifyInDto body) {
        return appBillingBizService.verifyPurchase(requireUserId(), body);
    }

    @Override
    public SubscriptionStatusVO restore(PlayRestoreInDto body) {
        return appBillingBizService.restore(requireUserId(), body);
    }

    @Override
    public SubscriptionStatusVO testOverride(BillingTestOverrideInDto body) {
        return appBillingBizService.testOverride(requireUserId(), body);
    }

    @Override
    public SubscriptionStatusVO mockSync(BillingMockSyncInDto body) {
        return appBillingBizService.mockSync(requireUserId(), body);
    }

    private Long requireUserId() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.notLoggedIn"));
        }
        return uid;
    }
}
