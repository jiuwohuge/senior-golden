package cn.nine.pros.post.biz.controller.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.biz.AppPostOfficeService;
import cn.nine.pros.post.client.api.app.AppPostOfficeApi;
import cn.nine.pros.post.client.model.out.AppPostOfficeHomeVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

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
}
