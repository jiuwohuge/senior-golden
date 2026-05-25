ALTER TABLE bu_postcard
    ADD COLUMN IF NOT EXISTS machine_review_note TEXT;

ALTER TABLE bu_postcard
    ADD COLUMN IF NOT EXISTS machine_reviewed_at TIMESTAMP;

COMMENT ON COLUMN bu_postcard.machine_review_note IS '机审摘要（百度/DeepSeek），供管理端复核';
COMMENT ON COLUMN bu_postcard.machine_reviewed_at IS '机审完成时间';
