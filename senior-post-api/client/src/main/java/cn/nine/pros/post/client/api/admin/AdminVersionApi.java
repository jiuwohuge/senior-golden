package cn.nine.pros.post.client.api.admin;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.AppVersionDTO;
import cn.nine.pros.post.client.model.input.admin.AppVersionInDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "管理后台-版本管理API")
public interface AdminVersionApi {

    @Operation(summary = "版本列表")
    @GetMapping(AppServiceDefine.WEBAPI_PREFIX + "/version/list")
    List<AppVersionDTO> listVersions();

    @Operation(summary = "创建版本")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/version")
    void createVersion(@RequestBody @Validated AppVersionInDto version);

    @Operation(summary = "更新版本")
    @PutMapping(AppServiceDefine.WEBAPI_PREFIX + "/version/{id}")
    void updateVersion(@PathVariable("id") Integer id, @RequestBody @Validated AppVersionInDto version);

    @Operation(summary = "删除版本")
    @DeleteMapping(AppServiceDefine.WEBAPI_PREFIX + "/version/{id}")
    void deleteVersion(@PathVariable("id") Integer id);
}