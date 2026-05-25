INSERT INTO sys_config (config_key, config_value, config_group, description, created_at, updated_at, created_by, updated_by, del_flag)
VALUES
('moderation.postcard.image.enabled', 'false', 'moderation', '明信片配图鉴黄（百度）：true 开启自动审图，false 仅人工审核', NOW(), NOW(), 0, 0, FALSE),
('moderation.postcard.text.enabled', 'false', 'moderation', '明信片正文鉴黄（DeepSeek）：true 开启智能审文案，false 仅人工审核', NOW(), NOW(), 0, 0, FALSE)
ON CONFLICT (config_key) DO UPDATE SET
    config_group = EXCLUDED.config_group,
    description  = EXCLUDED.description,
    del_flag     = FALSE,
    updated_at   = NOW();
