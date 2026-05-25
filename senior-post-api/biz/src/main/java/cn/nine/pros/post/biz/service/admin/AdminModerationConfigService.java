package cn.nine.pros.post.biz.service.admin;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.ConfigDomain;
import cn.nine.pros.post.biz.moderation.ModerationConfigKeys;
import cn.nine.pros.post.biz.moderation.ModerationRuntimeConfig;
import cn.nine.pros.post.biz.moderation.ModerationRuntimeConfigService;
import cn.nine.pros.post.biz.service.base.ConfigService;
import cn.nine.pros.post.client.model.input.admin.ModerationConfigSaveInDto;
import cn.nine.pros.post.client.model.out.ModerationConfigVO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class AdminModerationConfigService {

    private final ModerationRuntimeConfigService moderationRuntimeConfigService;
    private final ConfigService configService;
    private final AppMessages appMessages;

    public ModerationConfigVO get() {
        ModerationRuntimeConfig cfg = moderationRuntimeConfigService.loadFromDb();
        return ModerationConfigVO.builder()
                .postcardImageEnabled(cfg.postcardImageEnabled())
                .postcardTextEnabled(cfg.postcardTextEnabled())
                .baiduCredentialsReady(cfg.baiduCredentialsReady())
                .deepseekCredentialsReady(cfg.deepseekCredentialsReady())
                .build();
    }

    @Transactional(rollbackFor = Exception.class)
    public void save(ModerationConfigSaveInDto body) {
        if (Boolean.TRUE.equals(body.getPostcardImageEnabled())
                && !moderationRuntimeConfigService.loadFromDb().baiduCredentialsReady()) {
            throw new BadRequestException(appMessages.get("admin.error.moderation.baiduNotConfigured"));
        }
        if (Boolean.TRUE.equals(body.getPostcardTextEnabled())
                && !moderationRuntimeConfigService.loadFromDb().deepseekCredentialsReady()) {
            throw new BadRequestException(appMessages.get("admin.error.moderation.deepseekNotConfigured"));
        }
        upsertFlag(ModerationConfigKeys.POSTCARD_IMAGE_ENABLED, body.getPostcardImageEnabled());
        upsertFlag(ModerationConfigKeys.POSTCARD_TEXT_ENABLED, body.getPostcardTextEnabled());
        moderationRuntimeConfigService.invalidateCache();
    }

    private void upsertFlag(String key, boolean enabled) {
        String value = enabled ? "true" : "false";
        ConfigDomain existing = configService.getOne(new LambdaQueryWrapper<ConfigDomain>()
                .eq(ConfigDomain::isDelFlag, false)
                .eq(ConfigDomain::getConfigKey, key)
                .last("LIMIT 1"));
        LocalDateTime now = LocalDateTime.now();
        if (existing != null) {
            existing.setConfigValue(value);
            existing.setUpdatedAt(now);
            existing.setUpdatedBy(0L);
            configService.updateById(existing);
            return;
        }
        ConfigDomain row = new ConfigDomain();
        row.setConfigKey(key);
        row.setConfigValue(value);
        row.setConfigGroup(ModerationConfigKeys.GROUP);
        row.setDescription(descriptionFor(key));
        row.setCreatedAt(now);
        row.setUpdatedAt(now);
        row.setCreatedBy(0L);
        row.setUpdatedBy(0L);
        row.setDelFlag(false);
        configService.save(row);
    }

    private static String descriptionFor(String key) {
        return switch (key) {
            case ModerationConfigKeys.POSTCARD_IMAGE_ENABLED -> "明信片配图鉴黄（百度）";
            case ModerationConfigKeys.POSTCARD_TEXT_ENABLED -> "明信片正文鉴黄（DeepSeek）";
            default -> "";
        };
    }
}
