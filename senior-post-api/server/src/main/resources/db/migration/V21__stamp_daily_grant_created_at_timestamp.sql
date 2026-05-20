-- bu_stamp_daily_grant.created_at 为 TIMESTAMPTZ 时，MyBatis 映射 LocalDateTime 会报错；
-- 与项目其余 auditable 列一致改为 TIMESTAMP（无时区）。
ALTER TABLE bu_stamp_daily_grant
    ALTER COLUMN created_at TYPE TIMESTAMP
        USING created_at AT TIME ZONE 'UTC';
