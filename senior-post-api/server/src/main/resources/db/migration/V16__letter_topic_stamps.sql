-- 信件主题邮票：与兴趣标签分栏，本轮不参与匹配算法。
ALTER TABLE sys_tag
    ADD COLUMN IF NOT EXISTS tag_kind VARCHAR(32) NOT NULL DEFAULT 'interest';

ALTER TABLE sys_tag
    ADD COLUMN IF NOT EXISTS tag_code VARCHAR(64);

COMMENT ON COLUMN sys_tag.tag_kind IS 'interest=兴趣目录；letter_topic=写信主题邮票';
COMMENT ON COLUMN sys_tag.tag_code IS '稳定业务码；兴趣旧数据可为空';

CREATE UNIQUE INDEX IF NOT EXISTS uk_sys_tag_lang_code
    ON sys_tag (lang_code, tag_code)
    WHERE tag_code IS NOT NULL AND del_flag = FALSE;

ALTER TABLE bu_letter
    ADD COLUMN IF NOT EXISTS topic_tag_id BIGINT;

COMMENT ON COLUMN bu_letter.topic_tag_id IS '写信主题邮票 sys_tag.id，可空，本轮不参与匹配';

-- 时光信走 bu_time_letter，主题同样落库，避免封缄丢票。
ALTER TABLE bu_time_letter
    ADD COLUMN IF NOT EXISTS topic_tag_id BIGINT;

COMMENT ON COLUMN bu_time_letter.topic_tag_id IS '写信主题邮票 sys_tag.id，可空，本轮不参与匹配';

-- 中英各 5 枚主题邮票（按 lang+code 幂等）
INSERT INTO sys_tag (tag_kind, tag_code, tag_name, lang_code, sort_order, created_at, updated_at, created_by, updated_by, del_flag)
SELECT v.tag_kind, v.tag_code, v.tag_name, v.lang_code, v.sort_order, NOW(), NOW(), 0, 0, FALSE
FROM (VALUES
          ('letter_topic', 'heart_talk', '心事倾诉', 'zh', 10),
          ('letter_topic', 'life_share', '生活分享', 'zh', 20),
          ('letter_topic', 'interest_exchange', '兴趣交流', 'zh', 30),
          ('letter_topic', 'life_puzzle', '人生困惑', 'zh', 40),
          ('letter_topic', 'just_chat', '随便聊聊', 'zh', 50),
          ('letter_topic', 'heart_talk', 'What''s on my mind', 'en', 10),
          ('letter_topic', 'life_share', 'Life lately', 'en', 20),
          ('letter_topic', 'interest_exchange', 'Shared interests', 'en', 30),
          ('letter_topic', 'life_puzzle', 'A question about life', 'en', 40),
          ('letter_topic', 'just_chat', 'Just saying hello', 'en', 50)
     ) AS v(tag_kind, tag_code, tag_name, lang_code, sort_order)
WHERE NOT EXISTS (
    SELECT 1
    FROM sys_tag t
    WHERE t.del_flag = FALSE
      AND t.lang_code = v.lang_code
      AND t.tag_code = v.tag_code
);
