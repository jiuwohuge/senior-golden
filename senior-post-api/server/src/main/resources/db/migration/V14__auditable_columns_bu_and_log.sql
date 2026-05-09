-- 与 AbstractAuditableDomain / AbstractAuditableDTO 对齐：created_at、created_by、updated_at、updated_by、del_flag
-- V1 中部分 bu_/log_ 表缺列导致 MyBatis-Plus 查询失败（如 bu_user_blacklist 缺 created_by）。

-- 22. 用户黑名单
ALTER TABLE bu_user_blacklist
    ADD COLUMN IF NOT EXISTS created_by BIGINT;
ALTER TABLE bu_user_blacklist
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NOT NULL DEFAULT NOW();
ALTER TABLE bu_user_blacklist
    ADD COLUMN IF NOT EXISTS updated_by BIGINT;
COMMENT ON COLUMN bu_user_blacklist.created_by IS '创建人用户ID';
COMMENT ON COLUMN bu_user_blacklist.updated_at IS '更新时间';
COMMENT ON COLUMN bu_user_blacklist.updated_by IS '更新人用户ID';

-- 20. IM 消息
ALTER TABLE bu_im_message
    ADD COLUMN IF NOT EXISTS created_by BIGINT;
ALTER TABLE bu_im_message
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NOT NULL DEFAULT NOW();
ALTER TABLE bu_im_message
    ADD COLUMN IF NOT EXISTS updated_by BIGINT;
COMMENT ON COLUMN bu_im_message.created_by IS '创建人用户ID';
COMMENT ON COLUMN bu_im_message.updated_at IS '更新时间';
COMMENT ON COLUMN bu_im_message.updated_by IS '更新人用户ID';

-- 19. IM 会话
ALTER TABLE bu_im_conversation
    ADD COLUMN IF NOT EXISTS created_by BIGINT;
ALTER TABLE bu_im_conversation
    ADD COLUMN IF NOT EXISTS updated_by BIGINT;
COMMENT ON COLUMN bu_im_conversation.created_by IS '创建人用户ID';
COMMENT ON COLUMN bu_im_conversation.updated_by IS '更新人用户ID';

-- 21. 访客记录
ALTER TABLE bu_visitor_record
    ADD COLUMN IF NOT EXISTS created_by BIGINT;
ALTER TABLE bu_visitor_record
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NOT NULL DEFAULT NOW();
ALTER TABLE bu_visitor_record
    ADD COLUMN IF NOT EXISTS updated_by BIGINT;
COMMENT ON COLUMN bu_visitor_record.created_by IS '创建人用户ID';
COMMENT ON COLUMN bu_visitor_record.updated_at IS '更新时间';
COMMENT ON COLUMN bu_visitor_record.updated_by IS '更新人用户ID';

-- 23. 每日发布记录
ALTER TABLE bu_daily_publish_record
    ADD COLUMN IF NOT EXISTS created_by BIGINT;
ALTER TABLE bu_daily_publish_record
    ADD COLUMN IF NOT EXISTS updated_by BIGINT;
COMMENT ON COLUMN bu_daily_publish_record.created_by IS '创建人用户ID';
COMMENT ON COLUMN bu_daily_publish_record.updated_by IS '更新人用户ID';

-- 24. 管理员操作日志（Domain 继承可审计基类）
ALTER TABLE log_admin_operation
    ADD COLUMN IF NOT EXISTS created_by BIGINT;
ALTER TABLE log_admin_operation
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NOT NULL DEFAULT NOW();
ALTER TABLE log_admin_operation
    ADD COLUMN IF NOT EXISTS updated_by BIGINT;
COMMENT ON COLUMN log_admin_operation.created_by IS '创建人用户ID';
COMMENT ON COLUMN log_admin_operation.updated_at IS '更新时间';
COMMENT ON COLUMN log_admin_operation.updated_by IS '更新人用户ID';
