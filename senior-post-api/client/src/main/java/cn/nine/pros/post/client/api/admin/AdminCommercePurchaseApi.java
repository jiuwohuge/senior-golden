package cn.nine.pros.post.client.api.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.admin.AdminCommercePurchaseIdInDto;
import cn.nine.pros.post.client.model.input.admin.AdminCommercePurchaseQueryInDto;
import cn.nine.pros.post.client.model.out.AdminCommercePurchaseForceSyncResultVO;
import cn.nine.pros.post.client.model.out.CommercePurchaseDetailVO;
import cn.nine.pros.post.client.model.out.CommercePurchaseVO;
import cn.nine.pros.post.client.model.out.CommercePurchaseWebhookEventVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

@Tag(name = "管理后台-购买记录")
@RequestMapping(AppServiceDefine.WEBAPI_PREFIX + "/commerce/purchases")
public interface AdminCommercePurchaseApi {

    @Operation(summary = "购买记录分页（只读）")
    @PostMapping("/paging")
    PageData<CommercePurchaseVO> paging(@RequestBody @Valid AdminCommercePurchaseQueryInDto body);

    @Operation(summary = "购买详情（订阅/权益/时间线/webhook）")
    @PostMapping("/detail")
    CommercePurchaseDetailVO detail(@RequestBody @Valid AdminCommercePurchaseIdInDto body);

    @Operation(summary = "购买关联 webhook 事件（payload 已脱敏）")
    @PostMapping("/webhook-events")
    List<CommercePurchaseWebhookEventVO> webhookEvents(@RequestBody @Valid AdminCommercePurchaseIdInDto body);

    @Operation(summary = "强制同步购买（仅重查，不退款）")
    @PostMapping("/force-sync")
    AdminCommercePurchaseForceSyncResultVO forceSync(@RequestBody @Valid AdminCommercePurchaseIdInDto body);
}
