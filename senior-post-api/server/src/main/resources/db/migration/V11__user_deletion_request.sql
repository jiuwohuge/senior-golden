-- 账号注销冷静期：提交时间；7 日内成功登录会清空该字段（撤销申请）
ALTER TABLE bu_user ADD COLUMN IF NOT EXISTS deletion_requested_at TIMESTAMP;
COMMENT ON COLUMN bu_user.deletion_requested_at IS '用户申请注销时间；冷静期内再次登录可清空；满7天未登录则 status=注销';
