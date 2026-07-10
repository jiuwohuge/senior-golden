package cn.nine.pros.post.biz.service.biz.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.controller.admin.AdminPageHelper;
import cn.nine.pros.post.biz.model.domain.CountryDomain;
import cn.nine.pros.post.biz.model.mapstruct.CountryMapstruct;
import cn.nine.pros.post.biz.service.base.CountryService;
import cn.nine.pros.post.client.model.db.CountryDTO;
import cn.nine.pros.post.client.model.input.admin.CountryInDto;
import cn.nine.pros.post.client.model.input.admin.CountryQueryInDto;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 管理端国家字典 CRUD。
 */
@Service
@RequiredArgsConstructor
public class AdminCountryBizService {

    private final CountryService countryService;
    private final CountryMapstruct countryMapstruct;

    /**
     * 按国家码/关键词分页查询国家。
     */
    public PageData<CountryDTO> paging(CountryQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        Page<CountryDomain> p = countryService.pageForAdmin(
                pageQuery, body.getCountryCode(), body.getKeyword());
        List<CountryDTO> list = p.getRecords().stream().map(countryMapstruct::toDTO).collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }

    /**
     * 新增或更新国家字典项。
     */
    public void save(CountryInDto body) {
        CountryDTO dto = new CountryDTO();
        dto.setId(body.getId());
        dto.setCountryCode(body.getCountryCode() != null ? body.getCountryCode().trim() : null);
        dto.setCountryNameEn(body.getCountryNameEn() != null ? body.getCountryNameEn().trim() : null);
        dto.setCountryNameZh(body.getCountryNameZh() != null ? body.getCountryNameZh().trim() : null);
        dto.setSortOrder(body.getSortOrder() != null ? body.getSortOrder() : 0);
        countryService.upsert(dto);
    }

    /**
     * 按主键删除国家字典项。
     */
    public void delete(Integer id) {
        countryService.delByIds(List.of(id));
    }
}
