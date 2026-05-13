-- FP-X-001：异步邮件投递，支持失败重试（与忘记密码等串联）
CREATE TABLE sys_mail_outbox (
    id              BIGSERIAL PRIMARY KEY,
    mail_type       VARCHAR(64)  NOT NULL,
    to_email        VARCHAR(320) NOT NULL,
    payload_json    TEXT         NOT NULL,
    locale_tag      VARCHAR(32),
    status          VARCHAR(20)  NOT NULL DEFAULT 'pending',
    attempts        INT          NOT NULL DEFAULT 0,
    next_retry_at   TIMESTAMP    NOT NULL DEFAULT NOW(),
    last_error      TEXT,
    created_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sys_mail_outbox_poll ON sys_mail_outbox (status, next_retry_at, id)
    WHERE status = 'pending';

COMMENT ON TABLE sys_mail_outbox IS '邮件发件箱（Outbox），异步重试';
COMMENT ON COLUMN sys_mail_outbox.mail_type IS '业务类型，如 PASSWORD_RESET';
COMMENT ON COLUMN sys_mail_outbox.payload_json IS 'JSON 载荷，由 mail_type 解析';
COMMENT ON COLUMN sys_mail_outbox.locale_tag IS 'BCP47 语言标签，用于模板渲染';
COMMENT ON COLUMN sys_mail_outbox.status IS 'pending / sent / failed';
