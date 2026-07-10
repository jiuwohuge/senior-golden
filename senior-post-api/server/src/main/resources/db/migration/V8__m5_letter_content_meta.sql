-- M5: letter presentation metadata (skin/font/template)

ALTER TABLE bu_letter ADD COLUMN IF NOT EXISTS content_meta_json JSONB;

COMMENT ON COLUMN bu_letter.content_meta_json IS '表达增强元数据：skinId/fontId/templateId 等';
