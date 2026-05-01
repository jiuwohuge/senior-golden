-- 一、系统配置表（sys_ 前缀）
-- 1. 兴趣标签表 (sys_tag)
CREATE TABLE sys_tag (
    id              SERIAL PRIMARY KEY,
    tag_name        VARCHAR(50) NOT NULL,
    lang_code       VARCHAR(10) NOT NULL DEFAULT 'en',
    sort_order      INT DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by      VARCHAR(64),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(64),
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE(tag_name, lang_code)
);
CREATE INDEX idx_sys_tag_lang ON sys_tag(lang_code) WHERE del_flag = FALSE;
CREATE INDEX idx_sys_tag_sort_order ON sys_tag(sort_order) WHERE del_flag = FALSE;
COMMENT ON TABLE sys_tag IS '兴趣标签表';
COMMENT ON COLUMN sys_tag.id IS '标签ID';
COMMENT ON COLUMN sys_tag.tag_name IS '标签名称';
COMMENT ON COLUMN sys_tag.lang_code IS '语言代码（en/zh/ja/ko等）';
COMMENT ON COLUMN sys_tag.sort_order IS '排序顺序';

-- 2. 敏感词表 (sys_sensitive_word)
CREATE TABLE sys_sensitive_word (
    id              SERIAL PRIMARY KEY,
    word            VARCHAR(100) NOT NULL,
    type            VARCHAR(20),
    type_text       VARCHAR(50),
    lang_code       VARCHAR(10) NOT NULL DEFAULT 'en',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by      VARCHAR(64),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(64),
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE(word, lang_code)
);
CREATE INDEX idx_sys_sensitive_word_lang ON sys_sensitive_word(lang_code) WHERE del_flag = FALSE;
CREATE INDEX idx_sys_sensitive_word_type ON sys_sensitive_word(type) WHERE del_flag = FALSE;
COMMENT ON TABLE sys_sensitive_word IS '敏感词库表';
COMMENT ON COLUMN sys_sensitive_word.id IS '敏感词ID';
COMMENT ON COLUMN sys_sensitive_word.word IS '敏感词';
COMMENT ON COLUMN sys_sensitive_word.type IS '分类（porn/politics/ad等）';
COMMENT ON COLUMN sys_sensitive_word.type_text IS '分类描述（多语言）';
COMMENT ON COLUMN sys_sensitive_word.lang_code IS '语言代码（en/zh/ja/ko等）';

-- 3. 系统配置表 (sys_config)
CREATE TABLE sys_config (
    id              SERIAL PRIMARY KEY,
    config_key      VARCHAR(100) NOT NULL UNIQUE,
    config_value    TEXT,
    config_group    VARCHAR(50) NOT NULL,
    description     VARCHAR(255),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by      VARCHAR(64),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(64),
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_sys_config_group ON sys_config(config_group) WHERE del_flag = FALSE;
COMMENT ON TABLE sys_config IS '系统配置表';
COMMENT ON COLUMN sys_config.id IS '配置ID';
COMMENT ON COLUMN sys_config.config_key IS '配置键';
COMMENT ON COLUMN sys_config.config_value IS '配置值';
COMMENT ON COLUMN sys_config.config_group IS '配置分组（register/vip/stamps/system等）';
COMMENT ON COLUMN sys_config.description IS '配置描述';

-- 4. 公告表 (sys_announcement)
CREATE TABLE sys_announcement (
    id              SERIAL PRIMARY KEY,
    title           VARCHAR(200),
    title_json      JSONB,
    content         TEXT,
    content_json    JSONB,
    start_at        TIMESTAMPTZ,
    end_at          TIMESTAMPTZ,
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by      VARCHAR(64),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(64),
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_sys_announcement_active ON sys_announcement(is_active, start_at, end_at) WHERE del_flag = FALSE;
COMMENT ON TABLE sys_announcement IS '系统公告表';
COMMENT ON COLUMN sys_announcement.id IS '公告ID';
COMMENT ON COLUMN sys_announcement.title IS '标题（单语言备用）';
COMMENT ON COLUMN sys_announcement.title_json IS '标题多语言JSON {"en":"...", "zh":"..."}';
COMMENT ON COLUMN sys_announcement.content IS '内容（单语言备用）';
COMMENT ON COLUMN sys_announcement.content_json IS '内容多语言JSON {"en":"...", "zh":"..."}';
COMMENT ON COLUMN sys_announcement.start_at IS '生效开始时间';
COMMENT ON COLUMN sys_announcement.end_at IS '生效结束时间';
COMMENT ON COLUMN sys_announcement.is_active IS '是否激活';

-- 5. 版本控制表 (sys_app_version)
CREATE TABLE sys_app_version (
    id                          SERIAL PRIMARY KEY,
    app_platform                VARCHAR(20) NOT NULL,
    version_code                VARCHAR(50) NOT NULL,
    min_supported_version       VARCHAR(50),
    force_update                BOOLEAN DEFAULT FALSE,
    update_url                  TEXT,
    release_note                TEXT,
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by                  VARCHAR(64),
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by                  VARCHAR(64),
    del_flag                    BOOLEAN NOT NULL DEFAULT FALSE
);
COMMENT ON TABLE sys_app_version IS 'App版本控制表';
COMMENT ON COLUMN sys_app_version.id IS '版本ID';
COMMENT ON COLUMN sys_app_version.app_platform IS '平台（ios/android）';
COMMENT ON COLUMN sys_app_version.version_code IS '版本号';
COMMENT ON COLUMN sys_app_version.min_supported_version IS '最低支持版本';
COMMENT ON COLUMN sys_app_version.force_update IS '是否强制更新';
COMMENT ON COLUMN sys_app_version.update_url IS '更新包地址';
COMMENT ON COLUMN sys_app_version.release_note IS '更新日志';

-- 6. 国家地区表
CREATE TABLE sys_country (
    id              SERIAL PRIMARY KEY,
    country_code    VARCHAR(10) NOT NULL UNIQUE,
    country_name_en VARCHAR(100),
    country_name_zh VARCHAR(100),
    sort_order      INT DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by      VARCHAR(64),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(64),
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_sys_country_sort_order ON sys_country(sort_order) WHERE del_flag = FALSE;
COMMENT ON TABLE sys_country IS '国家地区表';
COMMENT ON COLUMN sys_country.id IS '国家ID';
COMMENT ON COLUMN sys_country.country_code IS '国家代码（ISO 3166-1 alpha-2）';
COMMENT ON COLUMN sys_country.country_name_en IS '英文名称';
COMMENT ON COLUMN sys_country.country_name_zh IS '中文名称';
COMMENT ON COLUMN sys_country.sort_order IS '排序顺序';

-- 二、业务表（bu_ 前缀）
-- 7. 用户表 (bu_user)
CREATE TABLE bu_user (
    id              BIGSERIAL PRIMARY KEY,
    email           VARCHAR(255) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    nickname        VARCHAR(100) NOT NULL,
    birth_year      INT NOT NULL,
    country_code    VARCHAR(10),
    bio             TEXT,
    avatar_url      TEXT,
    stamps_balance  INT NOT NULL DEFAULT 0,
    is_vip          BOOLEAN DEFAULT FALSE,
    vip_expire_at   TIMESTAMPTZ,
    status          SMALLINT DEFAULT 1,
    register_ip     INET,
    last_login_at   TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by      VARCHAR(64),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(64),
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_bu_user_email ON bu_user(email) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_user_nickname ON bu_user(nickname) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_user_status ON bu_user(status) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_user_birth_year ON bu_user(birth_year);
COMMENT ON TABLE bu_user IS '用户主表';
COMMENT ON COLUMN bu_user.id IS '用户ID';
COMMENT ON COLUMN bu_user.email IS '邮箱（登录账号）';
COMMENT ON COLUMN bu_user.password_hash IS '密码哈希';
COMMENT ON COLUMN bu_user.nickname IS '昵称';
COMMENT ON COLUMN bu_user.birth_year IS '出生年份（用于年龄验证）';
COMMENT ON COLUMN bu_user.country_code IS '国家代码';
COMMENT ON COLUMN bu_user.bio IS '个人简介';
COMMENT ON COLUMN bu_user.avatar_url IS '头像URL';
COMMENT ON COLUMN bu_user.stamps_balance IS '邮票余额';
COMMENT ON COLUMN bu_user.is_vip IS '是否VIP会员（冗余）';
COMMENT ON COLUMN bu_user.vip_expire_at IS 'VIP过期时间（冗余）';
COMMENT ON COLUMN bu_user.status IS '状态：1正常 2封禁 3注销';
COMMENT ON COLUMN bu_user.register_ip IS '注册IP';
COMMENT ON COLUMN bu_user.last_login_at IS '最后登录时间';

-- 8. 用户设备表 (bu_user_device)
CREATE TABLE bu_user_device (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    device_uuid     VARCHAR(255) NOT NULL,
    device_type     VARCHAR(20),
    last_login_at   TIMESTAMPTZ,
    status          SMALLINT DEFAULT 1,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by      VARCHAR(64),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(64),
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_bu_user_device_user_id ON bu_user_device(user_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_user_device_uuid ON bu_user_device(device_uuid) WHERE del_flag = FALSE;
COMMENT ON TABLE bu_user_device IS '用户设备记录表（用于风控/拉黑/防刷）';
COMMENT ON COLUMN bu_user_device.id IS '设备记录ID';
COMMENT ON COLUMN bu_user_device.user_id IS '用户ID';
COMMENT ON COLUMN bu_user_device.device_uuid IS '设备唯一标识（IDFA/IDFV/Android ID）';
COMMENT ON COLUMN bu_user_device.device_type IS '设备类型（ios/android）';
COMMENT ON COLUMN bu_user_device.last_login_at IS '最后登录时间';
COMMENT ON COLUMN bu_user_device.status IS '状态：1正常 2黑名单';

-- 9. 用户兴趣关联表 (bu_user_tag)
CREATE TABLE bu_user_tag (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    tag_id          INT NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by      VARCHAR(64),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(64),
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE(user_id, tag_id)
);
CREATE INDEX idx_bu_user_tag_user_id ON bu_user_tag(user_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_user_tag_tag_id ON bu_user_tag(tag_id) WHERE del_flag = FALSE;
COMMENT ON TABLE bu_user_tag IS '用户兴趣标签关联表';
COMMENT ON COLUMN bu_user_tag.id IS '关联ID';
COMMENT ON COLUMN bu_user_tag.user_id IS '用户ID';
COMMENT ON COLUMN bu_user_tag.tag_id IS '标签ID';

-- 10. 明信片表 (bu_postcard)
CREATE TABLE bu_postcard (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    content         TEXT NOT NULL,
    images          TEXT[],
    status          SMALLINT DEFAULT 1,
    review_status   SMALLINT DEFAULT 0,
    published_at    TIMESTAMPTZ DEFAULT NOW(),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by      VARCHAR(64),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(64),
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_bu_postcard_user_id ON bu_postcard(user_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_postcard_published_at ON bu_postcard(published_at DESC) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_postcard_review_status ON bu_postcard(review_status) WHERE del_flag = FALSE;
COMMENT ON TABLE bu_postcard IS '明信片墙表（用户发布的公开明信片）';
COMMENT ON COLUMN bu_postcard.id IS '明信片ID';
COMMENT ON COLUMN bu_postcard.user_id IS '发布用户ID';
COMMENT ON COLUMN bu_postcard.content IS '文字内容';
COMMENT ON COLUMN bu_postcard.images IS '图片URL数组';
COMMENT ON COLUMN bu_postcard.status IS '状态：1公开 2隐藏 3违规删除';
COMMENT ON COLUMN bu_postcard.review_status IS '审核状态：0待审核 1通过 2驳回';
COMMENT ON COLUMN bu_postcard.published_at IS '发布时间';

-- 11. 明信片评论表 (bu_postcard_comment)
CREATE TABLE bu_postcard_comment (
    id              BIGSERIAL PRIMARY KEY,
    postcard_id     BIGINT NOT NULL,
    user_id         BIGINT NOT NULL,
    content         TEXT NOT NULL,
    status          SMALLINT DEFAULT 1,
    review_status   SMALLINT DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by      VARCHAR(64),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(64),
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_bu_postcard_comment_postcard_id ON bu_postcard_comment(postcard_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_postcard_comment_user_id ON bu_postcard_comment(user_id) WHERE del_flag = FALSE;
COMMENT ON TABLE bu_postcard_comment IS '明信片评论表';
COMMENT ON COLUMN bu_postcard_comment.id IS '评论ID';
COMMENT ON COLUMN bu_postcard_comment.postcard_id IS '明信片ID';
COMMENT ON COLUMN bu_postcard_comment.user_id IS '评论用户ID';
COMMENT ON COLUMN bu_postcard_comment.content IS '评论内容';
COMMENT ON COLUMN bu_postcard_comment.status IS '状态：1正常 2删除';
COMMENT ON COLUMN bu_postcard_comment.review_status IS '审核状态：0待审核 1通过 2驳回';

-- 12. 信件表 (bu_letter)
CREATE TABLE bu_letter (
    id                      BIGSERIAL PRIMARY KEY,
    from_user_id            BIGINT NOT NULL,
    to_user_id              BIGINT NOT NULL,
    letter_type             SMALLINT NOT NULL,
    status                  SMALLINT NOT NULL,
    content                 TEXT NOT NULL,
    is_accelerated          BOOLEAN DEFAULT FALSE,
    accelerated_at          TIMESTAMPTZ,
    expected_arrival_time   TIMESTAMPTZ,
    actual_arrival_time     TIMESTAMPTZ,
    parent_letter_id        BIGINT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by              VARCHAR(64),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by              VARCHAR(64),
    del_flag                BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_bu_letter_from_user ON bu_letter(from_user_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_letter_to_user ON bu_letter(to_user_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_letter_status ON bu_letter(status) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_letter_parent ON bu_letter(parent_letter_id) WHERE del_flag = FALSE;
COMMENT ON TABLE bu_letter IS '信件表（挂号信/平邮）';
COMMENT ON COLUMN bu_letter.id IS '信件ID';
COMMENT ON COLUMN bu_letter.from_user_id IS '发件人用户ID';
COMMENT ON COLUMN bu_letter.to_user_id IS '收件人用户ID';
COMMENT ON COLUMN bu_letter.letter_type IS '类型：1挂号信（即时） 2平邮（慢信）';
COMMENT ON COLUMN bu_letter.status IS '状态：1运输中（仅平邮） 2已送达';
COMMENT ON COLUMN bu_letter.content IS '信件内容';
COMMENT ON COLUMN bu_letter.is_accelerated IS '是否已加速（仅平邮）';
COMMENT ON COLUMN bu_letter.accelerated_at IS '加速时间';
COMMENT ON COLUMN bu_letter.expected_arrival_time IS '预计送达时间（平邮）';
COMMENT ON COLUMN bu_letter.actual_arrival_time IS '实际送达时间';
COMMENT ON COLUMN bu_letter.parent_letter_id IS '回复的信件ID（自关联）';

-- 13. VIP订阅表 (bu_vip_subscription)
CREATE TABLE bu_vip_subscription (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    plan_id         VARCHAR(50),
    start_at        TIMESTAMPTZ NOT NULL,
    end_at          TIMESTAMPTZ NOT NULL,
    status          SMALLINT DEFAULT 1,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by      VARCHAR(64),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(64),
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_bu_vip_subscription_user_id ON bu_vip_subscription(user_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_vip_subscription_end_at ON bu_vip_subscription(end_at) WHERE del_flag = FALSE;
COMMENT ON TABLE bu_vip_subscription IS 'VIP订阅记录表';
COMMENT ON COLUMN bu_vip_subscription.id IS '订阅ID';
COMMENT ON COLUMN bu_vip_subscription.user_id IS '用户ID';
COMMENT ON COLUMN bu_vip_subscription.plan_id IS '套餐标识';
COMMENT ON COLUMN bu_vip_subscription.start_at IS '生效开始时间';
COMMENT ON COLUMN bu_vip_subscription.end_at IS '生效结束时间';
COMMENT ON COLUMN bu_vip_subscription.status IS '状态：1有效 2过期 3取消';

-- 14. 举报表 (bu_report)
CREATE TABLE bu_report (
    id              BIGSERIAL PRIMARY KEY,
    reporter_user_id BIGINT NOT NULL,
    target_type     VARCHAR(20) NOT NULL,
    target_id       BIGINT NOT NULL,
    reason          VARCHAR(255),
    status          SMALLINT DEFAULT 0,
    handler_user_id BIGINT,
    handle_note     TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by      VARCHAR(64),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(64),
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_bu_report_reporter ON bu_report(reporter_user_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_report_target ON bu_report(target_type, target_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_report_status ON bu_report(status) WHERE del_flag = FALSE;
COMMENT ON TABLE bu_report IS '举报工单表';
COMMENT ON COLUMN bu_report.id IS '举报ID';
COMMENT ON COLUMN bu_report.reporter_user_id IS '举报人用户ID';
COMMENT ON COLUMN bu_report.target_type IS '举报对象类型（postcard/comment/letter/user）';
COMMENT ON COLUMN bu_report.target_id IS '举报对象ID';
COMMENT ON COLUMN bu_report.reason IS '举报原因';
COMMENT ON COLUMN bu_report.status IS '状态：0待处理 1已处理 2驳回';
COMMENT ON COLUMN bu_report.handler_user_id IS '处理人用户ID';
COMMENT ON COLUMN bu_report.handle_note IS '处理备注';

-- 三、日志表（log_ 前缀）
-- 15. 邮票变更记录表 (log_stamp_transaction)
CREATE TABLE log_stamp_transaction (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    change_amount   INT NOT NULL,
    balance_after   INT NOT NULL,
    reason          VARCHAR(50),
    ref_id          BIGINT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by      VARCHAR(64),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(64),
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_log_stamp_user_id ON log_stamp_transaction(user_id) WHERE del_flag = FALSE;
CREATE INDEX idx_log_stamp_created_at ON log_stamp_transaction(created_at) WHERE del_flag = FALSE;
COMMENT ON TABLE log_stamp_transaction IS '邮票变更流水日志';
COMMENT ON COLUMN log_stamp_transaction.id IS '流水ID';
COMMENT ON COLUMN log_stamp_transaction.user_id IS '用户ID';
COMMENT ON COLUMN log_stamp_transaction.change_amount IS '变更数量（正增负减）';
COMMENT ON COLUMN log_stamp_transaction.balance_after IS '变更后余额';
COMMENT ON COLUMN log_stamp_transaction.reason IS '变更原因（登录奖励/发布明信片/挂号信消耗/加速消耗）';
COMMENT ON COLUMN log_stamp_transaction.ref_id IS '关联业务ID（明信片ID/信件ID）';

-- 16. 登录日志表 (log_login)
CREATE TABLE log_login (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT,
    login_ip        INET,
    device_uuid     VARCHAR(255),
    login_result    SMALLINT,
    fail_reason     VARCHAR(100),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by      VARCHAR(64),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(64),
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_log_login_user_id ON log_login(user_id) WHERE del_flag = FALSE;
CREATE INDEX idx_log_login_created_at ON log_login(created_at) WHERE del_flag = FALSE;
COMMENT ON TABLE log_login IS '登录日志表';
COMMENT ON COLUMN log_login.id IS '日志ID';
COMMENT ON COLUMN log_login.user_id IS '用户ID（登录成功时有值）';
COMMENT ON COLUMN log_login.login_ip IS '登录IP';
COMMENT ON COLUMN log_login.device_uuid IS '设备UUID';
COMMENT ON COLUMN log_login.login_result IS '结果：1成功 2失败';
COMMENT ON COLUMN log_login.fail_reason IS '失败原因';

-- 17. 用户行为日志表 (log_action)
CREATE TABLE log_action (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT,
    action_type     VARCHAR(50),
    target_type     VARCHAR(50),
    target_id       BIGINT,
    details         JSONB,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by      VARCHAR(64),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(64),
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_log_action_user_id ON log_action(user_id) WHERE del_flag = FALSE;
CREATE INDEX idx_log_action_created_at ON log_action(created_at) WHERE del_flag = FALSE;
COMMENT ON TABLE log_action IS '用户行为日志（发布/寄信/加速等）';
COMMENT ON COLUMN log_action.id IS '日志ID';
COMMENT ON COLUMN log_action.user_id IS '操作用户ID';
COMMENT ON COLUMN log_action.action_type IS '行为类型';
COMMENT ON COLUMN log_action.target_type IS '目标类型';
COMMENT ON COLUMN log_action.target_id IS '目标ID';
COMMENT ON COLUMN log_action.details IS '详情（JSON格式）';

-- 18. 异常日志表 (log_exception)
CREATE TABLE log_exception (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT,
    exception_type  VARCHAR(100),
    message         TEXT,
    stack_trace     TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by      VARCHAR(64),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(64),
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_log_exception_created_at ON log_exception(created_at) WHERE del_flag = FALSE;
COMMENT ON TABLE log_exception IS '系统异常日志表';
COMMENT ON COLUMN log_exception.id IS '日志ID';
COMMENT ON COLUMN log_exception.user_id IS '用户ID';
COMMENT ON COLUMN log_exception.exception_type IS '异常类型';
COMMENT ON COLUMN log_exception.message IS '错误消息';
COMMENT ON COLUMN log_exception.stack_trace IS '堆栈跟踪';

-- 四、补充业务表
-- 19. IM会话表（腾讯IM本地存储）
CREATE TABLE bu_im_conversation (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    target_user_id  BIGINT NOT NULL,
    im_conversation_id VARCHAR(128),
    last_message_at TIMESTAMPTZ,
    last_message_preview TEXT,
    unread_count    INT DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE(user_id, target_user_id)
);
CREATE INDEX idx_bu_im_conversation_user_id ON bu_im_conversation(user_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_im_conversation_target_user_id ON bu_im_conversation(target_user_id) WHERE del_flag = FALSE;
COMMENT ON TABLE bu_im_conversation IS 'IM会话表（腾讯IM）';
COMMENT ON COLUMN bu_im_conversation.id IS '会话ID';
COMMENT ON COLUMN bu_im_conversation.user_id IS '用户ID';
COMMENT ON COLUMN bu_im_conversation.target_user_id IS '对方用户ID';
COMMENT ON COLUMN bu_im_conversation.im_conversation_id IS '腾讯云端会话ID';
COMMENT ON COLUMN bu_im_conversation.last_message_at IS '最后消息时间';
COMMENT ON COLUMN bu_im_conversation.last_message_preview IS '最后消息预览';
COMMENT ON COLUMN bu_im_conversation.unread_count IS '未读消息数';

-- 20. IM消息表
CREATE TABLE bu_im_message (
    id              BIGSERIAL PRIMARY KEY,
    conversation_id BIGINT NOT NULL,
    sender_id       BIGINT NOT NULL,
    msg_type        SMALLINT DEFAULT 1,
    content         TEXT NOT NULL,
    im_msg_id       VARCHAR(128),
    status          SMALLINT DEFAULT 1,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_bu_im_message_conversation_id ON bu_im_message(conversation_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_im_message_sender_id ON bu_im_message(sender_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_im_message_created_at ON bu_im_message(created_at) WHERE del_flag = FALSE;
COMMENT ON TABLE bu_im_message IS 'IM消息表';
COMMENT ON COLUMN bu_im_message.id IS '消息ID';
COMMENT ON COLUMN bu_im_message.conversation_id IS '会话ID';
COMMENT ON COLUMN bu_im_message.sender_id IS '发送者ID';
COMMENT ON COLUMN bu_im_message.msg_type IS '消息类型：1文本 2图片 3语音';
COMMENT ON COLUMN bu_im_message.content IS '消息内容';
COMMENT ON COLUMN bu_im_message.im_msg_id IS '腾讯云端消息ID';
COMMENT ON COLUMN bu_im_message.status IS '状态：1已发送 2已读';
COMMENT ON COLUMN bu_im_message.created_at IS '创建时间';

-- 21. 访客记录表（VIP查看访客功能）
CREATE TABLE bu_visitor_record (
    id              BIGSERIAL PRIMARY KEY,
    visitor_id      BIGINT NOT NULL,
    visited_id      BIGINT NOT NULL,
    visit_type      SMALLINT DEFAULT 1,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_bu_visitor_record_visited_id ON bu_visitor_record(visited_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_visitor_record_visitor_id ON bu_visitor_record(visitor_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_visitor_record_created_at ON bu_visitor_record(created_at) WHERE del_flag = FALSE;
COMMENT ON TABLE bu_visitor_record IS '访客记录表';
COMMENT ON COLUMN bu_visitor_record.id IS '记录ID';
COMMENT ON COLUMN bu_visitor_record.visitor_id IS '访问者ID';
COMMENT ON COLUMN bu_visitor_record.visited_id IS '被访问者ID';
COMMENT ON COLUMN bu_visitor_record.visit_type IS '访问类型：1查看资料 2查看明信片';
COMMENT ON COLUMN bu_visitor_record.created_at IS '访问时间';

-- 22. 用户黑名单表（拉黑功能）
CREATE TABLE bu_user_blacklist (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    blocked_user_id BIGINT NOT NULL,
    reason          VARCHAR(255),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE(user_id, blocked_user_id)
);
CREATE INDEX idx_bu_user_blacklist_user_id ON bu_user_blacklist(user_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_user_blacklist_blocked_user_id ON bu_user_blacklist(blocked_user_id) WHERE del_flag = FALSE;
COMMENT ON TABLE bu_user_blacklist IS '用户黑名单表';
COMMENT ON COLUMN bu_user_blacklist.id IS '记录ID';
COMMENT ON COLUMN bu_user_blacklist.user_id IS '用户ID';
COMMENT ON COLUMN bu_user_blacklist.blocked_user_id IS '被拉黑用户ID';
COMMENT ON COLUMN bu_user_blacklist.reason IS '拉黑原因';
COMMENT ON COLUMN bu_user_blacklist.created_at IS '拉黑时间';

-- 23. 每日发布记录表（限制发布次数）
CREATE TABLE bu_daily_publish_record (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    publish_date    DATE NOT NULL,
    publish_count   INT DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE(user_id, publish_date)
);
CREATE INDEX idx_bu_daily_publish_record_user_id ON bu_daily_publish_record(user_id) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_daily_publish_record_publish_date ON bu_daily_publish_record(publish_date) WHERE del_flag = FALSE;
COMMENT ON TABLE bu_daily_publish_record IS '每日发布记录表';
COMMENT ON COLUMN bu_daily_publish_record.id IS '记录ID';
COMMENT ON COLUMN bu_daily_publish_record.user_id IS '用户ID';
COMMENT ON COLUMN bu_daily_publish_record.publish_date IS '发布日期';
COMMENT ON COLUMN bu_daily_publish_record.publish_count IS '当日发布次数';

-- 24. 管理员表
CREATE TABLE bu_admin_user (
    id              BIGSERIAL PRIMARY KEY,
    username        VARCHAR(100) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    nickname        VARCHAR(100),
    role            SMALLINT DEFAULT 1,
    status          SMALLINT DEFAULT 1,
    last_login_at   TIMESTAMPTZ,
    last_login_ip   INET,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by      VARCHAR(64),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(64),
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_bu_admin_user_username ON bu_admin_user(username) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_admin_user_role ON bu_admin_user(role) WHERE del_flag = FALSE;
CREATE INDEX idx_bu_admin_user_status ON bu_admin_user(status) WHERE del_flag = FALSE;
COMMENT ON TABLE bu_admin_user IS '管理员表';
COMMENT ON COLUMN bu_admin_user.id IS '管理员ID';
COMMENT ON COLUMN bu_admin_user.username IS '管理员用户名';
COMMENT ON COLUMN bu_admin_user.password_hash IS '密码哈希';
COMMENT ON COLUMN bu_admin_user.nickname IS '管理员昵称';
COMMENT ON COLUMN bu_admin_user.role IS '角色：1超级管理员 2普通管理员';
COMMENT ON COLUMN bu_admin_user.status IS '状态：1正常 2禁用';
COMMENT ON COLUMN bu_admin_user.last_login_at IS '最后登录时间';
COMMENT ON COLUMN bu_admin_user.last_login_ip IS '最后登录IP';

-- 25. 管理员操作日志表
CREATE TABLE log_admin_operation (
    id              BIGSERIAL PRIMARY KEY,
    admin_id        BIGINT NOT NULL,
    action_type     VARCHAR(50),
    target_type     VARCHAR(50),
    target_id       BIGINT,
    details         JSONB,
    ip_address      INET,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_log_admin_operation_admin_id ON log_admin_operation(admin_id) WHERE del_flag = FALSE;
CREATE INDEX idx_log_admin_operation_created_at ON log_admin_operation(created_at) WHERE del_flag = FALSE;
COMMENT ON TABLE log_admin_operation IS '管理员操作日志表';
COMMENT ON COLUMN log_admin_operation.id IS '日志ID';
COMMENT ON COLUMN log_admin_operation.admin_id IS '管理员ID';
COMMENT ON COLUMN log_admin_operation.action_type IS '操作类型';
COMMENT ON COLUMN log_admin_operation.target_type IS '目标类型';
COMMENT ON COLUMN log_admin_operation.target_id IS '目标ID';
COMMENT ON COLUMN log_admin_operation.details IS '操作详情';
COMMENT ON COLUMN log_admin_operation.ip_address IS 'IP地址';
