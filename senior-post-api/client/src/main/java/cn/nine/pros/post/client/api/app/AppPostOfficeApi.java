package cn.nine.pros.post.client.api.app;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.out.AppPostOfficeHomeVO;
import cn.nine.pros.post.client.model.out.DailyQuotaClaimVO;
import cn.nine.pros.post.client.model.out.PostOfficeInTransitItemVO;
import cn.nine.pros.post.client.model.out.PostOfficeRelationMessageVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

@Tag(name = "App-邮局首页")
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/post-office")
public interface AppPostOfficeApi {

    @Operation(summary = "邮局首页聚合（问候、额度、关系/在途摘要）")
    @GetMapping("/home")
    AppPostOfficeHomeVO home();

    @Operation(summary = "关系消息明细（§11.3）")
    @GetMapping("/relation-messages")
    List<PostOfficeRelationMessageVO> relationMessages();

    @Operation(summary = "信件在途明细（§11.4）")
    @GetMapping("/in-transit")
    List<PostOfficeInTransitItemVO> inTransit();

    @Operation(summary = "领取今日免费写信额度（幂等，不可跳过）")
    @PostMapping("/quota/daily-claim")
    DailyQuotaClaimVO claimDailyQuota();
}
