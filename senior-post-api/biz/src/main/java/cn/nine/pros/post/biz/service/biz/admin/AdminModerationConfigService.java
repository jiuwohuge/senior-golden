package cn.nine.pros.post.biz.service.biz.admin;

import cn.nine.pros.post.biz.moderation.ModerationRuntimeConfig;
import cn.nine.pros.post.biz.moderation.ModerationRuntimeConfigService;
import cn.nine.pros.post.client.model.input.admin.ModerationConfigSaveInDto;
import cn.nine.pros.post.client.model.out.ModerationConfigVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AdminModerationConfigService {

    private final ModerationRuntimeConfigService moderationRuntimeConfigService;

    public ModerationConfigVO get() {
        ModerationRuntimeConfig cfg = moderationRuntimeConfigService.loadFromDb();
        return ModerationConfigVO.builder()
                .baiduCredentialsReady(cfg.baiduCredentialsReady())
                .deepseekCredentialsReady(cfg.deepseekCredentialsReady())
                .build();
    }

    @Transactional(rollbackFor = Exception.class)
    public void save(ModerationConfigSaveInDto body) {
        moderationRuntimeConfigService.invalidateCache();
    }
}
