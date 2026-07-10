package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.biz.service.biz.admin.AdminVersionBizService;
import cn.nine.pros.post.client.api.admin.AdminVersionApi;
import cn.nine.pros.post.client.model.db.AppVersionDTO;
import cn.nine.pros.post.client.model.input.admin.AppVersionInDto;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AdminVersionController implements AdminVersionApi {

    private final AdminVersionBizService adminVersionBizService;

    @Override
    public PageData<AppVersionDTO> paging(AppVersionInDto body) {
        return adminVersionBizService.paging(body);
    }

    @Override
    public void save(AppVersionInDto body) {
        adminVersionBizService.save(body);
    }

    @Override
    public void delete(Integer id) {
        adminVersionBizService.delete(id);
    }
}
