-- The legal website owns localization. The app only needs one URL per document.
INSERT INTO sys_config
    (config_key, config_value, config_group, description, created_at, updated_at, created_by, updated_by, del_flag)
VALUES
    ('legal.terms_url', '', 'legal', 'User Agreement / Terms of Service URL', NOW(), NOW(), 0, 0, FALSE),
    ('legal.privacy_url', '', 'legal', 'Privacy Policy URL', NOW(), NOW(), 0, 0, FALSE)
ON CONFLICT (config_key) DO NOTHING;

-- V17 briefly introduced language-specific keys. Keep migration history intact,
-- but hide those obsolete settings from active configuration screens.
UPDATE sys_config
SET del_flag = TRUE,
    updated_at = NOW(),
    updated_by = 0
WHERE config_key IN (
    'legal.terms_url_en',
    'legal.terms_url_zh',
    'legal.privacy_url_en',
    'legal.privacy_url_zh'
);
