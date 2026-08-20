-- P0 冷启动：首页主推由管理后台手动切换，默认时光信
INSERT INTO sys_config (config_key, config_value, config_group, description, created_at, updated_at, created_by, updated_by, del_flag)
VALUES
('home.recommended_action', 'TIME_LETTER', 'home', '首页主 CTA：TIME_LETTER 或 POST_OFFICE', NOW(), NOW(), 0, 0, FALSE)
ON CONFLICT (config_key) DO UPDATE SET
    config_value = EXCLUDED.config_value,
    config_group = EXCLUDED.config_group,
    description  = EXCLUDED.description,
    del_flag     = FALSE,
    updated_at   = NOW(),
    updated_by   = 0;
