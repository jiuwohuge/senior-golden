-- Payment common tables + Plus product/channel seed (PLAN §8.3 / §2).
-- product_type on bu_commerce_product now also supports subscription|one_time
-- (existing skin/font/template/etc values remain valid).

-- ---------------------------------------------------------------------------
-- ALTER bu_commerce_product
-- ---------------------------------------------------------------------------
ALTER TABLE bu_commerce_product
    ADD COLUMN IF NOT EXISTS entitlement_code VARCHAR(64),
    ADD COLUMN IF NOT EXISTS description_key VARCHAR(128);

COMMENT ON COLUMN bu_commerce_product.entitlement_code IS '权益编码，如 plus；订阅商品关联授权码';
COMMENT ON COLUMN bu_commerce_product.description_key IS '描述 i18n key';
COMMENT ON COLUMN bu_commerce_product.product_type IS 'skin|template|font|attachment|vip_bundle|export|subscription|one_time';

-- ---------------------------------------------------------------------------
-- bu_commerce_product_channel
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS bu_commerce_product_channel (
    id                      BIGSERIAL PRIMARY KEY,
    product_id              BIGINT NOT NULL,
    provider                VARCHAR(32) NOT NULL,
    store_product_id        VARCHAR(128) NOT NULL,
    base_plan_id            VARCHAR(128),
    offer_id                VARCHAR(128),
    app_id_or_package_name  VARCHAR(128),
    environment             VARCHAR(32) NOT NULL DEFAULT 'sandbox',
    status                  SMALLINT NOT NULL DEFAULT 1,
    provider_config_json    JSONB,
    created_at              TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by              BIGINT,
    updated_at              TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by              BIGINT,
    del_flag                BOOLEAN NOT NULL DEFAULT FALSE
);

COMMENT ON TABLE bu_commerce_product_channel IS '商品渠道映射：google_play|apple_app_store|mock × store_product_id';
COMMENT ON COLUMN bu_commerce_product_channel.provider IS 'google_play|apple_app_store|mock';

CREATE UNIQUE INDEX IF NOT EXISTS uk_bu_commerce_product_channel_provider_store_env
    ON bu_commerce_product_channel (provider, store_product_id, environment)
    WHERE del_flag = FALSE;

CREATE INDEX IF NOT EXISTS idx_bu_commerce_product_channel_product_id
    ON bu_commerce_product_channel (product_id)
    WHERE del_flag = FALSE;

-- ---------------------------------------------------------------------------
-- bu_payment_purchase
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS bu_payment_purchase (
    id                      BIGSERIAL PRIMARY KEY,
    purchase_no             VARCHAR(64) NOT NULL,
    user_id                 BIGINT NOT NULL,
    product_id              BIGINT NOT NULL,
    provider                VARCHAR(32) NOT NULL,
    store_product_id        VARCHAR(128),
    purchase_token_hash     VARCHAR(64) NOT NULL,
    -- prod must use vault/AES; non-prod mock may store base64 of token
    purchase_token_cipher   TEXT,
    purchase_token_preview  VARCHAR(32),
    external_order_id       VARCHAR(128),
    status                  VARCHAR(32) NOT NULL,
    purchased_at            TIMESTAMP,
    paid_at                 TIMESTAMP,
    environment             VARCHAR(32),
    channel_snapshot_json   JSONB,
    created_at              TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by              BIGINT,
    updated_at              TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by              BIGINT,
    del_flag                BOOLEAN NOT NULL DEFAULT FALSE
);

COMMENT ON TABLE bu_payment_purchase IS '支付购买主单；status=pending|purchased|canceled|refunded|revoked';
COMMENT ON COLUMN bu_payment_purchase.purchase_token_cipher IS '可选密文；生产必须 vault/AES，勿明文落库';
COMMENT ON COLUMN bu_payment_purchase.status IS 'pending|purchased|canceled|refunded|revoked';

CREATE UNIQUE INDEX IF NOT EXISTS uk_bu_payment_purchase_token_hash
    ON bu_payment_purchase (purchase_token_hash)
    WHERE del_flag = FALSE;

CREATE UNIQUE INDEX IF NOT EXISTS uk_bu_payment_purchase_no
    ON bu_payment_purchase (purchase_no)
    WHERE del_flag = FALSE;

CREATE INDEX IF NOT EXISTS idx_bu_payment_purchase_user_id
    ON bu_payment_purchase (user_id)
    WHERE del_flag = FALSE;

-- ---------------------------------------------------------------------------
-- bu_payment_transaction
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS bu_payment_transaction (
    id                  BIGSERIAL PRIMARY KEY,
    purchase_id         BIGINT NOT NULL,
    user_id             BIGINT NOT NULL,
    tx_type             VARCHAR(32) NOT NULL,
    amount_cents        INT,
    currency            VARCHAR(8),
    provider_tx_id      VARCHAR(128),
    occurred_at         TIMESTAMP NOT NULL,
    raw_snapshot_json   JSONB,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by          BIGINT,
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by          BIGINT,
    del_flag            BOOLEAN NOT NULL DEFAULT FALSE
);

COMMENT ON TABLE bu_payment_transaction IS '支付流水；tx_type=initial_purchase|renewal|refund|chargeback|revocation';
COMMENT ON COLUMN bu_payment_transaction.tx_type IS 'initial_purchase|renewal|refund|chargeback|revocation';

CREATE INDEX IF NOT EXISTS idx_bu_payment_transaction_purchase_id
    ON bu_payment_transaction (purchase_id)
    WHERE del_flag = FALSE;

-- ---------------------------------------------------------------------------
-- bu_subscription (canonical payment subscription; distinct from bu_vip_subscription)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS bu_subscription (
    id                          BIGSERIAL PRIMARY KEY,
    user_id                     BIGINT NOT NULL,
    product_id                  BIGINT,
    purchase_id                 BIGINT,
    provider                    VARCHAR(32),
    status                      VARCHAR(32) NOT NULL,
    current_period_start        TIMESTAMP,
    current_period_end          TIMESTAMP,
    auto_renew                  BOOLEAN NOT NULL DEFAULT TRUE,
    purchase_token_hash         VARCHAR(64),
    linked_purchase_token_hash  VARCHAR(64),
    cancel_reason               VARCHAR(128),
    last_synced_at              TIMESTAMP,
    is_trial                    BOOLEAN DEFAULT FALSE,
    store_product_id            VARCHAR(128),
    created_at                  TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by                  BIGINT,
    updated_at                  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by                  BIGINT,
    del_flag                    BOOLEAN NOT NULL DEFAULT FALSE
);

COMMENT ON TABLE bu_subscription IS '支付订阅权威行；status=pending|active|grace_period|on_hold|paused|canceled|expired|revoked';
COMMENT ON COLUMN bu_subscription.status IS 'pending|active|grace_period|on_hold|paused|canceled|expired|revoked';

CREATE INDEX IF NOT EXISTS idx_bu_subscription_user_id
    ON bu_subscription (user_id)
    WHERE del_flag = FALSE;

CREATE INDEX IF NOT EXISTS idx_bu_subscription_token_hash
    ON bu_subscription (purchase_token_hash)
    WHERE del_flag = FALSE AND purchase_token_hash IS NOT NULL;

-- ---------------------------------------------------------------------------
-- ALTER bu_user_entitlement
-- ---------------------------------------------------------------------------
ALTER TABLE bu_user_entitlement
    ADD COLUMN IF NOT EXISTS entitlement_code VARCHAR(64),
    ADD COLUMN IF NOT EXISTS purchase_id BIGINT,
    ADD COLUMN IF NOT EXISTS subscription_id BIGINT,
    ADD COLUMN IF NOT EXISTS effective_at TIMESTAMP,
    ADD COLUMN IF NOT EXISTS revoked_at TIMESTAMP,
    ADD COLUMN IF NOT EXISTS status VARCHAR(32) DEFAULT 'active';

COMMENT ON COLUMN bu_user_entitlement.status IS 'active|revoked|expired';

CREATE INDEX IF NOT EXISTS idx_bu_user_entitlement_user_code
    ON bu_user_entitlement (user_id, entitlement_code)
    WHERE del_flag = FALSE;

-- ---------------------------------------------------------------------------
-- bu_payment_webhook_event
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS bu_payment_webhook_event (
    id                          BIGSERIAL PRIMARY KEY,
    provider                    VARCHAR(32) NOT NULL,
    event_id_or_message_id      VARCHAR(128) NOT NULL,
    event_type                  VARCHAR(64),
    payload_json                JSONB,
    process_status              VARCHAR(32) NOT NULL DEFAULT 'received',
    retry_count                 INT DEFAULT 0,
    error_message               TEXT,
    received_at                 TIMESTAMP NOT NULL DEFAULT NOW(),
    processed_at                TIMESTAMP,
    created_at                  TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by                  BIGINT,
    updated_at                  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by                  BIGINT,
    del_flag                    BOOLEAN NOT NULL DEFAULT FALSE
);

COMMENT ON TABLE bu_payment_webhook_event IS '支付 webhook 幂等事件；process_status=received|processed|failed';
COMMENT ON COLUMN bu_payment_webhook_event.process_status IS 'received|processed|failed';

CREATE UNIQUE INDEX IF NOT EXISTS uk_bu_payment_webhook_event_provider_event
    ON bu_payment_webhook_event (provider, event_id_or_message_id)
    WHERE del_flag = FALSE;

-- ---------------------------------------------------------------------------
-- Seed Plus products
-- ---------------------------------------------------------------------------
INSERT INTO bu_commerce_product (
    product_code, product_type, entitlement_code, title_key, description_key,
    price_cents, metadata_json, sort_order, status,
    created_at, updated_at, created_by, updated_by, del_flag
)
SELECT 'plus_monthly', 'subscription', 'plus', 'commerce.product.plus.monthly',
       'commerce.product.plus.monthly.desc', 990, NULL, 10, 1,
       NOW(), NOW(), 0, 0, FALSE
WHERE NOT EXISTS (
    SELECT 1 FROM bu_commerce_product WHERE product_code = 'plus_monthly' AND del_flag = FALSE
);

INSERT INTO bu_commerce_product (
    product_code, product_type, entitlement_code, title_key, description_key,
    price_cents, metadata_json, sort_order, status,
    created_at, updated_at, created_by, updated_by, del_flag
)
SELECT 'plus_yearly', 'subscription', 'plus', 'commerce.product.plus.yearly',
       'commerce.product.plus.yearly.desc', 6900, NULL, 20, 1,
       NOW(), NOW(), 0, 0, FALSE
WHERE NOT EXISTS (
    SELECT 1 FROM bu_commerce_product WHERE product_code = 'plus_yearly' AND del_flag = FALSE
);

UPDATE bu_commerce_product
SET entitlement_code = 'plus',
    product_type = 'subscription',
    title_key = COALESCE(NULLIF(title_key, ''), 'commerce.product.plus.monthly'),
    description_key = COALESCE(description_key, 'commerce.product.plus.monthly.desc'),
    price_cents = COALESCE(NULLIF(price_cents, 0), 990),
    updated_at = NOW(),
    updated_by = 0
WHERE product_code = 'plus_monthly' AND del_flag = FALSE;

UPDATE bu_commerce_product
SET entitlement_code = 'plus',
    product_type = 'subscription',
    title_key = COALESCE(NULLIF(title_key, ''), 'commerce.product.plus.yearly'),
    description_key = COALESCE(description_key, 'commerce.product.plus.yearly.desc'),
    price_cents = COALESCE(NULLIF(price_cents, 0), 6900),
    updated_at = NOW(),
    updated_by = 0
WHERE product_code = 'plus_yearly' AND del_flag = FALSE;

-- google_play sandbox channels
INSERT INTO bu_commerce_product_channel (
    product_id, provider, store_product_id, app_id_or_package_name, environment,
    status, created_at, updated_at, created_by, updated_by, del_flag
)
SELECT p.id, 'google_play', 'plus_monthly', 'cn.nine.pros.seniorpost', 'sandbox',
       1, NOW(), NOW(), 0, 0, FALSE
FROM bu_commerce_product p
WHERE p.product_code = 'plus_monthly' AND p.del_flag = FALSE
  AND NOT EXISTS (
      SELECT 1 FROM bu_commerce_product_channel c
      WHERE c.provider = 'google_play' AND c.store_product_id = 'plus_monthly'
        AND c.environment = 'sandbox' AND c.del_flag = FALSE
  );

INSERT INTO bu_commerce_product_channel (
    product_id, provider, store_product_id, app_id_or_package_name, environment,
    status, created_at, updated_at, created_by, updated_by, del_flag
)
SELECT p.id, 'google_play', 'plus_yearly', 'cn.nine.pros.seniorpost', 'sandbox',
       1, NOW(), NOW(), 0, 0, FALSE
FROM bu_commerce_product p
WHERE p.product_code = 'plus_yearly' AND p.del_flag = FALSE
  AND NOT EXISTS (
      SELECT 1 FROM bu_commerce_product_channel c
      WHERE c.provider = 'google_play' AND c.store_product_id = 'plus_yearly'
        AND c.environment = 'sandbox' AND c.del_flag = FALSE
  );

-- mock provider channels (local QA)
INSERT INTO bu_commerce_product_channel (
    product_id, provider, store_product_id, app_id_or_package_name, environment,
    status, created_at, updated_at, created_by, updated_by, del_flag
)
SELECT p.id, 'mock', 'plus_monthly', 'cn.nine.pros.seniorpost', 'sandbox',
       1, NOW(), NOW(), 0, 0, FALSE
FROM bu_commerce_product p
WHERE p.product_code = 'plus_monthly' AND p.del_flag = FALSE
  AND NOT EXISTS (
      SELECT 1 FROM bu_commerce_product_channel c
      WHERE c.provider = 'mock' AND c.store_product_id = 'plus_monthly'
        AND c.environment = 'sandbox' AND c.del_flag = FALSE
  );

INSERT INTO bu_commerce_product_channel (
    product_id, provider, store_product_id, app_id_or_package_name, environment,
    status, created_at, updated_at, created_by, updated_by, del_flag
)
SELECT p.id, 'mock', 'plus_yearly', 'cn.nine.pros.seniorpost', 'sandbox',
       1, NOW(), NOW(), 0, 0, FALSE
FROM bu_commerce_product p
WHERE p.product_code = 'plus_yearly' AND p.del_flag = FALSE
  AND NOT EXISTS (
      SELECT 1 FROM bu_commerce_product_channel c
      WHERE c.provider = 'mock' AND c.store_product_id = 'plus_yearly'
        AND c.environment = 'sandbox' AND c.del_flag = FALSE
  );
