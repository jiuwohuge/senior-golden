-- 时光邮局：独立数据域 bu_time_letter
CREATE TABLE bu_time_letter (
    id                      BIGSERIAL PRIMARY KEY,
    sender_id               BIGINT NOT NULL,
    recipient_id            BIGINT,
    recipient_type          SMALLINT NOT NULL,
    body                    TEXT NOT NULL DEFAULT '',
    content_tag             VARCHAR(32),
    emotion_tag             VARCHAR(32),
    paper_theme             VARCHAR(32),
    paper_color             VARCHAR(16),
    delivery_date           DATE NOT NULL,
    delivery_tz             VARCHAR(64) NOT NULL,
    status                  SMALLINT NOT NULL,
    sealed_at               TIMESTAMPTZ,
    delivered_at            TIMESTAMPTZ,
    read_at                 TIMESTAMPTZ,
    cancel_deadline_at      TIMESTAMPTZ,
    cancelled_at            TIMESTAMPTZ,
    stamp_cost              INT NOT NULL DEFAULT 0,
    sender_snapshot_json    JSONB,
    writer_city             VARCHAR(128),
    write_duration_sec      INT,
    privacy_level           SMALLINT NOT NULL DEFAULT 1,
    star_flag               BOOLEAN NOT NULL DEFAULT FALSE,
    reply_to_id             BIGINT,
    seal_request_id         VARCHAR(64),
    fail_reason             VARCHAR(256),
    takedown_reason         VARCHAR(256),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by              BIGINT,
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by              BIGINT,
    del_flag                BOOLEAN NOT NULL DEFAULT FALSE
);

COMMENT ON TABLE bu_time_letter IS '时光邮局信件';
COMMENT ON COLUMN bu_time_letter.recipient_id IS 'NULL=写给自己';
COMMENT ON COLUMN bu_time_letter.recipient_type IS '1=SELF 2=FRIEND';
COMMENT ON COLUMN bu_time_letter.status IS '1=DRAFT 2=PENDING 3=DELIVERED 4=READ 5=CANCELLED 6=FAILED';

CREATE INDEX idx_bu_time_letter_delivery_due
    ON bu_time_letter (delivery_date ASC, delivery_tz)
    WHERE del_flag = FALSE AND status = 2;

CREATE INDEX idx_bu_time_letter_sender_outbox
    ON bu_time_letter (sender_id, status, created_at DESC)
    WHERE del_flag = FALSE;

CREATE INDEX idx_bu_time_letter_recipient_inbox
    ON bu_time_letter (recipient_id, status, delivered_at DESC)
    WHERE del_flag = FALSE AND recipient_id IS NOT NULL;

CREATE UNIQUE INDEX idx_bu_time_letter_seal_request
    ON bu_time_letter (sender_id, seal_request_id)
    WHERE del_flag = FALSE AND seal_request_id IS NOT NULL;

CREATE UNIQUE INDEX idx_bu_time_letter_same_day
    ON bu_time_letter (sender_id, COALESCE(recipient_id, sender_id), delivery_date)
    WHERE del_flag = FALSE AND status IN (2, 3);
