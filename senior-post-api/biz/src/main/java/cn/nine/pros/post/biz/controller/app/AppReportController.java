package cn.nine.pros.post.biz.controller.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.app.AppReportService;
import cn.nine.pros.post.client.api.app.AppReportApi;
import cn.nine.pros.post.client.model.input.app.AppReportCreateInDto;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@Tag(name = "App-举报")
public class AppReportController implements AppReportApi {

    private final AppReportService appReportService;
    private final AppMessages appMessages;

    @Override
    public void submit(@Valid AppReportCreateInDto body) {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.notLoggedIn"));
        }
        appReportService.submit(uid, body);
    }
}
