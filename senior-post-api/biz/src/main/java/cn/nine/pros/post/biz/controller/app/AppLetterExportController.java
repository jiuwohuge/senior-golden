package cn.nine.pros.post.biz.controller.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.biz.AppLetterExportBizService;
import cn.nine.pros.post.client.api.app.AppLetterExportApi;
import cn.nine.pros.post.client.model.input.app.LetterExportInDto;
import cn.nine.pros.post.client.model.out.LetterExportResultVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AppLetterExportController implements AppLetterExportApi {

    private final AppLetterExportBizService appLetterExportBizService;
    private final AppMessages appMessages;

    @Override
    public LetterExportResultVO export(LetterExportInDto body) {
        return appLetterExportBizService.export(requireUserId(), body);
    }

    private Long requireUserId() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.notLoggedIn"));
        }
        return uid;
    }
}
