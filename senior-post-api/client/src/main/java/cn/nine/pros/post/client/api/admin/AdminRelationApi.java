package cn.nine.pros.post.client.api.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.admin.AdminPenpalQueryInDto;
import cn.nine.pros.post.client.model.out.AdminPenpalItemVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

@Tag(name = "管理后台-笔友关系")
@RequestMapping(AppServiceDefine.WEBAPI_PREFIX + "/relation")
public interface AdminRelationApi {

    @Operation(summary = "笔友关系分页")
    @PostMapping("/penpal/paging")
    PageData<AdminPenpalItemVO> pagingPenpal(@RequestBody @Valid AdminPenpalQueryInDto body);

    @Operation(summary = "强制解除笔友")
    @PostMapping("/penpal/{id}/dissolve")
    void dissolvePenpal(@PathVariable("id") Long id);
}
