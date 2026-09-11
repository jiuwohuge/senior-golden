-- FCM Notification Outbox + push endpoints (PLAN §8 item 7 / §4).
-- Payment/subscription/billing push is forbidden at enqueue layer; letter events only.

-- ---------------------------------------------------------------------------
-- bu_push_endpoint
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS bu_push_endpoint (
    id                          BIGSERIAL PRIMARY KEY,
    user_id                     BIGINT NOT NULL,
    device_uuid                 VARCHAR(128) NOT NULL,
    platform                    VARCHAR(16) NOT NULL,
    push_token                  VARCHAR(512) NOT NULL,
    firebase_installation_id    VARCHAR(128),
    app_version                 VARCHAR(64),
    locale                      VARCHAR(32),
    notification_permission     VARCHAR(16) NOT NULL DEFAULT 'unknown',
    enabled                     BOOLEAN NOT NULL DEFAULT TRUE,
    last_seen_at                TIMESTAMP,
    invalidated_at              TIMESTAMP,
    invalid_reason              VARCHAR(256),
    created_at                  TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by                  BIGINT,
    updated_at                  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by                  BIGINT,
    del_flag                    BOOLEAN NOT NULL DEFAULT FALSE
);

COMMENT ON TABLE bu_push_endpoint IS 'FCM/APNs 推送端点；与 bu_user_device 并存，供 Outbox 派发';
COMMENT ON COLUMN bu_push_endpoint.platform IS 'ios|android';
COMMENT ON COLUMN bu_push_endpoint.notification_permission IS 'granted|denied|unknown';

CREATE UNIQUE INDEX IF NOT EXISTS uk_bu_push_endpoint_user_device
    ON bu_push_endpoint (user_id, device_uuid)
    WHERE del_flag = FALSE;

CREATE UNIQUE INDEX IF NOT EXISTS uk_bu_push_endpoint_user_token
    ON bu_push_endpoint (user_id, push_token)
    WHERE del_flag = FALSE;

CREATE INDEX IF NOT EXISTS idx_bu_push_endpoint_user_enabled
    ON bu_push_endpoint (user_id, enabled)
    WHERE del_flag = FALSE;

-- ---------------------------------------------------------------------------
-- bu_notification_outbox
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS bu_notification_outbox (
    id                  BIGSERIAL PRIMARY KEY,
    event_type          VARCHAR(64) NOT NULL,
    recipient_user_id   BIGINT NOT NULL,
    template_key        VARCHAR(64),
    title               VARCHAR(256) NOT NULL,
    body                VARCHAR(1024) NOT NULL,
    payload_json        JSONB,
    dedupe_key          VARCHAR(256) NOT NULL,
    status              VARCHAR(32) NOT NULL DEFAULT 'pending',
    attempts            INT NOT NULL DEFAULT 0,
    next_retry_at       TIMESTAMP,
    last_error          VARCHAR(2000),
    scheduled_at        TIMESTAMP NOT NULL DEFAULT NOW(),
    processed_at        TIMESTAMP,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by          BIGINT,
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by          BIGINT,
    del_flag            BOOLEAN NOT NULL DEFAULT FALSE
);

COMMENT ON TABLE bu_notification_outbox IS '推送通知 Outbox；仅信件事件，禁止支付类 event_type';
COMMENT ON COLUMN bu_notification_outbox.event_type IS 'letter_matched_in_transit|letter_arrived';
COMMENT ON COLUMN bu_notification_outbox.status IS 'pending|processing|sent|failed|cancelled';

CREATE UNIQUE INDEX IF NOT EXISTS uk_bu_notification_outbox_dedupe
    ON bu_notification_outbox (dedupe_key)
    WHERE del_flag = FALSE;

CREATE INDEX IF NOT EXISTS idx_bu_notification_outbox_status_retry
    ON bu_notification_outbox (status, next_retry_at, id)
    WHERE del_flag = FALSE;

CREATE INDEX IF NOT EXISTS idx_bu_notification_outbox_recipient
    ON bu_notification_outbox (recipient_user_id)
    WHERE del_flag = FALSE;

-- ---------------------------------------------------------------------------
-- bu_notification_delivery
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS bu_notification_delivery (
    id                  BIGSERIAL PRIMARY KEY,
    outbox_id           BIGINT NOT NULL,
    endpoint_id         BIGINT,
    user_id             BIGINT NOT NULL,
    fcm_message_id      VARCHAR(256),
    send_status         VARCHAR(32) NOT NULL,
    error_message       VARCHAR(2000),
    provider            VARCHAR(16) NOT NULL,
    sent_at             TIMESTAMP,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by          BIGINT,
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by          BIGINT,
    del_flag            BOOLEAN NOT NULL DEFAULT FALSE
);

COMMENT ON TABLE bu_notification_delivery IS 'Outbox 按端点投递结果';
COMMENT ON COLUMN bu_notification_delivery.send_status IS 'mock_sent|sent|failed|skipped';
COMMENT ON COLUMN bu_notification_delivery.provider IS 'mock|fcm';

CREATE UNIQUE INDEX IF NOT EXISTS uk_bu_notification_delivery_outbox_endpoint
    ON bu_notification_delivery (outbox_id, endpoint_id)
    WHERE del_flag = FALSE AND endpoint_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_bu_notification_delivery_outbox
    ON bu_notification_delivery (outbox_id)
    WHERE del_flag = FALSE;

CREATE INDEX IF NOT EXISTS idx_bu_notification_delivery_user
    ON bu_notification_delivery (user_id)
    WHERE del_flag = FALSE;
