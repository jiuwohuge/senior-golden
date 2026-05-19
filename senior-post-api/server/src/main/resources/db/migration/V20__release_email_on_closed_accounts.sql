-- 已注销(status=3)或软删(del_flag)账号释放 email UNIQUE，与 DeletedUserEmailSupport 归档形态一致。
UPDATE bu_user u
SET email = LEFT(
        LOWER(SPLIT_PART(u.email, '@', 1))
            || '+deleted.'
            || (FLOOR(EXTRACT(EPOCH FROM COALESCE(u.updated_at, u.created_at, NOW())) * 1000))::BIGINT::TEXT
            || '@'
            || SPLIT_PART(u.email, '@', 2),
        255
    ),
    updated_at = NOW()
WHERE (u.status = 3 OR u.del_flag = TRUE)
  AND POSITION('@' IN u.email) > 0
  AND LOWER(u.email) NOT LIKE '%+deleted.%';
