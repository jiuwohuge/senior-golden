package cn.nine.pros.post.client.api.app;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.out.AppImUserSigVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Tag(name = "App-腾讯IM")
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/im")
public interface AppImApi {

    @Operation(summary = "获取当前用户 UserSig（用于 TIM SDK 登录；须至少有一条活跃邮政好友关系，否则拒绝以节省 IM 席位）")
    @GetMapping("/usersig")
    AppImUserSigVO userSig();
}
