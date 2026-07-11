package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.biz.service.biz.admin.AdminMailOutboxBizService;
import cn.nine.pros.post.client.api.admin.AdminMailOutboxApi;
import cn.nine.pros.post.client.model.input.admin.MailOutboxQueryInDto;
import cn.nine.pros.post.client.model.out.MailOutboxVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AdminMailOutboxController implements AdminMailOutboxApi {

    private final AdminMailOutboxBizService adminMailOutboxBizService;

    @Override
    public PageData<MailOutboxVO> paging(MailOutboxQueryInDto body) {
        return adminMailOutboxBizService.paging(body);
    }

    @Override
    public MailOutboxVO detail(Long id) {
        return adminMailOutboxBizService.detail(id);
    }

    @Override
    public void retry(Long id) {
        adminMailOutboxBizService.retry(id);
    }
}
