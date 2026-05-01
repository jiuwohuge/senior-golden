package cn.nine.pros.post.client.api.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.AppVersionDTO;
import cn.nine.pros.post.client.model.input.admin.AppVersionInDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@Tag(name = "管理后台-版本")
public interface AdminVersionApi {

    @Operation(summary = "版本分页")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/version/paging")
    PageData<AppVersionDTO> paging(@RequestBody AppVersionInDto body);

    @Operation(summary = "保存版本")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/version/save")
    void save(@RequestBody @Valid AppVersionInDto body);

    @Operation(summary = "删除版本")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/version/{id}/delete")
    void delete(@PathVariable("id") Integer id);
}
