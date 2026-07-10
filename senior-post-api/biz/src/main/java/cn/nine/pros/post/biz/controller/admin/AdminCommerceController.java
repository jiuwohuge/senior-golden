package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.biz.service.biz.admin.AdminCommerceBizService;
import cn.nine.pros.post.client.api.admin.AdminCommerceApi;
import cn.nine.pros.post.client.model.input.admin.AdminCommerceGrantInDto;
import cn.nine.pros.post.client.model.input.admin.AdminCommerceProductQueryInDto;
import cn.nine.pros.post.client.model.input.admin.AdminCommerceProductSaveInDto;
import cn.nine.pros.post.client.model.out.CommerceEntitlementVO;
import cn.nine.pros.post.client.model.out.CommerceProductVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AdminCommerceController implements AdminCommerceApi {

    private final AdminCommerceBizService adminCommerceBizService;

    @Override
    public PageData<CommerceProductVO> pagingProducts(AdminCommerceProductQueryInDto body) {
        return adminCommerceBizService.pagingProducts(body);
    }

    @Override
    public CommerceProductVO saveProduct(AdminCommerceProductSaveInDto body) {
        return adminCommerceBizService.saveProduct(body);
    }

    @Override
    public CommerceEntitlementVO grant(AdminCommerceGrantInDto body) {
        return adminCommerceBizService.grant(body);
    }
}
