package cn.nine.pros.post.client.api.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.CountryDTO;
import cn.nine.pros.post.client.model.input.admin.CountryInDto;
import cn.nine.pros.post.client.model.input.admin.CountryQueryInDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@Tag(name = "管理后台-国家/地区")
public interface AdminCountryApi {

    @Operation(summary = "分页查询国家/地区")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/country/paging")
    PageData<CountryDTO> paging(@RequestBody @Valid CountryQueryInDto body);

    @Operation(summary = "保存国家/地区")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/country/save")
    void save(@RequestBody @Valid CountryInDto body);

    @Operation(summary = "删除国家/地区")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/country/{id}/delete")
    void delete(@PathVariable("id") Integer id);
}
