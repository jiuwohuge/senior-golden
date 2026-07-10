package cn.nine.pros.post.biz.controller.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.biz.AppPostOfficeService;
import cn.nine.pros.post.client.api.app.AppPostOfficeApi;
import cn.nine.pros.post.client.model.out.AppPostOfficeHomeVO;
import cn.nine.pros.post.client.model.out.DailyQuotaClaimVO;
import cn.nine.pros.post.client.model.out.PostOfficeInTransitItemVO;
import cn.nine.pros.post.client.model.out.PostOfficeRelationMessageVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class AppPostOfficeController implements AppPostOfficeApi {

    private final AppPostOfficeService appPostOfficeService;
    private final AppMessages appMessages;

    @Override
    public AppPostOfficeHomeVO home() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.notLoggedIn"));
        }
        return appPostOfficeService.home(uid);
    }

    @Override
    public List<PostOfficeRelationMessageVO> relationMessages() {
        return appPostOfficeService.listRelationMessages(requireUserId());
    }

    @Override
    public List<PostOfficeInTransitItemVO> inTransit() {
        return appPostOfficeService.listInTransit(requireUserId());
    }

    @Override
    public DailyQuotaClaimVO claimDailyQuota() {
        return appPostOfficeService.claimDailyQuota(requireUserId());
    }

    private Long requireUserId() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.notLoggedIn"));
        }
        return uid;
    }
}
