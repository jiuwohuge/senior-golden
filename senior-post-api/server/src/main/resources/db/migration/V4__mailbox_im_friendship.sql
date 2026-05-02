-- 邮政信箱 × IM：发送模式、好友关系（建联后走 TIM C2C）

ALTER TABLE bu_letter
    ADD COLUMN IF NOT EXISTS send_mode SMALLINT NOT NULL DEFAULT 1;

COMMENT ON COLUMN bu_letter.send_mode IS '1=standard_post 2=registered_mail 3=direct_vip';

UPDATE bu_letter
SET send_mode = CASE WHEN letter_type = 1 THEN 2 ELSE 1 END
WHERE send_mode = 1;

COMMENT ON COLUMN bu_letter.status IS '1=delivering 2=delivered 3=registered';

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

COMMENT ON TABLE bu_friendship IS '邮政建联后的好友关系；user_low < user_high';
COMMENT ON COLUMN bu_friendship.status IS '1=active';
COMMENT ON COLUMN bu_friendship.source_letter_id IS '触发建联的信件ID（如首次 accept）';
