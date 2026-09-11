package cn.nine.pros.post.biz.controller.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.biz.AppPushBizService;
import cn.nine.pros.post.client.api.app.AppPushApi;
import cn.nine.pros.post.client.model.input.app.PushMockEnqueueInDto;
import cn.nine.pros.post.client.model.out.PushMockEnqueueVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

/**
 * App 推送 Controller：QA mock-enqueue。
 */
@RestController
@RequiredArgsConstructor
public class AppPushController implements AppPushApi {

    private final AppPushBizService appPushBizService;
    private final AppMessages appMessages;

    @Override
    public PushMockEnqueueVO mockEnqueue(PushMockEnqueueInDto body) {
        return appPushBizService.mockEnqueue(requireUserId(), body);
    }

    private Long requireUserId() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.notLoggedIn"));
        }
        return uid;
    }
}
