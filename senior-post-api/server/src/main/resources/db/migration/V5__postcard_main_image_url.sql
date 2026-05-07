-- 明信片首张配图冗余列（V5 若为空脚本已执行，此处幂等补齐）
ALTER TABLE bu_postcard
    ADD COLUMN IF NOT EXISTS main_image_url VARCHAR(1024);

COMMENT ON COLUMN bu_postcard.main_image_url IS '首张配图 URL（冗余，与 images JSON 同步）';
