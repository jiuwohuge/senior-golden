package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.biz.service.biz.admin.AdminCommercePurchaseBizService;
import cn.nine.pros.post.client.api.admin.AdminCommercePurchaseApi;
import cn.nine.pros.post.client.model.input.admin.AdminCommercePurchaseIdInDto;
import cn.nine.pros.post.client.model.input.admin.AdminCommercePurchaseQueryInDto;
import cn.nine.pros.post.client.model.out.AdminCommercePurchaseForceSyncResultVO;
import cn.nine.pros.post.client.model.out.CommercePurchaseDetailVO;
import cn.nine.pros.post.client.model.out.CommercePurchaseVO;
import cn.nine.pros.post.client.model.out.CommercePurchaseWebhookEventVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class AdminCommercePurchaseController implements AdminCommercePurchaseApi {

    private final AdminCommercePurchaseBizService adminCommercePurchaseBizService;

    @Override
    public PageData<CommercePurchaseVO> paging(AdminCommercePurchaseQueryInDto body) {
        return adminCommercePurchaseBizService.paging(body);
    }

    @Override
    public CommercePurchaseDetailVO detail(AdminCommercePurchaseIdInDto body) {
        return adminCommercePurchaseBizService.detail(body);
    }

    @Override
    public List<CommercePurchaseWebhookEventVO> webhookEvents(AdminCommercePurchaseIdInDto body) {
        return adminCommercePurchaseBizService.webhookEvents(body);
    }

    @Override
    public AdminCommercePurchaseForceSyncResultVO forceSync(AdminCommercePurchaseIdInDto body) {
        return adminCommercePurchaseBizService.forceSync(body);
    }
}
