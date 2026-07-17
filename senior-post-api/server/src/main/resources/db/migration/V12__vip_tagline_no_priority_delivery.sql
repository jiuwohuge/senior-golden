-- 清理 VIP「优先送达」文案；去掉已废弃的邮票加速相关暗示
UPDATE sys_config
SET config_value = 'Expression upgrades · Ad-free',
    updated_at = NOW()
WHERE config_key = 'vip.product.tagline';

UPDATE sys_config
SET config_value = '专属装扮 · 无广告干扰',
    updated_at = NOW()
WHERE config_key = 'vip.product.tagline_zh';
