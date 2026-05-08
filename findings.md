# 研究发现（规划会话 · 2026-05-02）

本文档记录**从仓库内可验证事实**归纳的「未实现 / 部分实现」结论，供 `task_plan.md` 引用。

---

## 1. PLAN.md 中仍为未勾选的功能清单

| 编号 | 摘要 | 备注 |
|------|------|------|
| A1 | 账号注册登录全流程 | 部分已做：bootstrap、注册、me、85xx；资料完善/忘记密码等见 M1/M4 |
| A2 | 用户资料中心 | Profile 已有真实 bootstrap/me 联调痕迹；编辑资料等未在清单勾完成 |
| A3 | Post Wall | 未勾选 |
| A4 | Post Directory | 未勾选 |
| A5 | Post Box 发信/拉信全量 REST | **明确写「仍待联调」**；A5-IM 已勾选 |
| A6 | Chat Stamp 账本与规则 | 未勾选 |
| A7 | VIP 权益 | 未勾选 |
| A8 | 风控与合规 | 未勾选 |
| A9 | 管理后台 | 未勾选（工程已有大量页面，与「全量验收」有别） |
| A10 | 国际化 | 未勾选 |

---

## 2. 代码与契约层面的缺口（抽样）

### 2.1 App 信箱 API（`client`）— 2026-05-07 勘误

**历史结论（2026-05-02）已过期**：当时 `AppMailboxApi` 未暴露发信。当前仓库已包含（与 §5.1 一致）：

- `POST .../mailbox/letters/send`、`GET .../mailbox/letters/{letterId}`、加速等扩展。

**仍待验收的**是双用户场景下 **postal/sync 一致性**（见 `doc/plan/07` FP-A5-002），而非「缺发信契约」。

### 2.2 Flutter 信箱数据

- `mailbox_providers.dart`：在 `AppEnv.useMock` 为真时使用 `MockMailboxRepository`；非 Mock 路径需接真实 API（与 A5 一致）。
- `mailbox_page.dart`：Connections 在非 Mock 下走 TIM 会话列表。

### 2.3 状态位

- `PLAN.md` **S9**：M2 帖子/目录/写信主链路 — **未勾选**。
- **B14 / B15**：视觉与登录规范 — **未勾选**。

---

## 3. 已相对成熟的部分（避免重复规划）

- Flyway、JWT、`/api` 与 `/webapi`、bootstrap、注册登录部分链路。
- 邮政 Tab UI 分段、归档、TIM facade、chat 页、Mock 建联与 `mailbox_models_test`（见 PLAN A5-IM 与改动预测 2026-05-02）。
- 管理端：配置、国家、VIP 页等（PLAN 改动预测中有记录）。

---

## 4. 待用户/产品确认（非代码可解）

- 忘记密码是否在首发范围（PLAN 邮件能力已规划密码重置）。
- IM 好友同步占位替换为正式策略的时间点（与发信/建联顺序）。

---

## 5. 摸底补充（2026-05-02 · 文档体系落地前核对）

### 5.1 App 已实现 HTTP（`client/api/app` 实现类）

| 方法 | 路径 |
|------|------|
| POST | `/api/auth/register`、`/api/auth/login` |
| POST | `/api/auth/forgot-password`（body：`email`；防枚举） |
| POST | `/api/auth/reset-password`（body：`email`、`code` 6 位、`newPassword`） |
| GET | `/api/auth/me` |
| GET | `/api/bootstrap/init` |
| GET | `/api/mailbox/postal`、`/api/mailbox/sync`、`/api/mailbox/archive` |
| POST | `/api/mailbox/letters/{letterId}/accept-postal` |
| POST | `/api/mailbox/letters/send`（body：`AppSendLetterInDto`：`toUserId`、`content`、`letterType` 1=挂号 2=平邮） |
| GET | `/api/mailbox/letters/{letterId}`（详情，含 `content` 正文） |
| GET | `/api/mailbox/peers/{peerUserId}/friendship-active`（是否已建联） |
| GET | `/api/im/usersig` |
| GET | `/api/oss/put-sign`（需登录；`scene=postcard|avatar|letter`，`ext` 可选） |
| GET | `/api/stamps/balance` |
| POST | `/api/stamps/ledger/paging`（body：`AppStampLedgerPageInDto` 含 `page`） |

**平邮自动送达（2026-05-07）**：`StandardLetterDeliveryScheduler` 定时将 `expected_arrival_time` 已到的平邮（`letter_type=2`,`status=1`）更新为已送达并写 `actual_arrival_time`；幂等条件 UPDATE。Redis ZSET 未接，可后续优化扫表。

**缺口（相对首发清单）**：敏感词写路径、邮件/outbox、AES 全链、部分 Manage 运营页等；**client 已存在** `AppPostcardApi`、`AppDirectoryApi`、`AppReportApi` 等（与 Flutter `post_wall` / `directory` 真接口联调进度以 [`01-feature-list.md`](doc/plan/01-feature-list.md) 为准）。

### 5.2 管理端已实现 HTTP（抽样）

`/webapi/auth/*`、`/webapi/user/*`、`/webapi/content/postcard/*`、`/webapi/content/comment/*`、`/webapi/report/*`、`/webapi/config/*`、`/webapi/country/*`、`/webapi/sensitive-word/*`、`/webapi/version/*`、`/webapi/announcement/*`、`/webapi/dashboard/summary`、`/webapi/log/action/paging`、`/webapi/log/login/paging`。

### 5.3 Flutter `features` 完成度（相对 `AppEnv.useMock`）— 2026-05-07 勘误

**口径**：下表描述「Mock 分支 vs 非 Mock 分支」的粗粒度事实；**与 `01-feature-list` 中各 FP 勾选不一致时，以 `01` + [`07-gap-analysis-and-roadmap.md`](doc/plan/07-gap-analysis-and-roadmap.md) 为准**（避免「完全 Mock」与已接线 REST 并存时产生歧义）。

| Feature | 数据层 |
|---------|--------|
| `auth` | Mock 或真实 `dio` 二轨；**FP-A1-003** 已接 `forgot-password` / `reset-password`；**FP-X-001** 全量 outbox 仍可选 |
| `post_wall` | `USE_MOCK=false` 时走 `post_wall_remote` 等真实 API（多图/举报等迭代见 `01`）；Mock 分支仍保留 |
| `directory` | `USE_MOCK=false` 时走名录分页等真实 API；发信已接真实 API |
| `mailbox`（信件） | **`USE_MOCK=false` 时**：`mailbox_remote` 接 postal/archive/详情/发信/建联/好友判断/`speed-up`；顶栏邮票接 `/api/stamps/balance`；**回信**仍待产品化（见 `07`） |
| `profile` | `USE_MOCK=false` 时 bootstrap/me/PATCH profile 已有多处接线；头像 OSS 写回等见 **FP-A2-002** |

### 5.4 Manage 小缺口（再次确认）

- `api.ts` 中 `blockDevice` 已定义，`UserList` 未调用。
- 无「邮票流水」独立管理页与 `/webapi` 绑定。

### 5.5 文档索引

执行层规划见 [`task_plan.md`](task_plan.md) 与 [`doc/plan/01-feature-list.md`](doc/plan/01-feature-list.md) 起共 **7** 份（含 [`07-gap-analysis-and-roadmap.md`](doc/plan/07-gap-analysis-and-roadmap.md) 遗漏清单与路线图）。

---

## 6. OSS 私有读（2026-05-08）

**已存在事实**：仅 [`AppOssServiceImpl`](senior-post-api/biz/src/main/java/cn/nine/pros/post/biz/service/app/impl/AppOssServiceImpl.java) 签发 **PUT** 预签名；`OssPutSignResultVO.readUrl` 依赖 `senior-post.oss.public-read-base-url`，**私有桶下应为空**，否则客户端误用不可匿名访问的拼接 URL。

**缺口**：无 **GET** 预签名接口；`PostcardWallItemVO` / `avatarUrl` 等若落库为不可读 URL，则 App `Image.network` 与后续 Web 审核台均无法稳定展示。

**改造原则（与产品对齐）**：首发 **不做** 匿名公共前缀；读链路由服务端换签 + 短 TTL + objectKey 白名单与业务权限校验。

**执行跟踪**：`task_plan.md`「OSS 私有读改造」子阶段 O1–O7；FP **FP-X-005**（`05-task-tracker.md`）。
