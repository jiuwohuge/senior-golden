package cn.nine.pros.post.client.api.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.AppVersionDTO;
import cn.nine.pros.post.client.model.input.admin.AppVersionInDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

@Tag(name = "管理后台-版本")
@RequestMapping(AppServiceDefine.WEBAPI_PREFIX + "/version")
public interface AdminVersionApi {

    @Operation(summary = "版本分页")
    @PostMapping("/paging")
    PageData<AppVersionDTO> paging(@RequestBody AppVersionInDto body);

    @Operation(summary = "保存版本")
    @PostMapping("/save")
    void save(@RequestBody @Valid AppVersionInDto body);

    @Operation(summary = "删除版本")
    @PostMapping("/{id}/delete")
    void delete(@PathVariable("id") Integer id);
}
