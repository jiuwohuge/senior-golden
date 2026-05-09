package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.biz.service.app.impl.AdminAppFeedbackService;
import cn.nine.pros.post.client.api.admin.AdminAppFeedbackApi;
import cn.nine.pros.post.client.model.input.admin.AppFeedbackAdminQueryInDto;
import cn.nine.pros.post.client.model.out.AppFeedbackAdminItemVO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AdminAppFeedbackController implements AdminAppFeedbackApi {

    private final AdminAppFeedbackService adminAppFeedbackService;

    @Override
    public PageData<AppFeedbackAdminItemVO> paging(@Valid AppFeedbackAdminQueryInDto body) {
        return adminAppFeedbackService.paging(body);
    }
}
