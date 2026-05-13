-- FP-X-003：版本公告结构化字段（标题 / 版本号展示 / 纯文本更新说明 + 可选版本区间）
ALTER TABLE sys_announcement ADD COLUMN IF NOT EXISTS version_label VARCHAR(64);
ALTER TABLE sys_announcement ADD COLUMN IF NOT EXISTS min_version_code INTEGER;
ALTER TABLE sys_announcement ADD COLUMN IF NOT EXISTS max_version_code INTEGER;

COMMENT ON COLUMN sys_announcement.version_label IS '版本号（展示），如 1.2.0';
COMMENT ON COLUMN sys_announcement.min_version_code IS '可见最小客户端 versionCode（含），空表示不限制';
COMMENT ON COLUMN sys_announcement.max_version_code IS '可见最大客户端 versionCode（含），空表示不限制';
