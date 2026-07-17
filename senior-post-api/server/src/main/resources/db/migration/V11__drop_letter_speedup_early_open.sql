-- 移除平邮加速 / 提前拆信字段与 VIP 加速占位配置（4.0 已无该产品能力）
ALTER TABLE bu_letter DROP COLUMN IF EXISTS is_accelerated;
ALTER TABLE bu_letter DROP COLUMN IF EXISTS accelerated_at;
ALTER TABLE bu_letter DROP COLUMN IF EXISTS recipient_early_open_at;

DELETE FROM sys_config WHERE config_key = 'vip.benefit.standard_delivery_hours';
