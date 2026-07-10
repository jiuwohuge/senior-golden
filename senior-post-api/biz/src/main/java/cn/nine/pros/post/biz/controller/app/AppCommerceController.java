package cn.nine.pros.post.biz.controller.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.biz.AppCommerceBizService;
import cn.nine.pros.post.client.api.app.AppCommerceApi;
import cn.nine.pros.post.client.model.input.app.CommerceMockPurchaseInDto;
import cn.nine.pros.post.client.model.out.CommerceEntitlementVO;
import cn.nine.pros.post.client.model.out.CommerceProductVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class AppCommerceController implements AppCommerceApi {

    private final AppCommerceBizService appCommerceBizService;
    private final AppMessages appMessages;

    @Override
    public List<CommerceProductVO> catalog() {
        return appCommerceBizService.catalog(requireUserId());
    }

    @Override
    public List<CommerceEntitlementVO> entitlements() {
        return appCommerceBizService.entitlements(requireUserId());
    }

    @Override
    public CommerceEntitlementVO mockPurchase(CommerceMockPurchaseInDto body) {
        return appCommerceBizService.mockPurchase(requireUserId(), body);
    }

    private Long requireUserId() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.notLoggedIn"));
        }
        return uid;
    }
}
