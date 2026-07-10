package cn.nine.pros.post.client.api.app;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.app.UserPreferencesPatchInDto;
import cn.nine.pros.post.client.model.out.ProfileOverviewVO;
import cn.nine.pros.post.client.model.out.UserPreferencesVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

@Tag(name = "App-个人中心")
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/profile")
public interface AppProfileApi {

    @Operation(summary = "个人中心概览统计（§13）")
    @GetMapping("/overview")
    ProfileOverviewVO overview();

    @Operation(summary = "隐私与通知偏好")
    @GetMapping("/preferences")
    UserPreferencesVO preferences();

    @Operation(summary = "更新隐私与通知偏好（部分字段）")
    @PatchMapping("/preferences")
    UserPreferencesVO patchPreferences(@RequestBody @Valid UserPreferencesPatchInDto body);
}
