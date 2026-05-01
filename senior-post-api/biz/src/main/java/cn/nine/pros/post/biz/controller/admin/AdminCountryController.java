package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.model.domain.CountryDomain;
import cn.nine.pros.post.biz.model.mapstruct.CountryMapstruct;
import cn.nine.pros.post.biz.service.base.CountryService;
import cn.nine.pros.post.client.api.admin.AdminCountryApi;
import cn.nine.pros.post.client.model.db.CountryDTO;
import cn.nine.pros.post.client.model.input.admin.CountryInDto;
import cn.nine.pros.post.client.model.input.admin.CountryQueryInDto;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.StringUtils;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequiredArgsConstructor
public class AdminCountryController implements AdminCountryApi {

    private final CountryService countryService;
    private final CountryMapstruct countryMapstruct;

    @Override
    public PageData<CountryDTO> paging(CountryQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        LambdaQueryWrapper<CountryDomain> qw = new LambdaQueryWrapper<CountryDomain>()
                .eq(CountryDomain::isDelFlag, false)
                .orderByAsc(CountryDomain::getSortOrder)
                .orderByAsc(CountryDomain::getId);
        if (StringUtils.isNotBlank(body.getCountryCode())) {
            qw.like(CountryDomain::getCountryCode, body.getCountryCode().trim());
        }
        if (StringUtils.isNotBlank(body.getKeyword())) {
            String k = body.getKeyword().trim();
            qw.and(w -> w.like(CountryDomain::getCountryNameEn, k)
                    .or().like(CountryDomain::getCountryNameZh, k)
                    .or().like(CountryDomain::getCountryCode, k));
        }
        Page<CountryDomain> p = countryService.page(AdminPageHelper.mpPage(pageQuery), qw);
        List<CountryDTO> list = p.getRecords().stream().map(countryMapstruct::toDTO).collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }

    @Override
    public void save(CountryInDto body) {
        CountryDTO dto = new CountryDTO();
        dto.setId(body.getId());
        dto.setCountryCode(body.getCountryCode() != null ? body.getCountryCode().trim() : null);
        dto.setCountryNameEn(body.getCountryNameEn() != null ? body.getCountryNameEn().trim() : null);
        dto.setCountryNameZh(body.getCountryNameZh() != null ? body.getCountryNameZh().trim() : null);
        dto.setSortOrder(body.getSortOrder() != null ? body.getSortOrder() : 0);
        countryService.upsert(dto);
    }

    @Override
    public void delete(Integer id) {
        countryService.delByIds(List.of(id));
    }
}
