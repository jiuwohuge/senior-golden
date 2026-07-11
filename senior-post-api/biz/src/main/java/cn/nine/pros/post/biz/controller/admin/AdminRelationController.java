package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.biz.service.biz.admin.AdminRelationBizService;
import cn.nine.pros.post.client.api.admin.AdminRelationApi;
import cn.nine.pros.post.client.model.input.admin.AdminPenpalQueryInDto;
import cn.nine.pros.post.client.model.out.AdminPenpalItemVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AdminRelationController implements AdminRelationApi {

    private final AdminRelationBizService adminRelationBizService;

    @Override
    public PageData<AdminPenpalItemVO> pagingPenpal(AdminPenpalQueryInDto body) {
        return adminRelationBizService.pagingPenpal(body);
    }

    @Override
    public void dissolvePenpal(Long id) {
        adminRelationBizService.dissolvePenpal(id);
    }
}
