-- M4: penpal request, daily recommendation, relation config seeds

CREATE TABLE bu_penpal_request (
    id               BIGSERIAL PRIMARY KEY,
    requester_id     BIGINT NOT NULL,
    target_id        BIGINT NOT NULL,
    status           SMALLINT NOT NULL DEFAULT 1,
    source_letter_id BIGINT,
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by       BIGINT,
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by       BIGINT,
    del_flag         BOOLEAN NOT NULL DEFAULT FALSE
);
COMMENT ON TABLE bu_penpal_request IS '笔友申请；status 1=PENDING 2=ACCEPTED 3=IGNORED';
CREATE INDEX idx_bu_penpal_request_target_pending
    ON bu_penpal_request (target_id, status)
    WHERE del_flag = FALSE AND status = 1;
CREATE UNIQUE INDEX ux_bu_penpal_request_pending_pair
    ON bu_penpal_request (requester_id, target_id)
    WHERE del_flag = FALSE AND status = 1;

CREATE TABLE bu_daily_recommendation (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    target_user_id  BIGINT NOT NULL,
    recommend_date  DATE NOT NULL,
    score           DOUBLE PRECISION,
    reason_key      VARCHAR(100),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by      BIGINT,
    del_flag        BOOLEAN NOT NULL DEFAULT FALSE
);
COMMENT ON TABLE bu_daily_recommendation IS '每日推荐笔友快照（同日幂等）';
CREATE UNIQUE INDEX ux_bu_daily_rec_user_target_date
    ON bu_daily_recommendation (user_id, target_user_id, recommend_date)
    WHERE del_flag = FALSE;
CREATE INDEX idx_bu_daily_rec_user_date
    ON bu_daily_recommendation (user_id, recommend_date DESC)
    WHERE del_flag = FALSE;

INSERT INTO sys_config (config_key, config_value, config_group, description, created_at, updated_at, created_by, updated_by, del_flag)
VALUES
('penpal.min_exchange_count', '2', 'penpal', '加笔友所需双向往来信件最小数量', NOW(), NOW(), 0, 0, FALSE),
('recommend.daily_count', '5', 'recommend', '笔友页每日推荐用户数（3~5 可配）', NOW(), NOW(), 0, 0, FALSE)
ON CONFLICT (config_key) DO UPDATE SET
    config_value = EXCLUDED.config_value,
    config_group = EXCLUDED.config_group,
    description  = EXCLUDED.description,
    del_flag     = FALSE,
    updated_at   = NOW(),
    updated_by   = 0;
