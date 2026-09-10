-- Plus / Play Billing v1: subscription purchase metadata + AI weekly usage.

ALTER TABLE bu_vip_subscription
    ADD COLUMN IF NOT EXISTS product_id VARCHAR(64),
    ADD COLUMN IF NOT EXISTS purchase_token VARCHAR(512),
    ADD COLUMN IF NOT EXISTS order_id VARCHAR(128),
    ADD COLUMN IF NOT EXISTS package_name VARCHAR(128),
    ADD COLUMN IF NOT EXISTS is_trial BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS source VARCHAR(32) DEFAULT 'unknown',
    ADD COLUMN IF NOT EXISTS acknowledged_at TIMESTAMP;

CREATE UNIQUE INDEX IF NOT EXISTS uk_bu_vip_subscription_purchase_token
    ON bu_vip_subscription (purchase_token)
    WHERE purchase_token IS NOT NULL AND del_flag = FALSE;

CREATE TABLE IF NOT EXISTS bu_ai_assist_usage (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    week_start      DATE NOT NULL,
    use_count       INT NOT NULL DEFAULT 0,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by      BIGINT,
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE UNIQUE INDEX IF NOT EXISTS uk_bu_ai_assist_usage_user_week
    ON bu_ai_assist_usage (user_id, week_start)
    WHERE del_flag = FALSE;

CREATE INDEX IF NOT EXISTS idx_bu_ai_assist_usage_user_id
    ON bu_ai_assist_usage (user_id)
    WHERE del_flag = FALSE;

INSERT INTO sys_config (config_key, config_value, config_group, description, created_at, updated_at, created_by, updated_by, del_flag)
VALUES
('plus.ai.free_weekly_quota', '3', 'plus', '非订阅 AI 助手每周免费次数', NOW(), NOW(), 0, 0, FALSE),
('plus.ai.subscriber_weekly_quota', '100', 'plus', '订阅/试用 AI 助手每周配额', NOW(), NOW(), 0, 0, FALSE),
('plus.in_transit.recall_window_minutes', '20', 'plus', '在途撤回/改信窗口（分钟）', NOW(), NOW(), 0, 0, FALSE)
ON CONFLICT (config_key) DO UPDATE SET
    config_value = EXCLUDED.config_value,
    config_group = EXCLUDED.config_group,
    description  = EXCLUDED.description,
    del_flag     = FALSE,
    updated_at   = NOW(),
    updated_by   = 0;
