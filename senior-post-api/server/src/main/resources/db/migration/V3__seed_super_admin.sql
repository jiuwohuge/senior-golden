-- 可登录管理端的种子用户：staff_role 非 0 即可（暂不分角色）；登录邮箱 admin@staff.local（用户名填 admin 会自动补全）
-- 密码与 BCryptPasswordEncoder 一致  admin/Admin@123456
INSERT INTO bu_user (
    email,
    password_hash,
    nickname,
    birth_year,
    status,
    staff_role,
    created_by,
    updated_by,
    del_flag
)
VALUES (
    'admin@staff.local',
    '$2a$10$YTUeGZqQ/xrX1d9V26669ubXuH90MthjRxhXxJV5EldtWdFm0WQbS',
    '超级管理员',
    1990,
    1,
    1,
    0,
    0,
    FALSE
)
ON CONFLICT (email) DO UPDATE SET
    password_hash = EXCLUDED.password_hash,
    nickname      = EXCLUDED.nickname,
    status        = EXCLUDED.status,
    del_flag      = FALSE,
    updated_at    = NOW(),
    updated_by    = 0;
