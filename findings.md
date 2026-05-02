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

### 2.1 App 信箱 API（`client`）

`AppMailboxApi.java` 当前仅有：

- `GET .../mailbox/postal`
- `GET .../mailbox/sync`
- `GET .../mailbox/archive`
- `POST .../mailbox/letters/{letterId}/accept-postal`

**未发现**「创建信件 / 发送挂号信或平邮」的契约方法 — 与 PLAN「写信主流程」及 A5 联调描述一致：**发信写库仍为待办**。

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
| GET | `/api/auth/me` |
| GET | `/api/bootstrap/init` |
| GET | `/api/mailbox/postal`、`/api/mailbox/sync`、`/api/mailbox/archive` |
| POST | `/api/mailbox/letters/{letterId}/accept-postal` |
| POST | `/api/mailbox/letters/send`（body：`AppSendLetterInDto`：`toUserId`、`content`、`letterType` 1=挂号 2=平邮） |
| GET | `/api/im/usersig` |
| GET | `/api/oss/put-sign`（需登录；`scene=postcard|avatar|letter`，`ext` 可选） |
| GET | `/api/stamps/balance` |
| POST | `/api/stamps/ledger/paging`（body：`AppStampLedgerPageInDto` 含 `page`） |

**缺口**：无 `AppPostcard*`、`AppComment*`、`AppDirectory*`、`AppReport*` 等；**已有** `AppOssApi`、`AppStampsApi`；**发信**已并入 `AppMailboxApi.sendLetter`（2026-05-02）。

### 5.2 管理端已实现 HTTP（抽样）

`/webapi/auth/*`、`/webapi/user/*`、`/webapi/content/postcard/*`、`/webapi/content/comment/*`、`/webapi/report/*`、`/webapi/config/*`、`/webapi/country/*`、`/webapi/sensitive-word/*`、`/webapi/version/*`、`/webapi/announcement/*`、`/webapi/dashboard/summary`、`/webapi/log/action/paging`、`/webapi/log/login/paging`。

### 5.3 Flutter `features` 完成度（相对 `AppEnv.useMock`）

| Feature | 数据层 |
|---------|--------|
| `auth` | Mock 或真实 `dio` 二轨；忘记密码页存在但后端 `AppAuthController` 无对应端点 |
| `post_wall` | 完全 Mock |
| `directory` | 完全 Mock |
| `mailbox`（信件） | 完全 Mock；TIM 在非 Mock 下接 `usersig` |
| `profile` | 完全 Mock |

### 5.4 Manage 小缺口（再次确认）

- `api.ts` 中 `blockDevice` 已定义，`UserList` 未调用。
- 无「邮票流水」独立管理页与 `/webapi` 绑定。

### 5.5 文档索引

执行层规划见 [`task_plan.md`](task_plan.md) 与 [`doc/plan/01-feature-list.md`](doc/plan/01-feature-list.md) 起共 6 份。
