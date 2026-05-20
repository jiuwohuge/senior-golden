-- 用户性别 + 登录身份表；bu_user 不再存 email/password_hash

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
COMMENT ON TABLE bu_user_identity IS '用户登录身份：email/google/apple';
COMMENT ON COLUMN bu_user_identity.provider IS 'email | google | apple';
COMMENT ON COLUMN bu_user_identity.provider_uid IS '邮箱或 OAuth sub(openId)';

INSERT INTO bu_user_identity (user_id, provider, provider_uid, password_hash, created_at, created_by, updated_at, updated_by, del_flag)
SELECT id, 'email', LOWER(TRIM(email)), password_hash, created_at, COALESCE(created_by, 0), updated_at, COALESCE(updated_by, 0), del_flag
FROM bu_user
WHERE email IS NOT NULL AND TRIM(email) <> '';

ALTER TABLE bu_user ADD COLUMN IF NOT EXISTS gender SMALLINT NOT NULL DEFAULT 0;
COMMENT ON COLUMN bu_user.gender IS '0未设置 1男 2女 3其他/不愿透露';

ALTER TABLE bu_user DROP CONSTRAINT IF EXISTS bu_user_email_key;
ALTER TABLE bu_user DROP COLUMN IF EXISTS email;
ALTER TABLE bu_user DROP COLUMN IF EXISTS password_hash;

-- 已注销/软删账号：归档 identity.provider_uid（释放 UNIQUE）
UPDATE bu_user_identity i
SET provider_uid = LEFT(
        CASE
            WHEN POSITION('@' IN LOWER(i.provider_uid)) > 0 THEN
                SPLIT_PART(LOWER(i.provider_uid), '@', 1)
                    || '+deleted.'
                    || (FLOOR(EXTRACT(EPOCH FROM COALESCE(i.updated_at, i.created_at, NOW())) * 1000))::BIGINT::TEXT
                    || '@'
                    || SPLIT_PART(LOWER(i.provider_uid), '@', 2)
            ELSE
                i.provider_uid || '+deleted.'
                    || (FLOOR(EXTRACT(EPOCH FROM COALESCE(i.updated_at, i.created_at, NOW())) * 1000))::BIGINT::TEXT
        END,
        255),
    updated_at = NOW()
FROM bu_user u
WHERE i.user_id = u.id
  AND i.del_flag = FALSE
  AND i.provider_uid NOT LIKE '%+deleted.%'
  AND (u.status = 3 OR u.del_flag = TRUE);

-- 确保超管 email identity 存在（V3 种子在 drop 列之前已迁移）
INSERT INTO bu_user_identity (user_id, provider, provider_uid, password_hash, created_at, created_by, updated_at, updated_by, del_flag)
SELECT u.id, 'email', 'admin@staff.local', '$2a$10$YTUeGZqQ/xrX1d9V26669ubXuH90MthjRxhXxJV5EldtWdFm0WQbS', NOW(), 0, NOW(), 0, FALSE
FROM bu_user u
WHERE u.staff_role <> 0 AND u.del_flag = FALSE
  AND NOT EXISTS (
      SELECT 1 FROM bu_user_identity i
      WHERE i.user_id = u.id AND i.provider = 'email' AND i.provider_uid = 'admin@staff.local' AND i.del_flag = FALSE
  )
LIMIT 1;
