package cn.nine.pros.post.biz.controller.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.biz.AppFeedbackService;
import cn.nine.pros.post.client.api.app.AppFeedbackApi;
import cn.nine.pros.post.client.model.input.app.AppFeedbackSubmitInDto;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AppFeedbackController implements AppFeedbackApi {

    private final AppFeedbackService appFeedbackService;
    private final AppMessages appMessages;

    @Override
    public void submit(@Valid AppFeedbackSubmitInDto body) {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.notLoggedIn"));
        }
        appFeedbackService.submit(uid, body);
    }
}
