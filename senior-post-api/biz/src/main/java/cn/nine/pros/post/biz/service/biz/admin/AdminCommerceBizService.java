package cn.nine.pros.post.biz.service.biz.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.model.input.admin.AdminCommerceGrantInDto;
import cn.nine.pros.post.client.model.input.admin.AdminCommerceProductQueryInDto;
import cn.nine.pros.post.client.model.input.admin.AdminCommerceProductSaveInDto;
import cn.nine.pros.post.client.model.out.CommerceEntitlementVO;
import cn.nine.pros.post.client.model.out.CommerceProductVO;

public interface AdminCommerceBizService {

    PageData<CommerceProductVO> pagingProducts(AdminCommerceProductQueryInDto body);

    CommerceProductVO saveProduct(AdminCommerceProductSaveInDto body);

    CommerceEntitlementVO grant(AdminCommerceGrantInDto body);
}
