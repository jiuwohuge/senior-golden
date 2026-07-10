package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.biz.service.biz.admin.AdminSensitiveWordBizService;
import cn.nine.pros.post.client.api.admin.AdminSensitiveWordApi;
import cn.nine.pros.post.client.model.db.SensitiveWordDTO;
import cn.nine.pros.post.client.model.input.admin.SensitiveWordInDto;
import cn.nine.pros.post.client.model.input.admin.SensitiveWordQueryInDto;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AdminSensitiveWordController implements AdminSensitiveWordApi {

    private final AdminSensitiveWordBizService adminSensitiveWordBizService;

    @Override
    public PageData<SensitiveWordDTO> paging(SensitiveWordQueryInDto body) {
        return adminSensitiveWordBizService.paging(body);
    }

    @Override
    public void save(SensitiveWordInDto body) {
        adminSensitiveWordBizService.save(body);
    }

    @Override
    public void delete(Integer id) {
        adminSensitiveWordBizService.delete(id);
    }
}
