# Phase B — 建议项独立 PR 拆分（执行顺序可调整）

| PR | 范围 | 说明 |
|----|------|------|
| B1 | Flutter `PostalOssNetworkImage` / 可选 `cached_network_image` | 磁盘缓存、签名 URL 去重、减少切换闪白 |
| B2 | `post_compose_page` + 公共裁剪组件 | 「+」上传入口、矩形比例裁剪 |
| B3 | 明信片评论策略 + 可选客户端敏感词 | 需产品确认「待审评论」是否展示；端侧过滤仅作辅助 |
| B4 | OSS/云审核或异步人工审核 | 端侧完整鉴黄不推荐作为主方案 |
| B5 | 腾讯 IM 系统号 + 审核拒绝通知 | 禁回、模板消息、与审核流联动 |
| B6 | `UserBlacklist` App API + Flutter | 拉黑/取消、详情入口、墙与发信拦截 |
| B7 | 反馈表 + Flutter「我的帖子」+ 管理端列表 | 与 B8 命名统一 |
| B8 | 管理端文案 | 「举报工单」改为「明信片举报」（`senior-post-manage/src/pages/AdminLayout.tsx`） |
| B9 | 用户资料 bio / 时间轴 | 评估字段与 PRD 后再动表结构 |
