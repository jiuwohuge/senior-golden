-- 将 bu_postcard.images 从 TEXT[] 改为 TEXT，存 JSON 数组字符串，便于 MyBatis TypeHandler 读写多图
ALTER TABLE bu_postcard
    ALTER COLUMN images TYPE TEXT USING (
        CASE
            WHEN images IS NULL THEN NULL
            WHEN cardinality(images) = 0 THEN '[]'
            ELSE array_to_json(images)::TEXT
            END
        );

COMMENT ON COLUMN bu_postcard.images IS '配图 URL 列表（JSON 数组字符串）';
