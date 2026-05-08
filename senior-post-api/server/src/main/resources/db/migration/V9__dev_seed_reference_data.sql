-- =============================================================================
-- V9: 本地/联调环境参考数据（标签、敏感词、系统与 VIP 相关配置）
-- -----------------------------------------------------------------------------
-- 用途：空库启动后快速具备可测的「名录筛选 / 配置中心 / 敏感词拦截」能力。
-- 约束：非生产基线；生产环境请按合规要求审阅或拆分迁移。
-- 幂等：依赖各表 UNIQUE 约束，使用 ON CONFLICT 合并更新。
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1) 兴趣标签 sys_tag（与名录 interestNames / tag_name 一致；含 en + zh 便于双语调试）
-- ---------------------------------------------------------------------------
INSERT INTO sys_tag (tag_name, lang_code, sort_order, created_at, updated_at, created_by, updated_by, del_flag)
VALUES
-- English (lang_code = en)，排序与产品「45+ 笔友」场景一致
('Gardening', 'en', 10, NOW(), NOW(), 0, 0, FALSE),
('Reading', 'en', 20, NOW(), NOW(), 0, 0, FALSE),
('Classical Music', 'en', 30, NOW(), NOW(), 0, 0, FALSE),
('Jazz & Blues', 'en', 40, NOW(), NOW(), 0, 0, FALSE),
('Cooking', 'en', 50, NOW(), NOW(), 0, 0, FALSE),
('Slow Travel', 'en', 60, NOW(), NOW(), 0, 0, FALSE),
('Film Photography', 'en', 70, NOW(), NOW(), 0, 0, FALSE),
('Hand Crafts', 'en', 80, NOW(), NOW(), 0, 0, FALSE),
('Birdwatching', 'en', 90, NOW(), NOW(), 0, 0, FALSE),
('Language Exchange', 'en', 100, NOW(), NOW(), 0, 0, FALSE),
('Tea & Coffee', 'en', 110, NOW(), NOW(), 0, 0, FALSE),
('Watercolor', 'en', 120, NOW(), NOW(), 0, 0, FALSE),
('Volunteering', 'en', 130, NOW(), NOW(), 0, 0, FALSE),
('Long Walks', 'en', 140, NOW(), NOW(), 0, 0, FALSE),
('World History', 'en', 150, NOW(), NOW(), 0, 0, FALSE),
('Family History', 'en', 160, NOW(), NOW(), 0, 0, FALSE),
('Postcrossing', 'en', 170, NOW(), NOW(), 0, 0, FALSE),
('Stationery', 'en', 180, NOW(), NOW(), 0, 0, FALSE),
('Radio & Podcasts', 'en', 190, NOW(), NOW(), 0, 0, FALSE),
('Museums', 'en', 200, NOW(), NOW(), 0, 0, FALSE),
-- 中文（lang_code = zh），与上组语义对应，便于 zh 客户端名录筛选联调
('园艺', 'zh', 10, NOW(), NOW(), 0, 0, FALSE),
('阅读', 'zh', 20, NOW(), NOW(), 0, 0, FALSE),
('古典音乐', 'zh', 30, NOW(), NOW(), 0, 0, FALSE),
('爵士与蓝调', 'zh', 40, NOW(), NOW(), 0, 0, FALSE),
('烹饪', 'zh', 50, NOW(), NOW(), 0, 0, FALSE),
('慢旅行', 'zh', 60, NOW(), NOW(), 0, 0, FALSE),
('胶片摄影', 'zh', 70, NOW(), NOW(), 0, 0, FALSE),
('手工艺', 'zh', 80, NOW(), NOW(), 0, 0, FALSE),
('观鸟', 'zh', 90, NOW(), NOW(), 0, 0, FALSE),
('语言交换', 'zh', 100, NOW(), NOW(), 0, 0, FALSE),
('茶与咖啡', 'zh', 110, NOW(), NOW(), 0, 0, FALSE),
('水彩', 'zh', 120, NOW(), NOW(), 0, 0, FALSE),
('志愿服务', 'zh', 130, NOW(), NOW(), 0, 0, FALSE),
('健走', 'zh', 140, NOW(), NOW(), 0, 0, FALSE),
('世界史', 'zh', 150, NOW(), NOW(), 0, 0, FALSE),
('家族史', 'zh', 160, NOW(), NOW(), 0, 0, FALSE),
('明信片交换', 'zh', 170, NOW(), NOW(), 0, 0, FALSE),
('文具', 'zh', 180, NOW(), NOW(), 0, 0, FALSE),
('广播与播客', 'zh', 190, NOW(), NOW(), 0, 0, FALSE),
('博物馆', 'zh', 200, NOW(), NOW(), 0, 0, FALSE)
ON CONFLICT (tag_name, lang_code) DO UPDATE SET
    sort_order = EXCLUDED.sort_order,
    del_flag   = FALSE,
    updated_at = NOW(),
    updated_by = 0;

-- ---------------------------------------------------------------------------
-- 2) 敏感词 sys_sensitive_word（分类 + 可人工粘贴的调试占位词，避免真实脏话入库）
-- ---------------------------------------------------------------------------
INSERT INTO sys_sensitive_word (word, type, type_text, lang_code, created_at, updated_at, created_by, updated_by, del_flag)
VALUES
-- 联调专用：在信件/帖子中粘贴该词应触发拦截（全小写匹配由服务层处理）
('__dev_sensitive_block__', 'test', '调试占位词（可安全删除）', 'en', NOW(), NOW(), 0, 0, FALSE),
('__联调敏感词占位__', 'test', '调试占位词（可安全删除）', 'zh', NOW(), NOW(), 0, 0, FALSE),
-- 常见违规类型样例（词形偏「明显垃圾模式」，降低误伤正常通信）
('click-here-casino-bonus-now', 'spam', '垃圾营销 / 诱导点击（示例）', 'en', NOW(), NOW(), 0, 0, FALSE),
('加微信私聊刷单兼职', 'spam', '站外引流 / 兼职诈骗（示例）', 'zh', NOW(), NOW(), 0, 0, FALSE),
('illegal-goods-dev-placeholder', 'illegal', '违禁品类占位（联调替换为正式词库）', 'en', NOW(), NOW(), 0, 0, FALSE),
('违禁品推广占位词', 'illegal', '违禁品类占位（联调替换为正式词库）', 'zh', NOW(), NOW(), 0, 0, FALSE),
('harassment-dev-placeholder-en', 'harassment', '骚扰类占位（联调替换为正式词库）', 'en', NOW(), NOW(), 0, 0, FALSE),
('骚扰攻击占位词', 'harassment', '骚扰类占位（联调替换为正式词库）', 'zh', NOW(), NOW(), 0, 0, FALSE),
('adult-content-dev-placeholder', 'adult', '成人不当内容占位（联调替换为正式词库）', 'en', NOW(), NOW(), 0, 0, FALSE),
('成人不当内容占位词', 'adult', '成人不当内容占位（联调替换为正式词库）', 'zh', NOW(), NOW(), 0, 0, FALSE)
ON CONFLICT (word, lang_code) DO UPDATE SET
    type       = EXCLUDED.type,
    type_text  = EXCLUDED.type_text,
    del_flag   = FALSE,
    updated_at = NOW(),
    updated_by = 0;

-- ---------------------------------------------------------------------------
-- 3) 系统配置 sys_config（注册 / 邮票 / 明信片 / VIP 展示与功能开关 — 供管理端与后续业务读取）
--    说明：当前代码已读项见 AppBootstrapService.register.min_age；其余为约定键，便于后台与产品迭代。
-- ---------------------------------------------------------------------------
INSERT INTO sys_config (config_key, config_value, config_group, description, created_at, updated_at, created_by, updated_by, del_flag)
VALUES
-- 注册与合规
('register.min_age', '45', 'register', '注册最低年龄（周岁，与 App 注册页 bootstrap 一致）', NOW(), NOW(), 0, 0, FALSE),
('register.require_email_verify', 'false', 'register', '是否强制邮箱验证（调试默认关闭）', NOW(), NOW(), 0, 0, FALSE),
-- 邮票与寄信（与 Flutter/文档约定对齐，业务代码可逐步消费）
('stamps.daily_cap_non_vip', '3', 'stamps', '非 VIP 每日可用邮票上限（展示/风控参考）', NOW(), NOW(), 0, 0, FALSE),
('stamps.registered_mail_cost', '1', 'stamps', '非 VIP 发送挂号信消耗邮票数', NOW(), NOW(), 0, 0, FALSE),
('stamps.speed_up_cost', '1', 'stamps', '平邮加速消耗邮票数（非 VIP）', NOW(), NOW(), 0, 0, FALSE),
('stamps.welcome_on_register', '3', 'stamps', '注册成功赠送邮票（占位，发放逻辑接配置后生效）', NOW(), NOW(), 0, 0, FALSE),
-- 明信片墙
('postcard.daily_publish_limit', '1', 'postcard', '每用户每日发帖上限', NOW(), NOW(), 0, 0, FALSE),
('postcard.reward_stamps_on_publish', '1', 'postcard', '发帖奖励邮票数量（0 表示关闭）', NOW(), NOW(), 0, 0, FALSE),
('postcard.review_required', 'true', 'postcard', '新帖是否默认进入待审核', NOW(), NOW(), 0, 0, FALSE),
-- VIP（管理端 VipConfig 分组；客户端可展示营销文案）
('vip.product.enabled', 'true', 'vip', '是否开放 VIP 购买/展示入口', NOW(), NOW(), 0, 0, FALSE),
('vip.product.display_name', 'Senior Post Plus', 'vip', 'VIP 产品对外名称', NOW(), NOW(), 0, 0, FALSE),
('vip.product.tagline', 'Unlimited stamps · Priority delivery · Ad-free', 'vip', '副标题/卖点（英文）', NOW(), NOW(), 0, 0, FALSE),
('vip.product.tagline_zh', '无限邮票 · 优先送达 · 无广告干扰', 'vip', '副标题/卖点（中文）', NOW(), NOW(), 0, 0, FALSE),
('vip.benefit.unlimited_stamps', 'true', 'vip', 'VIP 是否免邮票消耗（挂号/加速等以代码为准）', NOW(), NOW(), 0, 0, FALSE),
('vip.benefit.standard_delivery_hours', '0', 'vip', 'VIP 平邮「加速」剩余小时占位（0 表示即时策略由业务实现）', NOW(), NOW(), 0, 0, FALSE),
-- 系统 / 运维
('system.env_label', 'development', 'system', '环境标识（仅供管理端或日志展示）', NOW(), NOW(), 0, 0, FALSE),
('system.maintenance_mode', 'false', 'system', '全局维护模式（占位，网关/过滤器消费）', NOW(), NOW(), 0, 0, FALSE)
ON CONFLICT (config_key) DO UPDATE SET
    config_value = EXCLUDED.config_value,
    config_group = EXCLUDED.config_group,
    description  = EXCLUDED.description,
    del_flag     = FALSE,
    updated_at   = NOW(),
    updated_by   = 0;
