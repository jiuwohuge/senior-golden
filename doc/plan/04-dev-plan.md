# 04 — 开发计划（技术方案摘要 + 人日 + 风险）

> **文档元信息**  
> **版本**：1.3 · **更新**：2026-05-09 · **维护人**：AI + Owner

**人日（D）**：单人全职粗估，含自测与文档；并行可压缩日历时间。  
**资源**：默认 `AI + Owner`；若拆角色，后端/Flutter/Manage 列在「协作」列。

> **2026-05-09**：与 Owner 裁剪对齐——删除 E2E 独立人日、B14/B15、强更叙事；平邮送达以 **PG 定时**为准；Sprint 4 优先 **A1-006 / X-001 / A1-007 / X-003 / A10-001**。

---

## Sprint 1 — P0 后端（约 8–12 D）

| FP | 后端方案摘要 | Flutter / Manage | D | 协作 | 主要风险 |
|----|----------------|------------------|---|------|----------|
| FP-X-002 | 新增 `AppOssApi`：`GET`/`POST` 返回 policy、host、key、签名；配置 `accessKeyId` 等走 Spring；**不落库** | Flutter：`dio` 取签 → `put` 上传；进度与失败重试 | 1.5 | Owner | 密钥泄露面；签名校验与时钟偏移 |
| FP-A3-001 | `AppPostcardController` + Service：`paging` 仅 `review_status` 通过；`PageQuery` | 列表接 Provider + 下拉刷新 | 2 | AI+Owner | SQL 遗漏导致未审泄露 |
| FP-A3-002 | `getById` + 权限过滤 | 详情页 | 0.5 | AI | N+1 查询 |
| FP-A3-003 | `create`：写 `bu_postcard` 待审；可选敏感词 | 发帖表单 multipart 或 JSON+URL | 2 | AI+Owner | 大图片超时 |
| FP-A3-004 | 评论 `paging` + `create` | 评论列表与输入框 | 1.5 | AI | 与审核字段一致 |
| FP-A5-001 | `AppLetterApi.send`：`LetterService` 内校验余额/VIP、写 `bu_letter`、写 `stamp_transaction`、触发延迟任务 | `send_letter_sheet` 调接口 + invalidate | 2.5 | AI+Owner | **事务边界**与并发超卖 |
| FP-A6-001 | `GET /api/stamps/balance` 或并入 bootstrap/me 扩展字段 | 顶栏读 Provider | 0.5 | AI | 与 `me` 字段重复需定一种 |
| FP-A6-004 | 抽 `StampAccountService.deduct(reason, letterId)` 幂等 | — | 含于 A5-001 | AI | 死锁顺序 |
| FP-A2-001 | `PATCH /api/user/profile`（示例路径）或扩展 `me` 写；MapStruct 更新 | `profile_edit` 接 REST | 1.5 | AI | 与注册 DTO 字段重复 |
| FP-A4-001 | `AppDirectoryApi.paging` + Query DTO | `directory_page` | 1.5 | AI | 排序索引 |

**Sprint 1 缓冲**：+2 D 联调与 Knife4j 示例。

---

## Sprint 2 — P0 Flutter + 联调（约 8–10 D）

| FP | 方案摘要 | D | 风险 |
|----|----------|---|------|
| 接线与远程默认 | Mock 层已删；各 feature 固定 `dio` + TIM | 0.5 | 回归面 |
| FP-A3-* UI | `post_wall` / `post_detail` / `post_compose` 全接；空态/审核态 | 3 | 图片压缩与内存 |
| FP-A5-* UI | `mailbox_providers` 接 postal/sync/archive；`letter_detail` 接详情 | 2 | DTO 与 Mock 模型映射 |
| FP-A2 / A4 UI | profile、directory 接 REST | 2 | 表单校验一致 |

---

## Sprint 3 — P1（约 10–14 D）

| FP | 后端方案摘要 | 前端 | D | 风险 |
|----|----------------|------|---|------|
| FP-A5d-002 | **`@Scheduled` + PG** 条件更新到期平邮；**不**使用 Redis ZSET（已定案） | 列表 sync / 刷新 | 1.5 | 幂等与索引 |
| FP-A5-005 | `POST .../letters/{id}/speed-up` | Speed Up Sheet | 1 | 与 VIP 分支 |
| FP-A5d-004 | `TencentImFriendshipNotifier` 调官方 REST；重试与降级 | — | 2 | 密钥与限频 |
| FP-A6-002/003 | 流水分页；登录/发帖 Hook 赠邮票 | `stamps_ledger` | 2 | 日上限边界 |
| FP-A7-* | **A7-001** 已并入 `vipProduct`；**A7-003** 扣费与配置/`me`/调试 VIP 一致；**真订阅不做** | `vip_center` | 1 | 与 `vip-debug` 一致 |
| FP-A4-002~004 | Query 扩展 | Filter sheet | 1.5 | — |
| FP-A3-005 | `POST /api/report` | 举报入口 | 1 | 防刷 |

---

## Sprint 4 — P2/P3（约 8–12 D）

| FP | 方案摘要 | D | 风险 |
|----|----------|---|------|
| FP-X-001 | `EmailService` + outbox 表；与重置密码、后续通知共用 | 3 | 垃圾邮件信誉 |
| FP-A1-003 | forgot token 表 + 邮件模板 + reset | 2 | 令牌泄露 |
| FP-A1-006 | 设备写入路径与 `user_device` 一致性核对 + 修正 | 1.5 | 与挤下线/拉黑联动 |
| FP-A1-007 | Flutter 加解密拦截器对齐 `jh.security` | 2 | 调试困难 |
| FP-A8-005 | 注销 MVP（已交付，见 `08`） | — | — |
| FP-X-003 | **可关闭**公告弹层 + Manage **结构化表单**（标题、版本号展示、纯文本多行正文）；**非**强更拦截 | 2 | 字段校验；正文禁止 HTML |
| FP-A10-001 | 邮件模板 `MessageSource` + Locale（依赖 X-001） | 1 | 与 `app.properties` 键对齐 |
| FP-A9-002/003 | 邮票流水页；设备列表与拉黑 | DONE | — |

---

## 技术决策建议（落地前写入 findings 或 ADR）

1. **发信路径命名**：`/api/mailbox/letters/send` 与现有 `mailbox` 前缀一致 vs 独立 `/api/letters` — 定一种后全仓统一。
2. **余额来源**：只 `me` 扩展 vs 独立 stamps API — 避免双源。
3. **幂等键**：客户端 `Idempotency-Key` 头 vs body `requestId` — 与网关兼容。

---

## 资源需求汇总

| 类型 | 说明 |
|------|------|
| 人力 | 默认 1 全栈 + AI；Sprint 2 起建议固定半日联调窗口 |
| 环境 | 见 [06-env-setup.md](06-env-setup.md) |
| 外部账号 | 腾讯 IM、阿里云 OSS、SMTP（或 SendGrid）测试账号 |
| 工具 | Knife4j、Postman 集合、Flutter DevTools |
