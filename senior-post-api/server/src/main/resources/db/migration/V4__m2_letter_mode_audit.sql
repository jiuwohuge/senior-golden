-- M2: letter mode / audit_status / nullable recipient / matched_at
ALTER TABLE bu_letter
    ALTER COLUMN to_user_id DROP NOT NULL;

ALTER TABLE bu_letter
    ADD COLUMN IF NOT EXISTS mode SMALLINT NOT NULL DEFAULT 2,
    ADD COLUMN IF NOT EXISTS audit_status SMALLINT NOT NULL DEFAULT 1,
    ADD COLUMN IF NOT EXISTS matched_at TIMESTAMP;

COMMENT ON COLUMN bu_letter.mode IS '1=POST_OFFICE 2=DIRECT 3=SELF_TIME(预留，时光信仍走 bu_time_letter)';
COMMENT ON COLUMN bu_letter.audit_status IS '0=PENDING_REVIEW 1=APPROVED 2=REJECTED';
COMMENT ON COLUMN bu_letter.status IS '0=PENDING 1=DELIVERING 2=DELIVERED 3=REGISTERED(预留) 4=MATCHED';
COMMENT ON COLUMN bu_letter.matched_at IS 'POST_OFFICE 匹配成功时间（M3）';
COMMENT ON COLUMN bu_letter.to_user_id IS '收件人；POST_OFFICE 入池时可空';

UPDATE bu_letter SET mode = 2 WHERE mode IS NULL;
UPDATE bu_letter SET audit_status = 1 WHERE audit_status IS NULL;

CREATE INDEX IF NOT EXISTS idx_bu_letter_mode_status
    ON bu_letter (mode, status)
    WHERE del_flag = FALSE;

CREATE INDEX IF NOT EXISTS idx_bu_letter_pool_pending
    ON bu_letter (created_at ASC)
    WHERE del_flag = FALSE AND mode = 1 AND status = 0 AND to_user_id IS NULL;

-- 投递延迟配置（小时）
INSERT INTO sys_config (config_key, config_value, config_group, description, created_at, updated_at, created_by, updated_by, del_flag)
VALUES
('delivery.delay_base_hours', '6', 'delivery', '§6.1 基础延迟（小时）', NOW(), NOW(), 0, 0, FALSE),
('delivery.delay_min_hours', '2', 'delivery', '§6.1 延迟下限（小时）', NOW(), NOW(), 0, 0, FALSE),
('delivery.delay_max_hours', '48', 'delivery', '§6.1 延迟上限（小时，默认 2 天）', NOW(), NOW(), 0, 0, FALSE),
('delivery.distance_max_km', '20000', 'delivery', '距离权重归一化上限（公里）', NOW(), NOW(), 0, 0, FALSE)
ON CONFLICT (config_key) DO UPDATE SET
    config_value = EXCLUDED.config_value,
    config_group = EXCLUDED.config_group,
    description  = EXCLUDED.description,
    del_flag     = FALSE,
    updated_at   = NOW(),
    updated_by   = 0;
