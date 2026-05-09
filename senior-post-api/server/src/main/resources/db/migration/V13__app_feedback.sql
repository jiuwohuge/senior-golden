-- APP 使用反馈（运营查看）
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
COMMENT ON TABLE bu_app_feedback IS 'APP 使用反馈与建议';
COMMENT ON COLUMN bu_app_feedback.user_id IS '提交用户';
COMMENT ON COLUMN bu_app_feedback.content IS '反馈正文';
COMMENT ON COLUMN bu_app_feedback.client_version IS '客户端版本号（可选）';
