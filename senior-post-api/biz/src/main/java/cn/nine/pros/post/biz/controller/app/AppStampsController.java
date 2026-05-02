package cn.nine.pros.post.biz.controller.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.biz.service.app.AppStampsService;
import cn.nine.pros.post.client.api.app.AppStampsApi;
import cn.nine.pros.post.client.model.db.StampTransactionDTO;
import cn.nine.pros.post.client.model.input.app.AppStampLedgerPageInDto;
import cn.nine.pros.post.client.model.out.AppStampBalanceVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AppStampsController implements AppStampsApi {

    private final AppStampsService appStampsService;

    @Override
    public AppStampBalanceVO balance() {
        Long uid = requireUserId();
        return appStampsService.balance(uid);
    }

    @Override
    public PageData<StampTransactionDTO> ledgerPaging(AppStampLedgerPageInDto body) {
        Long uid = requireUserId();
        if (body == null) {
            body = new AppStampLedgerPageInDto();
        }
        return appStampsService.ledgerPage(uid, body.getPage());
    }

    private static Long requireUserId() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException("未登录");
        }
        return uid;
    }
}
