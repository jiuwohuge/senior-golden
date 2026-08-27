-- Legal documents are hosted as static pages. English is the default;
-- Chinese URLs fall back to English when left blank.
INSERT INTO sys_config
    (config_key, config_value, config_group, description, created_at, updated_at, created_by, updated_by, del_flag)
VALUES
    ('legal.terms_url_en', '', 'legal', 'Terms of Service URL (English/default)', NOW(), NOW(), 0, 0, FALSE),
    ('legal.terms_url_zh', '', 'legal', '用户协议 URL（中文；空则回退英文）', NOW(), NOW(), 0, 0, FALSE),
    ('legal.privacy_url_en', '', 'legal', 'Privacy Policy URL (English/default)', NOW(), NOW(), 0, 0, FALSE),
    ('legal.privacy_url_zh', '', 'legal', '隐私政策 URL（中文；空则回退英文）', NOW(), NOW(), 0, 0, FALSE)
ON CONFLICT (config_key) DO NOTHING;
