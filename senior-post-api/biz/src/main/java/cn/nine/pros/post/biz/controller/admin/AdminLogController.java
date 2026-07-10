package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.biz.service.biz.admin.AdminLogBizService;
import cn.nine.pros.post.client.api.admin.AdminLogApi;
import cn.nine.pros.post.client.model.db.ActionDTO;
import cn.nine.pros.post.client.model.db.LoginDTO;
import cn.nine.pros.post.client.model.input.admin.ActionLogQueryInDto;
import cn.nine.pros.post.client.model.input.admin.LoginLogQueryInDto;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AdminLogController implements AdminLogApi {

    private final AdminLogBizService adminLogBizService;

    @Override
    public PageData<ActionDTO> pagingActions(ActionLogQueryInDto body) {
        return adminLogBizService.pagingActions(body);
    }

    @Override
    public PageData<LoginDTO> pagingLogins(LoginLogQueryInDto body) {
        return adminLogBizService.pagingLogins(body);
    }
}
