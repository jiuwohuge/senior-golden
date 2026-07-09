-- bu_time_letter 时间列为 TIMESTAMPTZ 时，MyBatis 映射 LocalDateTime 会报错；
-- 与项目其余 auditable / 业务时间列一致改为 TIMESTAMP（无时区）。
ALTER TABLE bu_time_letter
    ALTER COLUMN sealed_at TYPE TIMESTAMP
        USING sealed_at AT TIME ZONE 'UTC',
    ALTER COLUMN delivered_at TYPE TIMESTAMP
        USING delivered_at AT TIME ZONE 'UTC',
    ALTER COLUMN read_at TYPE TIMESTAMP
        USING read_at AT TIME ZONE 'UTC',
    ALTER COLUMN cancel_deadline_at TYPE TIMESTAMP
        USING cancel_deadline_at AT TIME ZONE 'UTC',
    ALTER COLUMN cancelled_at TYPE TIMESTAMP
        USING cancelled_at AT TIME ZONE 'UTC',
    ALTER COLUMN created_at TYPE TIMESTAMP
        USING created_at AT TIME ZONE 'UTC',
    ALTER COLUMN updated_at TYPE TIMESTAMP
        USING updated_at AT TIME ZONE 'UTC';
