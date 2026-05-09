-- 收件人消耗邮票提前查看运输中平邮正文
ALTER TABLE bu_letter
    ADD COLUMN IF NOT EXISTS recipient_early_open_at TIMESTAMP NULL;
COMMENT ON COLUMN bu_letter.recipient_early_open_at IS '收件人邮票提前拆信时间（运输中可读正文）';
