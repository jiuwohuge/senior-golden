package cn.nine.pros.post.biz.service.biz.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.model.input.admin.AdminCommercePurchaseIdInDto;
import cn.nine.pros.post.client.model.input.admin.AdminCommercePurchaseQueryInDto;
import cn.nine.pros.post.client.model.out.AdminCommercePurchaseForceSyncResultVO;
import cn.nine.pros.post.client.model.out.CommercePurchaseDetailVO;
import cn.nine.pros.post.client.model.out.CommercePurchaseVO;
import cn.nine.pros.post.client.model.out.CommercePurchaseWebhookEventVO;

import java.util.List;

/**
 * 管理端购买记录（只读查询 + 可选强制同步，不退款）。
 */
public interface AdminCommercePurchaseBizService {

    PageData<CommercePurchaseVO> paging(AdminCommercePurchaseQueryInDto body);

    CommercePurchaseDetailVO detail(AdminCommercePurchaseIdInDto body);

    List<CommercePurchaseWebhookEventVO> webhookEvents(AdminCommercePurchaseIdInDto body);

    AdminCommercePurchaseForceSyncResultVO forceSync(AdminCommercePurchaseIdInDto body);
}
