package cn.nine.pros.post.client.api.admin;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.admin.ModerationConfigSaveInDto;
import cn.nine.pros.post.client.model.out.ModerationConfigVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

@Tag(name = "管理后台-内容安全")
@RequestMapping(AppServiceDefine.WEBAPI_PREFIX + "/config/moderation")
public interface AdminModerationConfigApi {

    @Operation(summary = "明信片机审开关与凭证就绪状态")
    @GetMapping
    ModerationConfigVO get();

    @Operation(summary = "保存明信片机审开关")
    @PostMapping("/save")
    void save(@RequestBody @Valid ModerationConfigSaveInDto body);
}
