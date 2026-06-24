-- sender_snapshot_json：JSONB -> TEXT，与 bu_postcard.images 一致，兼容 MyBatis JacksonTypeHandler
ALTER TABLE bu_time_letter
    ALTER COLUMN sender_snapshot_json TYPE TEXT USING sender_snapshot_json::TEXT;

COMMENT ON COLUMN bu_time_letter.sender_snapshot_json IS '发件人快照（JSON 字符串）';
