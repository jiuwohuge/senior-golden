-- =============================================================================
-- Senior Post 4.0 baseline schema (M0 Flyway reset)
-- 不含：明信片 / 邮票 / 示例(Example/Food) 相关表
-- =============================================================================

-- 一、系统配置表（sys_ 前缀）

CREATE TABLE sys_tag (
    id              SERIAL PRIMARY KEY,
    tag_name        VARCHAR(50) NOT NULL,
    lang_code       VARCHAR(10) NOT NULL DEFAULT 'en',
    sort_order      INT DEFAULT 0,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by      BIGINT,
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE(tag_name, lang_code)
);
CREATE INDEX idx_sys_tag_lang ON sys_tag(lang_code) WHERE del_flag = FALSE;
CREATE INDEX idx_sys_tag_sort_order ON sys_tag(sort_order) WHERE del_flag = FALSE;

CREATE TABLE sys_sensitive_word (
    id              SERIAL PRIMARY KEY,
    word            VARCHAR(100) NOT NULL,
    type            VARCHAR(20),
    type_text       VARCHAR(50),
    lang_code       VARCHAR(10) NOT NULL DEFAULT 'en',
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by      BIGINT,
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE(word, lang_code)
);
CREATE INDEX idx_sys_sensitive_word_lang ON sys_sensitive_word(lang_code) WHERE del_flag = FALSE;
CREATE INDEX idx_sys_sensitive_word_type ON sys_sensitive_word(type) WHERE del_flag = FALSE;

CREATE TABLE sys_config (
    id              SERIAL PRIMARY KEY,
    config_key      VARCHAR(100) NOT NULL UNIQUE,
    config_value    TEXT,
    config_group    VARCHAR(50) NOT NULL,
    description     VARCHAR(255),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by      BIGINT,
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_sys_config_group ON sys_config(config_group) WHERE del_flag = FALSE;

CREATE TABLE sys_announcement (
    id                  SERIAL PRIMARY KEY,
    title               VARCHAR(200),
    title_json          JSONB,
    content             TEXT,
    content_json        JSONB,
    start_at            TIMESTAMP,
    end_at              TIMESTAMP,
    is_active           BOOLEAN DEFAULT TRUE,
    version_label       VARCHAR(64),
    min_version_code    INTEGER,
    max_version_code    INTEGER,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by          BIGINT,
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by          BIGINT,
    del_flag            BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_sys_announcement_active ON sys_announcement(is_active, start_at, end_at) WHERE del_flag = FALSE;

CREATE TABLE sys_app_version (
    id                          SERIAL PRIMARY KEY,
    app_platform                VARCHAR(20) NOT NULL,
    version_code                VARCHAR(50) NOT NULL,
    min_supported_version       VARCHAR(50),
    force_update                BOOLEAN DEFAULT FALSE,
    update_url                  TEXT,
    release_note                TEXT,
    created_at                  TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by                  BIGINT,
    updated_at                  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by                  BIGINT,
    del_flag                    BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE sys_country (
    id              SERIAL PRIMARY KEY,
    country_code    VARCHAR(10) NOT NULL UNIQUE,
    country_name_en VARCHAR(100),
    country_name_zh VARCHAR(100),
    sort_order      INT DEFAULT 0,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by      BIGINT,
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_sys_country_sort_order ON sys_country(sort_order) WHERE del_flag = FALSE;

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

-- 二、业务表（bu_ 前缀）

CREATE TABLE bu_user (
    id                      BIGSERIAL PRIMARY KEY,
    gender                  SMALLINT NOT NULL DEFAULT 0,
    nickname                VARCHAR(100) NOT NULL,
    birth_year              INT NOT NULL,
    country_code            VARCHAR(10),
    bio                     TEXT,
    avatar_url              TEXT,
    avatar_audit_status     SMALLINT NOT NULL DEFAULT 0,
    is_vip                  BOOLEAN DEFAULT FALSE,
    vip_expire_at           TIMESTAMP,
    status                  SMALLINT DEFAULT 1,
    staff_role              SMALLINT NOT NULL DEFAULT 0,
    register_ip             VARCHAR(64),
    last_login_at           TIMESTAMP,
    deletion_requested_at   TIMESTAMP,
    created_at              TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by              BIGINT,
    updated_at              TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by              BIGINT,
    del_flag                BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_bu_user_nickname ON bu_user(nickname) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_user_status ON bu_user(status) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_user_birth_year ON bu_user(birth_year);
CREATE INDEX idx_bu_user_avatar_audit_status ON bu_user (avatar_audit_status) WHERE del_flag = FALSE;
COMMENT ON COLUMN bu_user.gender IS '0未设置 1男 2女';
COMMENT ON COLUMN bu_user.avatar_audit_status IS '头像审核：0待审核 1通过 2驳回';
COMMENT ON COLUMN bu_user.status IS '状态：1正常 2封禁 3注销';
COMMENT ON COLUMN bu_user.staff_role IS '0 不可登录后台；非 0 可登录管理端';
COMMENT ON COLUMN bu_user.deletion_requested_at IS '用户申请注销时间；冷静期内再次登录可清空';

CREATE TABLE bu_user_identity (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES bu_user(id),
    provider        VARCHAR(16) NOT NULL,
    provider_uid    VARCHAR(255) NOT NULL,
    password_hash   VARCHAR(255),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by      BIGINT,
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT uk_bu_user_identity_provider_uid UNIQUE (provider, provider_uid)
);
CREATE INDEX idx_bu_user_identity_user ON bu_user_identity(user_id) WHERE del_flag = FALSE;
COMMENT ON COLUMN bu_user_identity.provider IS 'email | google | apple';
COMMENT ON COLUMN bu_user_identity.provider_uid IS '邮箱或 OAuth sub(openId)';

CREATE TABLE bu_user_device (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    device_uuid     VARCHAR(255) NOT NULL,
    device_type     VARCHAR(20),
    last_login_at   TIMESTAMP,
    status          SMALLINT DEFAULT 1,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by      BIGINT,
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_bu_user_device_user_id ON bu_user_device(user_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_user_device_uuid ON bu_user_device(device_uuid) WHERE del_flag = FALSE;

CREATE TABLE bu_user_tag (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    tag_id          INT NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by      BIGINT,
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE(user_id, tag_id)
);
CREATE INDEX idx_bu_user_tag_user_id ON bu_user_tag(user_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_user_tag_tag_id ON bu_user_tag(tag_id) WHERE del_flag = FALSE;

CREATE TABLE bu_letter (
    id                      BIGSERIAL PRIMARY KEY,
    from_user_id            BIGINT NOT NULL,
    to_user_id              BIGINT NOT NULL,
    letter_type             SMALLINT NOT NULL,
    send_mode               SMALLINT NOT NULL DEFAULT 1,
    status                  SMALLINT NOT NULL,
    content                 TEXT NOT NULL,
    is_accelerated          BOOLEAN DEFAULT FALSE,
    accelerated_at          TIMESTAMP,
    expected_arrival_time   TIMESTAMP,
    actual_arrival_time     TIMESTAMP,
    parent_letter_id        BIGINT,
    recipient_early_open_at TIMESTAMP,
    recipient_read_at       TIMESTAMP,
    created_at              TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by              BIGINT,
    updated_at              TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by              BIGINT,
    del_flag                BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_bu_letter_from_user ON bu_letter(from_user_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_letter_to_user ON bu_letter(to_user_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_letter_status ON bu_letter(status) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_letter_parent ON bu_letter(parent_letter_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_letter_standard_due
    ON bu_letter (expected_arrival_time ASC)
    WHERE del_flag = FALSE AND letter_type = 2 AND status = 1;
COMMENT ON COLUMN bu_letter.letter_type IS '类型：1挂号信（即时） 2平邮（慢信）';
COMMENT ON COLUMN bu_letter.send_mode IS '1=standard_post 2=registered_mail 3=direct_vip';
COMMENT ON COLUMN bu_letter.status IS '1=delivering 2=delivered 3=registered';
COMMENT ON COLUMN bu_letter.recipient_early_open_at IS '收件人提前拆信时间';
COMMENT ON COLUMN bu_letter.recipient_read_at IS '收件人首次已读时间';

CREATE TABLE bu_friendship (
    id               BIGSERIAL PRIMARY KEY,
    user_low         BIGINT NOT NULL,
    user_high        BIGINT NOT NULL,
    status           SMALLINT NOT NULL DEFAULT 1,
    source_letter_id BIGINT,
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by       BIGINT,
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by       BIGINT,
    del_flag         BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE UNIQUE INDEX ux_bu_friendship_pair ON bu_friendship (user_low, user_high) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_friendship_low ON bu_friendship (user_low) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_friendship_high ON bu_friendship (user_high) WHERE del_flag = FALSE;
COMMENT ON TABLE bu_friendship IS '笔友关系；user_low < user_high';

CREATE TABLE bu_vip_subscription (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    plan_id         VARCHAR(50),
    start_at        TIMESTAMP NOT NULL,
    end_at          TIMESTAMP NOT NULL,
    status          SMALLINT DEFAULT 1,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by      BIGINT,
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_bu_vip_subscription_user_id ON bu_vip_subscription(user_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_vip_subscription_end_at ON bu_vip_subscription(end_at) WHERE del_flag = FALSE;

CREATE TABLE bu_report (
    id              BIGSERIAL PRIMARY KEY,
    reporter_user_id BIGINT NOT NULL,
    target_type     VARCHAR(20) NOT NULL,
    target_id       BIGINT NOT NULL,
    reason          VARCHAR(255),
    status          SMALLINT DEFAULT 0,
    handler_user_id BIGINT,
    handle_note     TEXT,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by      BIGINT,
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_bu_report_reporter ON bu_report(reporter_user_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_report_target ON bu_report(target_type, target_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_report_status ON bu_report(status) WHERE del_flag = FALSE;
COMMENT ON COLUMN bu_report.target_type IS '举报对象类型（letter/user 等）';

CREATE TABLE bu_password_reset_token (
    id           BIGSERIAL PRIMARY KEY,
    user_id      BIGINT NOT NULL,
    code_hash    VARCHAR(64) NOT NULL,
    expires_at   TIMESTAMP NOT NULL,
    used_at      TIMESTAMP,
    created_at   TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_pwd_reset_user_created ON bu_password_reset_token (user_id, created_at DESC);
CREATE INDEX idx_pwd_reset_expires ON bu_password_reset_token (expires_at) WHERE used_at IS NULL;

CREATE TABLE bu_app_feedback (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    content         VARCHAR(4000) NOT NULL,
    client_version  VARCHAR(128),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by      BIGINT,
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_bu_app_feedback_user_id ON bu_app_feedback(user_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_app_feedback_created_at ON bu_app_feedback(created_at DESC) WHERE del_flag = FALSE;

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
    sealed_at               TIMESTAMP,
    delivered_at            TIMESTAMP,
    read_at                 TIMESTAMP,
    cancel_deadline_at      TIMESTAMP,
    cancelled_at            TIMESTAMP,
    stamp_cost              INT NOT NULL DEFAULT 0,
    sender_snapshot_json    TEXT,
    writer_city             VARCHAR(128),
    write_duration_sec      INT,
    privacy_level           SMALLINT NOT NULL DEFAULT 1,
    star_flag               BOOLEAN NOT NULL DEFAULT FALSE,
    reply_to_id             BIGINT,
    seal_request_id         VARCHAR(64),
    fail_reason             VARCHAR(256),
    takedown_reason         VARCHAR(256),
    created_at              TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by              BIGINT,
    updated_at              TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by              BIGINT,
    del_flag                BOOLEAN NOT NULL DEFAULT FALSE
);
COMMENT ON TABLE bu_time_letter IS '时光邮局信件';
COMMENT ON COLUMN bu_time_letter.recipient_id IS 'NULL=写给自己';
COMMENT ON COLUMN bu_time_letter.recipient_type IS '1=SELF 2=FRIEND';
COMMENT ON COLUMN bu_time_letter.status IS '1=DRAFT 2=PENDING 3=DELIVERED 4=READ 5=CANCELLED 6=FAILED';
COMMENT ON COLUMN bu_time_letter.sender_snapshot_json IS '发件人快照（JSON 字符串）';
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

CREATE TABLE bu_im_conversation (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    target_user_id  BIGINT NOT NULL,
    im_conversation_id VARCHAR(128),
    last_message_at TIMESTAMP,
    last_message_preview TEXT,
    unread_count    INT DEFAULT 0,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by      BIGINT,
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE(user_id, target_user_id)
);
CREATE INDEX idx_bu_im_conversation_user_id ON bu_im_conversation(user_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_im_conversation_target_user_id ON bu_im_conversation(target_user_id) WHERE del_flag = FALSE;

CREATE TABLE bu_im_message (
    id              BIGSERIAL PRIMARY KEY,
    conversation_id BIGINT NOT NULL,
    sender_id       BIGINT NOT NULL,
    msg_type        SMALLINT DEFAULT 1,
    content         TEXT NOT NULL,
    im_msg_id       VARCHAR(128),
    status          SMALLINT DEFAULT 1,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by      BIGINT,
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_bu_im_message_conversation_id ON bu_im_message(conversation_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_im_message_sender_id ON bu_im_message(sender_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_im_message_created_at ON bu_im_message(created_at) WHERE del_flag = FALSE;

CREATE TABLE bu_visitor_record (
    id              BIGSERIAL PRIMARY KEY,
    visitor_id      BIGINT NOT NULL,
    visited_id      BIGINT NOT NULL,
    visit_type      SMALLINT DEFAULT 1,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by      BIGINT,
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_bu_visitor_record_visited_id ON bu_visitor_record(visited_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_visitor_record_visitor_id ON bu_visitor_record(visitor_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_visitor_record_created_at ON bu_visitor_record(created_at) WHERE del_flag = FALSE;

CREATE TABLE bu_user_blacklist (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    blocked_user_id BIGINT NOT NULL,
    reason          VARCHAR(255),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by      BIGINT,
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE(user_id, blocked_user_id)
);
CREATE INDEX idx_bu_user_blacklist_user_id ON bu_user_blacklist(user_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_user_blacklist_blocked_user_id ON bu_user_blacklist(blocked_user_id) WHERE del_flag = FALSE;

-- 三、日志表（log_ 前缀）

CREATE TABLE log_login (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT,
    login_ip        VARCHAR(64),
    device_uuid     VARCHAR(255),
    login_result    SMALLINT,
    fail_reason     VARCHAR(100),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by      BIGINT,
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_log_login_user_id ON log_login(user_id) WHERE del_flag = FALSE;
CREATE INDEX idx_log_login_created_at ON log_login(created_at) WHERE del_flag = FALSE;

CREATE TABLE log_action (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT,
    action_type     VARCHAR(50),
    target_type     VARCHAR(50),
    target_id       BIGINT,
    details         JSONB,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by      BIGINT,
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_log_action_user_id ON log_action(user_id) WHERE del_flag = FALSE;
CREATE INDEX idx_log_action_created_at ON log_action(created_at) WHERE del_flag = FALSE;

CREATE TABLE log_exception (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT,
    exception_type  VARCHAR(100),
    message         TEXT,
    stack_trace     TEXT,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by      BIGINT,
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_log_exception_created_at ON log_exception(created_at) WHERE del_flag = FALSE;

CREATE TABLE log_admin_operation (
    id              BIGSERIAL PRIMARY KEY,
    admin_id        BIGINT NOT NULL,
    action_type     VARCHAR(50),
    target_type     VARCHAR(50),
    target_id       BIGINT,
    details         JSONB,
    ip_address      VARCHAR(64),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by      BIGINT,
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_log_admin_operation_admin_id ON log_admin_operation(admin_id) WHERE del_flag = FALSE;
CREATE INDEX idx_log_admin_operation_created_at ON log_admin_operation(created_at) WHERE del_flag = FALSE;
