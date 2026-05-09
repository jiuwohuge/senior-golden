-- 历史数据：收件人已提前拆信但 status 仍为运输中，导致 App 列表与详情/归档状态不一致
UPDATE bu_letter
SET status                 = 2,
    actual_arrival_time    = COALESCE(actual_arrival_time, recipient_early_open_at),
    updated_at             = NOW()
WHERE del_flag = FALSE
  AND letter_type = 2
  AND status = 1
  AND recipient_early_open_at IS NOT NULL;
