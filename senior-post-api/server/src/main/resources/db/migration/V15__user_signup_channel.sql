-- 开户方式：guest 静默访客可绑/换绑；email/google 注册账号不可走换绑。
ALTER TABLE bu_user
    ADD COLUMN IF NOT EXISTS signup_channel VARCHAR(16) NOT NULL DEFAULT 'guest';

COMMENT ON COLUMN bu_user.signup_channel IS '开户方式：guest | email | google；访客绑定不改此值';

-- 建号后 2 秒内已有 Google 身份 → Google 开户（优先于邮箱，避免 Google 同时写 email identity 被判成 email）。
UPDATE bu_user u
SET signup_channel = 'google'
WHERE EXISTS (
    SELECT 1
    FROM bu_user_identity i
    WHERE i.user_id = u.id
      AND i.del_flag = FALSE
      AND i.provider = 'google'
      AND i.created_at <= u.created_at + INTERVAL '2 seconds'
);

-- 其余：建号后 2 秒内已有邮箱身份 → 邮箱注册。
UPDATE bu_user u
SET signup_channel = 'email'
WHERE u.signup_channel = 'guest'
  AND EXISTS (
    SELECT 1
    FROM bu_user_identity i
    WHERE i.user_id = u.id
      AND i.del_flag = FALSE
      AND i.provider = 'email'
      AND i.created_at <= u.created_at + INTERVAL '2 seconds'
);
