package cn.nine.pros.post.client.api.app;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.app.CommerceMockPurchaseInDto;
import cn.nine.pros.post.client.model.out.CommerceEntitlementVO;
import cn.nine.pros.post.client.model.out.CommerceProductVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

@Tag(name = "App-商业")
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/commerce")
public interface AppCommerceApi {

    @Operation(summary = "商店商品目录")
    @GetMapping("/catalog")
    List<CommerceProductVO> catalog();

    @Operation(summary = "我的装扮/权益")
    @GetMapping("/entitlements")
    List<CommerceEntitlementVO> entitlements();

    @Operation(summary = "模拟购买（MVP，无真实 IAP）")
    @PostMapping("/mock-purchase")
    CommerceEntitlementVO mockPurchase(@RequestBody @Valid CommerceMockPurchaseInDto body);
}
