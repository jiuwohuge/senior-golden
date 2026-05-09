-- 邮票赠送幂等与上限（FP-A6-003）：按 UTC 日期与用户维度记录每日登录赠票、按明信片 ID 去重的发帖奖励。

CREATE TABLE IF NOT EXISTS bu_stamp_daily_grant (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT                   NOT NULL,
    grant_day       DATE                     NOT NULL,
    grant_kind      VARCHAR(16)              NOT NULL,
    ref_id          BIGINT,
    amount          INT                      NOT NULL,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ck_stamp_grant_login_no_ref CHECK (grant_kind <> 'LOGIN' OR ref_id IS NULL),
    CONSTRAINT ck_stamp_grant_postcard_ref CHECK (grant_kind <> 'POSTCARD' OR ref_id IS NOT NULL)
);

COMMENT ON TABLE bu_stamp_daily_grant IS '邮票赠送幂等：LOGIN 每日一行；POSTCARD 每个 postcardId 一行';

CREATE UNIQUE INDEX uk_stamp_daily_login ON bu_stamp_daily_grant (user_id, grant_day)
    WHERE grant_kind = 'LOGIN';

CREATE UNIQUE INDEX uk_stamp_postcard_once ON bu_stamp_daily_grant (user_id, ref_id)
    WHERE grant_kind = 'POSTCARD';

CREATE INDEX idx_stamp_postcard_day ON bu_stamp_daily_grant (user_id, grant_day)
    WHERE grant_kind = 'POSTCARD';
