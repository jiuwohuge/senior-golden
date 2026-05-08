-- 平邮到期扫描：运输中 + 平邮 + 预计送达时间
CREATE INDEX IF NOT EXISTS idx_bu_letter_standard_due
    ON bu_letter (expected_arrival_time ASC)
    WHERE del_flag = FALSE AND letter_type = 2 AND status = 1;

COMMENT ON INDEX idx_bu_letter_standard_due IS '平邮自动送达定时任务按 expected_arrival_time 扫描';
