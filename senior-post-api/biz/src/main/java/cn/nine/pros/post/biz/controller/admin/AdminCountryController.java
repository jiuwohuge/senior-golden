package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.biz.service.biz.admin.AdminCountryBizService;
import cn.nine.pros.post.client.api.admin.AdminCountryApi;
import cn.nine.pros.post.client.model.db.CountryDTO;
import cn.nine.pros.post.client.model.input.admin.CountryInDto;
import cn.nine.pros.post.client.model.input.admin.CountryQueryInDto;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AdminCountryController implements AdminCountryApi {

    private final AdminCountryBizService adminCountryBizService;

    @Override
    public PageData<CountryDTO> paging(CountryQueryInDto body) {
        return adminCountryBizService.paging(body);
    }

    @Override
    public void save(CountryInDto body) {
        adminCountryBizService.save(body);
    }

    @Override
    public void delete(Integer id) {
        adminCountryBizService.delete(id);
    }
}
