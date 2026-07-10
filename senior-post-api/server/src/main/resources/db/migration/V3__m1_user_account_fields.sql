-- M1: account + user kernel fields
ALTER TABLE bu_user
    ADD COLUMN IF NOT EXISTS email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS city VARCHAR(100),
    ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION,
    ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION,
    ADD COLUMN IF NOT EXISTS language VARCHAR(16),
    ADD COLUMN IF NOT EXISTS writing_style VARCHAR(32);

COMMENT ON COLUMN bu_user.email_verified IS '邮箱是否已验证绑定；注册默认 false，不阻断使用';
COMMENT ON COLUMN bu_user.city IS '城市/地区展示名（自动定位或用户修正）';
COMMENT ON COLUMN bu_user.latitude IS '纬度（GPS 或 IP 定位）';
COMMENT ON COLUMN bu_user.longitude IS '经度（GPS 或 IP 定位）';
COMMENT ON COLUMN bu_user.language IS '用户语言标签，如 zh-CN / en-US，用于匹配';
COMMENT ON COLUMN bu_user.writing_style IS '写作风格：concise | narrative | emotional，系统规则生成';

ALTER TABLE log_login
    ADD COLUMN IF NOT EXISTS user_agent VARCHAR(512),
    ADD COLUMN IF NOT EXISTS ip_country VARCHAR(10),
    ADD COLUMN IF NOT EXISTS risk_level SMALLINT NOT NULL DEFAULT 0;

COMMENT ON COLUMN log_login.user_agent IS '客户端 User-Agent';
COMMENT ON COLUMN log_login.ip_country IS '登录 IP 解析出的国家码';
COMMENT ON COLUMN log_login.risk_level IS '风险：0无 1轻 2中 3高';

-- 复用密码重置 token 表承载邮箱验证码（purpose 区分）
ALTER TABLE bu_password_reset_token
    ADD COLUMN IF NOT EXISTS purpose VARCHAR(32) NOT NULL DEFAULT 'password_reset';

COMMENT ON COLUMN bu_password_reset_token.purpose IS 'password_reset | email_verify | login_challenge';
