package cn.nine.pros.post.biz.controller.admin;

import cn.nine.pros.post.biz.service.biz.admin.AdminModerationConfigService;
import cn.nine.pros.post.client.api.admin.AdminModerationConfigApi;
import cn.nine.pros.post.client.model.input.admin.ModerationConfigSaveInDto;
import cn.nine.pros.post.client.model.out.ModerationConfigVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AdminModerationConfigController implements AdminModerationConfigApi {

    private final AdminModerationConfigService adminModerationConfigService;

    @Override
    public ModerationConfigVO get() {
        return adminModerationConfigService.get();
    }

    @Override
    public void save(ModerationConfigSaveInDto body) {
        adminModerationConfigService.save(body);
    }
}
