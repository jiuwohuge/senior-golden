-- M3: match / audit / behavior config seeds
INSERT INTO sys_config (config_key, config_value, config_group, description, created_at, updated_at, created_by, updated_by, del_flag)
VALUES
('match.inbound_daily_cap', '10', 'match', '每用户每日可接收 POST_OFFICE 匹配信上限', NOW(), NOW(), 0, 0, FALSE),
('match.batch_size', '50', 'match', '匹配调度每批处理入池信件数', NOW(), NOW(), 0, 0, FALSE),
('match.new_user_protect_count', '3', 'match', '新用户保护池：发出/收到前 N 封优先', NOW(), NOW(), 0, 0, FALSE),
('match.candidate_pool_size', '200', 'match', '单次匹配候选用户扫描上限', NOW(), NOW(), 0, 0, FALSE),
('audit.auto_approve_seconds', '0', 'audit', 'PENDING_REVIEW 自动放行秒数；0=立即放行', NOW(), NOW(), 0, 0, FALSE)
ON CONFLICT (config_key) DO UPDATE SET
    config_value = EXCLUDED.config_value,
    config_group = EXCLUDED.config_group,
    description  = EXCLUDED.description,
    del_flag     = FALSE,
    updated_at   = NOW(),
    updated_by   = 0;

CREATE INDEX IF NOT EXISTS idx_log_action_user_created
    ON log_action (user_id, created_at DESC)
    WHERE del_flag = FALSE;
