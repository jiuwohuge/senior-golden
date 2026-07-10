-- M5: commerce, entitlements, letter drafts/favorites, user preferences, push tokens, config seeds

CREATE TABLE bu_commerce_product (
    id              BIGSERIAL PRIMARY KEY,
    product_code    VARCHAR(64) NOT NULL,
    product_type    VARCHAR(32) NOT NULL,
    title_key       VARCHAR(128) NOT NULL,
    price_cents     INT NOT NULL DEFAULT 0,
    metadata_json   JSONB,
    sort_order      INT NOT NULL DEFAULT 0,
    status          SMALLINT NOT NULL DEFAULT 1,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by      BIGINT,
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
COMMENT ON TABLE bu_commerce_product IS '商业商品：skin|template|font|attachment|vip_bundle|export';
CREATE UNIQUE INDEX ux_bu_commerce_product_code ON bu_commerce_product (product_code) WHERE del_flag = FALSE;

CREATE TABLE bu_user_entitlement (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    product_id      BIGINT NOT NULL,
    source          VARCHAR(32) NOT NULL DEFAULT 'admin_grant',
    expires_at      TIMESTAMP,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by      BIGINT,
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
COMMENT ON TABLE bu_user_entitlement IS '用户权益；source=admin_grant|mock_purchase';
CREATE UNIQUE INDEX ux_bu_user_entitlement_user_product
    ON bu_user_entitlement (user_id, product_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_user_entitlement_user ON bu_user_entitlement (user_id) WHERE del_flag = FALSE;

CREATE TABLE bu_letter_draft (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    mode            VARCHAR(32) NOT NULL DEFAULT 'DIRECT',
    to_user_id      BIGINT,
    content_json    JSONB NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by      BIGINT,
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
COMMENT ON TABLE bu_letter_draft IS '普通信件草稿（未发送）';
CREATE INDEX idx_bu_letter_draft_user ON bu_letter_draft (user_id, updated_at DESC) WHERE del_flag = FALSE;

CREATE TABLE bu_letter_favorite (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    letter_id       BIGINT NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by      BIGINT,
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
COMMENT ON TABLE bu_letter_favorite IS '往来信件收藏';
CREATE UNIQUE INDEX ux_bu_letter_favorite_user_letter
    ON bu_letter_favorite (user_id, letter_id) WHERE del_flag = FALSE;

CREATE TABLE bu_user_preference (
    id                  BIGSERIAL PRIMARY KEY,
    user_id             BIGINT NOT NULL,
    privacy_json        JSONB NOT NULL DEFAULT '{}',
    notifications_json  JSONB NOT NULL DEFAULT '{}',
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by          BIGINT,
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by          BIGINT,
    del_flag            BOOLEAN NOT NULL DEFAULT FALSE
);
COMMENT ON TABLE bu_user_preference IS '用户隐私与通知偏好';
CREATE UNIQUE INDEX ux_bu_user_preference_user ON bu_user_preference (user_id) WHERE del_flag = FALSE;

ALTER TABLE bu_user_device ADD COLUMN IF NOT EXISTS push_token VARCHAR(512);
ALTER TABLE bu_user_device ADD COLUMN IF NOT EXISTS push_platform VARCHAR(16);
ALTER TABLE bu_user_device ADD COLUMN IF NOT EXISTS push_enabled BOOLEAN NOT NULL DEFAULT TRUE;

INSERT INTO bu_commerce_product (product_code, product_type, title_key, price_cents, metadata_json, sort_order, status, created_at, updated_at, created_by, updated_by, del_flag)
VALUES
('skin.default', 'skin', 'commerce.product.skin.default', 0, '{"skinId":"default"}', 0, 1, NOW(), NOW(), 0, 0, FALSE),
('skin.vintage', 'skin', 'commerce.product.skin.vintage', 990, '{"skinId":"vintage","previewColor":"#F5E6C8"}', 10, 1, NOW(), NOW(), 0, 0, FALSE),
('font.default', 'font', 'commerce.product.font.default', 0, '{"fontId":"default"}', 0, 1, NOW(), NOW(), 0, 0, FALSE),
('font.handwriting', 'font', 'commerce.product.font.handwriting', 690, '{"fontId":"handwriting"}', 10, 1, NOW(), NOW(), 0, 0, FALSE),
('export.pdf', 'export', 'commerce.product.export.pdf', 1990, '{"format":"pdf"}', 20, 1, NOW(), NOW(), 0, 0, FALSE);

INSERT INTO sys_config (config_key, config_value, config_group, description, created_at, updated_at, created_by, updated_by, del_flag)
VALUES
('match.score.emotion', '0.30', 'match', '匹配权重：情绪', NOW(), NOW(), 0, 0, FALSE),
('match.score.interest', '0.20', 'match', '匹配权重：兴趣', NOW(), NOW(), 0, 0, FALSE),
('match.score.style', '0.15', 'match', '匹配权重：表达风格', NOW(), NOW(), 0, 0, FALSE),
('match.score.time', '0.10', 'match', '匹配权重：时间', NOW(), NOW(), 0, 0, FALSE),
('match.score.geo', '0.10', 'match', '匹配权重：地理/语言', NOW(), NOW(), 0, 0, FALSE),
('match.score.freshness', '0.10', 'match', '匹配权重：新鲜度', NOW(), NOW(), 0, 0, FALSE),
('match.score.explore', '0.05', 'match', '匹配权重：随机探索', NOW(), NOW(), 0, 0, FALSE),
('match.distribution.high', '0.60', 'match', '高匹配分发比例', NOW(), NOW(), 0, 0, FALSE),
('match.distribution.mid', '0.30', 'match', '中匹配分发比例', NOW(), NOW(), 0, 0, FALSE),
('match.distribution.explore', '0.10', 'match', '探索分发比例', NOW(), NOW(), 0, 0, FALSE),
('match.active_hours', '72', 'match', '活跃判定窗口（小时）', NOW(), NOW(), 0, 0, FALSE),
('match.ai.emotion_enabled', 'false', 'match', 'DeepSeek 情绪特征开关', NOW(), NOW(), 0, 0, FALSE),
('match.ai.style_enabled', 'false', 'match', 'DeepSeek 风格特征开关', NOW(), NOW(), 0, 0, FALSE),
('letter.max_length', '5000', 'letter', '正文长度上限', NOW(), NOW(), 0, 0, FALSE),
('letter.max_images', '3', 'letter', '图片附件张数上限', NOW(), NOW(), 0, 0, FALSE),
('time_letter.free_capacity', '3', 'time_letter', '时光信免费容量', NOW(), NOW(), 0, 0, FALSE),
('favorite.free_limit', '20', 'letter', '免费收藏上限', NOW(), NOW(), 0, 0, FALSE),
('favorite.vip_limit', '200', 'letter', 'VIP 收藏上限', NOW(), NOW(), 0, 0, FALSE)
ON CONFLICT (config_key) DO UPDATE SET
    config_value = EXCLUDED.config_value,
    config_group = EXCLUDED.config_group,
    description  = EXCLUDED.description,
    del_flag     = FALSE,
    updated_at   = NOW(),
    updated_by   = 0;
