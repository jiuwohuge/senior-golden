-- 收件人「已读」时间：用于笔友场景下邮政收件箱与归档分流（已送达但未打开详情则仍占收件箱）
ALTER TABLE bu_letter
    ADD COLUMN IF NOT EXISTS recipient_read_at TIMESTAMP NULL;
COMMENT ON COLUMN bu_letter.recipient_read_at IS '收件人首次已读（打开详情且已送达）或提前拆信成功时写入；与 postal 列表过滤配合';
