-- 用户头像审核：0 待审核 1 通过 2 驳回
ALTER TABLE bu_user
    ADD COLUMN IF NOT EXISTS avatar_audit_status SMALLINT NOT NULL DEFAULT 0;

COMMENT ON COLUMN bu_user.avatar_audit_status IS '头像审核：0待审核 1通过 2驳回';

-- 历史已有头像视为已通过
UPDATE bu_user
SET avatar_audit_status = 1
WHERE avatar_url IS NOT NULL
  AND TRIM(avatar_url) <> '';

CREATE INDEX IF NOT EXISTS idx_bu_user_avatar_audit_status
    ON bu_user (avatar_audit_status)
    WHERE del_flag = FALSE;
