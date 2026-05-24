package cn.nine.pros.post.client.api.app;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.out.AppImUserSigVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Tag(name = "App-腾讯IM")
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/im")
public interface AppImApi {

    @Operation(summary = "获取当前用户 UserSig（用于 TIM SDK 登录；须至少有一条活跃邮政好友关系，否则拒绝以节省 IM 席位）")
    @GetMapping("/usersig")
    AppImUserSigVO userSig();

    @Operation(summary = "补偿同步腾讯 IM：导入双方 UserID + 双向好友（业务已建联但 IM 未注册/未加好友时调用，幂等）")
    @PostMapping("/peers/{peerUserId}/sync")
    void compensateChatPeer(@PathVariable("peerUserId") Long peerUserId);
}
