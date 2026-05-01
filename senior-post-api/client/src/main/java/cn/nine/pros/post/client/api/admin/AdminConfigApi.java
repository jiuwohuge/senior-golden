package cn.nine.pros.post.client.api.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.ConfigDTO;
import cn.nine.pros.post.client.model.input.admin.ConfigInDto;
import cn.nine.pros.post.client.model.input.admin.ConfigQueryInDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@Tag(name = "管理后台-配置")
public interface AdminConfigApi {

    @Operation(summary = "分页查询配置")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/config/paging")
    PageData<ConfigDTO> paging(@RequestBody @Valid ConfigQueryInDto body);

    @Operation(summary = "保存配置")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/config/save")
    void save(@RequestBody @Valid ConfigInDto body);

    @Operation(summary = "删除配置")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/config/{id}/delete")
    void delete(@PathVariable("id") Integer id);
}
