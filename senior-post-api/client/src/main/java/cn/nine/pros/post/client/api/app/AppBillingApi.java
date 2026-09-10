package cn.nine.pros.post.client.api.app;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.app.BillingTestOverrideInDto;
import cn.nine.pros.post.client.model.input.app.PlayPurchaseVerifyInDto;
import cn.nine.pros.post.client.model.input.app.PlayRestoreInDto;
import cn.nine.pros.post.client.model.out.SubscriptionStatusVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

@Tag(name = "App-Plus Billing")
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/billing")
public interface AppBillingApi {

    @Operation(summary = "当前订阅状态与 AI/撤回权益快照")
    @GetMapping("/subscription")
    SubscriptionStatusVO subscription();

    @Operation(summary = "校验并落库 Play 购买（生产须接 Play Developer API）")
    @PostMapping("/verify-purchase")
    SubscriptionStatusVO verifyPurchase(@RequestBody @Valid PlayPurchaseVerifyInDto body);

    @Operation(summary = "恢复购买：重验本地购买或重读服务端权益")
    @PostMapping("/restore")
    SubscriptionStatusVO restore(@RequestBody(required = false) PlayRestoreInDto body);

    @Operation(summary = "测试覆盖订阅状态（仅 BILLING_TEST_OVERRIDE=true）")
    @PostMapping("/test-override")
    SubscriptionStatusVO testOverride(@RequestBody @Valid BillingTestOverrideInDto body);
}
