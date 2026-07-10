package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.biz.service.biz.admin.AdminConfigBizService;
import cn.nine.pros.post.client.api.admin.AdminConfigApi;
import cn.nine.pros.post.client.model.db.ConfigDTO;
import cn.nine.pros.post.client.model.input.admin.ConfigInDto;
import cn.nine.pros.post.client.model.input.admin.ConfigQueryInDto;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AdminConfigController implements AdminConfigApi {

    private final AdminConfigBizService adminConfigBizService;

    @Override
    public PageData<ConfigDTO> paging(ConfigQueryInDto body) {
        return adminConfigBizService.paging(body);
    }

    @Override
    public void save(ConfigInDto body) {
        adminConfigBizService.save(body);
    }

    @Override
    public void delete(Integer id) {
        adminConfigBizService.delete(id);
    }
}
