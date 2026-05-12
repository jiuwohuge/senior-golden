package cn.nine.pros.post.client.api.app;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.app.AppBlacklistBlockInDto;
import cn.nine.pros.post.client.model.out.AppBlockedUserItemVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.List;

@Tag(name = "App-社交与黑名单")
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/social")
public interface AppSocialApi {

    @Operation(summary = "拉黑用户")
    @PostMapping("/blocks")
    void block(@RequestBody @Valid AppBlacklistBlockInDto body);

    @Operation(summary = "取消拉黑")
    @DeleteMapping("/blocks/{blockedUserId}")
    void unblock(@PathVariable("blockedUserId") Long blockedUserId);

    @Operation(summary = "我的黑名单")
    @GetMapping("/blocks")
    List<AppBlockedUserItemVO> listBlocks();
}
