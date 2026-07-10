package cn.nine.pros.post.client.api.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.admin.AdminCommerceGrantInDto;
import cn.nine.pros.post.client.model.input.admin.AdminCommerceProductQueryInDto;
import cn.nine.pros.post.client.model.input.admin.AdminCommerceProductSaveInDto;
import cn.nine.pros.post.client.model.out.CommerceEntitlementVO;
import cn.nine.pros.post.client.model.out.CommerceProductVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

@Tag(name = "管理后台-商业")
@RequestMapping(AppServiceDefine.WEBAPI_PREFIX + "/commerce")
public interface AdminCommerceApi {

    @Operation(summary = "商品分页")
    @PostMapping("/products/paging")
    PageData<CommerceProductVO> pagingProducts(@RequestBody @Valid AdminCommerceProductQueryInDto body);

    @Operation(summary = "保存商品")
    @PostMapping("/products/save")
    CommerceProductVO saveProduct(@RequestBody @Valid AdminCommerceProductSaveInDto body);

    @Operation(summary = "手动发放权益")
    @PostMapping("/grant")
    CommerceEntitlementVO grant(@RequestBody @Valid AdminCommerceGrantInDto body);
}
