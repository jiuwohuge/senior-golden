-- 忘记密码：一次性验证码（哈希落库），与 FP-A1-003 对齐
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
COMMENT ON TABLE bu_password_reset_token IS '密码重置验证码（仅存哈希）';
COMMENT ON COLUMN bu_password_reset_token.user_id IS '用户ID';
COMMENT ON COLUMN bu_password_reset_token.code_hash IS '验证码 SHA-256 十六进制';
COMMENT ON COLUMN bu_password_reset_token.expires_at IS '过期时间';
COMMENT ON COLUMN bu_password_reset_token.used_at IS '使用时间（一次性）';
