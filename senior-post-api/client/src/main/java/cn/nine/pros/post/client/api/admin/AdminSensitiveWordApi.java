package cn.nine.pros.post.client.api.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.SensitiveWordDTO;
import cn.nine.pros.post.client.model.input.admin.SensitiveWordInDto;
import cn.nine.pros.post.client.model.input.admin.SensitiveWordQueryInDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@Tag(name = "管理后台-敏感词")
@RequestMapping(AppServiceDefine.WEBAPI_PREFIX + "/sensitive-word")
public interface AdminSensitiveWordApi {

    @Operation(summary = "敏感词分页")
    @PostMapping("/paging")
    PageData<SensitiveWordDTO> paging(@RequestBody @Valid SensitiveWordQueryInDto body);

    @Operation(summary = "保存敏感词")
    @PostMapping("/save")
    void save(@RequestBody @Valid SensitiveWordInDto body);

    @Operation(summary = "删除敏感词")
    @PostMapping("/{id}/delete")
    void delete(@PathVariable("id") Integer id);
}
