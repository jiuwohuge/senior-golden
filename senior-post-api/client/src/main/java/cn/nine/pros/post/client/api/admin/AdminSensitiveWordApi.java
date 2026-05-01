package cn.nine.pros.post.client.api.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.SensitiveWordDTO;
import cn.nine.pros.post.client.model.input.admin.SensitiveWordInDto;
import cn.nine.pros.post.client.model.input.admin.SensitiveWordQueryInDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@Tag(name = "管理后台-敏感词管理API")
public interface AdminSensitiveWordApi {

    @Operation(summary = "敏感词列表")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/sensitive-word/list")
    PageData<SensitiveWordDTO> listSensitiveWords(@RequestBody @Validated SensitiveWordQueryInDto query);

    @Operation(summary = "创建敏感词")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/sensitive-word")
    void createSensitiveWord(@RequestBody @Validated SensitiveWordInDto word);

    @Operation(summary = "更新敏感词")
    @PutMapping(AppServiceDefine.WEBAPI_PREFIX + "/sensitive-word/{id}")
    void updateSensitiveWord(@PathVariable("id") Integer id, @RequestBody @Validated SensitiveWordInDto word);

    @Operation(summary = "删除敏感词")
    @DeleteMapping(AppServiceDefine.WEBAPI_PREFIX + "/sensitive-word/{id}")
    void deleteSensitiveWord(@PathVariable("id") Integer id);
}