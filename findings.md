# 研究发现（规划会话）

> **文档元信息**  
> **版本**：1.3 · **更新**：2026-05-09 · **维护人**：AI + Owner

本文档记录**从仓库内可验证事实**归纳的约束、缺口与勘误，供 `task_plan.md` 与 `doc/plan/*` 引用。

---

## 1. 文档真源与 `PLAN.md` 的关系（2026-05-09）

| 说明 | 内容 |
|------|------|
| **功能完成度真源** | **`doc/plan/01-feature-list.md`** + **`doc/plan/05-task-tracker.md`**（FP 行状态与交付物）。 |
| **`PLAN.md`** | 架构、技术栈、里程碑叙述；**[功能清单]、[状态] S9/S11** 已于 **2026-05-09** 与代码对齐（见 `progress.md` 同日条目）。 |
| **本文件** | 代码证据与横切约束（OSS、IM、设备 UI 等）；**不替代** `01` 的 FP 勾选。 |

---

## 2. 代码与契约层面的缺口（抽样）

### 2.1 App 信箱 API（`client`）— 2026-05-07 勘误

**历史结论（2026-05-02）已过期**：当时 `AppMailboxApi` 未暴露发信。当前仓库已包含（与 §5.1 一致）：

- `POST .../mailbox/letters/send`、`GET .../mailbox/letters/{letterId}`、加速等扩展。

**仍建议**双机场景回归 **postal/sync** 与业务预期（`05` FP-A5-002 已标 DONE），而非「缺发信契约」。

### 2.2 Flutter 信箱数据

- `mailbox_providers.dart`：在 `AppEnv.useMock` 为真时使用 `MockMailboxRepository`；**`USE_MOCK=false` 时已接** `mailbox_remote` REST。
- `mailbox_page.dart`：**Connections** = **邮政好友列表**（`GET /api/mailbox/friends`，数据源 `bu_friendship`），**不是** TIM `getConversationList` 会话列表；点击进入聊天仍用 TIM C2C。

### 2.3 状态位（文档侧）

- **`PLAN.md` S9**：已于 **2026-05-09** 勾选为完成（M2 REST 主链路已落地）；**E2E/UAT（FP-A9-004）** 仍待。
- **B14 / B15**：视觉与登录规范 — **未勾选**（仍为产品/设计债）。

---

## 3. 已相对成熟的部分（避免重复规划）

- Flyway、JWT、`/api` 与 `/webapi`、bootstrap、注册登录部分链路。
- 邮政 Tab UI 分段、归档、TIM facade、chat 页、Mock 建联与 `mailbox_models_test`（见 PLAN A5-IM 与改动预测 2026-05-02）。
- 管理端：配置、国家、VIP 页等（PLAN 改动预测中有记录）。

---

## 4. 待用户/产品确认（非代码可解）

- 忘记密码是否在首发范围（PLAN 邮件能力已规划密码重置）。
- **腾讯 IM 好友同步**：业务侧 **`TencentImFriendshipNotifier`（FP-A5d-004）** 已接 REST；生产需配置 **`TENCENT_IM_REST_IDENTIFIER`**（控制台 App 管理员 UserID）及可达 **`rest-api-host`**；与发信/建联顺序相关的仅为运维窗口与观测告警策略。

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
| GET | `/api/mailbox/friends`（**Connections**：活跃好友/笔友列表，非会话列表） |
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
| `mailbox`（信件） | **`USE_MOCK=false`**：`mailbox_remote` 接 postal/archive/详情/发信/建联/好友判断/`speed-up`；**Connections** 接 **`GET /api/mailbox/friends`**（好友列表）；顶栏邮票 `/api/stamps/balance`；聊天页仍用 TIM SDK（UserSig）；**回信**仍待产品化（见 `07`） |
| `profile` | `USE_MOCK=false` 时 bootstrap/me/PATCH profile 已有多处接线；头像 OSS 写回等见 **FP-A2-002** |

### 5.4 Manage 小缺口（再次确认）

- **设备拉黑**：`UserList` 已接「设备拉黑」；`api.userDevices` + `api.blockDevice`（body `{ deviceUuid, reason? }`）与 `GET /webapi/user/{userId}/devices`、`POST /webapi/user/device/block` 对齐（2026-05-09）。
- **邮票流水**：已有独立页与 `POST /webapi/stamps/ledger/paging`（见 FP-A9-002）。

### 5.5 文档索引

执行层规划见 [`task_plan.md`](task_plan.md) 与 [`doc/plan/01-feature-list.md`](doc/plan/01-feature-list.md) 起共 **7** 份（含 [`07-gap-analysis-and-roadmap.md`](doc/plan/07-gap-analysis-and-roadmap.md) 遗漏清单与路线图）。

---

## 6. OSS 私有读（2026-05-08）

**已存在事实**：仅 [`AppOssServiceImpl`](senior-post-api/biz/src/main/java/cn/nine/pros/post/biz/service/app/impl/AppOssServiceImpl.java) 签发 **PUT** 预签名；`OssPutSignResultVO.readUrl` 依赖 `senior-post.oss.public-read-base-url`，**私有桶下应为空**，否则客户端误用不可匿名访问的拼接 URL。

**缺口（2026-05-08 后已收口）**：已具备 **`POST /api/oss/get-sign`**、`OssDisplayUrlService` 出站换签、Manage **`/webapi/oss/get-sign`**；App 侧 **`PostalOssNetworkImage`** 在预签名过期导致首帧失败时，从 URL 路径解析 objectKey 并 **单次** 调用换签自愈（`OSS_KEY_PREFIX` 须与后端 `keyPrefix` 一致）。

**改造原则（与产品对齐）**：首发 **不做** 匿名公共前缀；读链路由服务端换签 + 短 TTL + objectKey 白名单与业务权限校验。

**执行跟踪**：`task_plan.md`「OSS 私有读改造」子阶段 O1–O7；FP **FP-X-005**（`05-task-tracker.md`）。

---

## 7. IM 好友同步与 Connections 语义（2026-05-08～09）

- **FP-A5d-004**：服务端在建联成功后调用腾讯 REST 双向 `friend_add`；需 **`TENCENT_IM_REST_IDENTIFIER`** 指向控制台 **App 管理员** UserID；可选 **`TENCENT_IM_REST_HOST`**（地域差异）。
- **FP-A6-003**：登录/注册与发帖创建路径写入 **`bu_stamp_daily_grant`** + **`log_stamp_transaction`**；默认 **`senior-post.stamps-grant`**；日期为 **UTC**。
- **E2E 人工冒烟**：见 `senior-post-api/doc/e2e-smoke.http`（自动化需启用测试库或 Testcontainers，未在本迭代交付）。
- **Connections（产品语义）**：邮政 Tab 第二分段 **等同于 IM 语境下的「好友列表」**：数据来自 **`bu_friendship`**（`GET /api/mailbox/friends`），**不等同于** SDK **会话列表**（`getConversationList`）。会话仅在实际发过/收过聊天消息后出现在 TIM 会话存储；好友列表在 Accept 建联后即可展示。

---

## 8. 文档与事实勘误（2026-05-09 全面梳理）

- **`doc/plan/01-feature-list.md`**：`FP-A2-002`（头像 OSS+PATCH）与 `FP-A8-006`（App 举报闭环）曾标为「缺」，与 `progress.md`（2026-05-08～09）及 Flutter `PostWallReportSheet` / `profile_edit_page` 实现不一致，**已回写为已有**。
- **`doc/plan/07-gap-analysis-and-roadmap.md`**：已增 **§2.0 与代码对齐表**（2026-05-09 v1.1）；§2 历史表前增加「以 §2.0 为准」注脚。
- **`PLAN.md` [功能清单]、[状态] S9/S11`**：已于 **2026-05-09** 与 `01` / 代码对齐更新；后续发版前仍建议 diff 核对 `01`。
- **文档治理**：新增 [`doc/plan/00-documentation-governance.md`](doc/plan/00-documentation-governance.md)、[`doc/README.md`](doc/README.md)，明确 **真源层级** 与淘汰规则。

---

## 9. 文档与代码差异清点（2026-05-09 · 已在本会话修正）

| 位置 | 原问题 | 修正动作 |
|------|--------|----------|
| `PLAN.md` [功能清单] | A1 写「忘记密码仍待后端」、A5 写 Worker 仍待、A6 赠票仍待等 | 按 `01`/`progress` 更新勾选与表述 |
| `PLAN.md` S9 / S11 | S9 未勾；S11 写 IM REST「仍为占位」 | S9 已勾并注明 E2E 债；S11 改为 REST 已接 |
| `findings.md` §1 / §2.3 | 旧表暗示 A1–A10 均未勾、`S9` 未勾 | 改为「真源层级」说明并更新 S9/B14 表述 |
| `doc/feature-overview.md` | 头像/赠票/语言/IM Notifier/速览滞后 | 与实现同步 |
| `doc/plan/01-feature-list.md` | A5d-001 误写「缺调度」；A4-004 未反映 `GET users/{id}`；A10-002 仍写缺 | 改为「部分/已有」准确表述 |
| `doc/plan/07-gap-analysis-and-roadmap.md` | §2 将已交付项读成仍缺 | 增 §2.0 对齐表 + §2 注脚 |
| `doc/plan/02-requirements.md` A1-003 | 依赖写死为 X-001 阻断叙事 | 改为「已实现；outbox 为增强」 |
| `findings.md` §2.1～2.2 | 信箱「仍待验收/需接 API」措辞过时 | 改为 DONE + 建议回归 |

**未物理删除的文档**：`.cursor/skills/*` 为工具链技能非本业务维护范围；`doc/1、需求文档.md` **保留为产品归档**（已加定位块，不淘汰）。

---

## 10. 邮政收件箱「在途信」与邮票展示源（2026-05-09）

| 事实 | 说明 |
|------|------|
| **后端 `listPostalInbox`**（`AppMailboxServiceImpl`）曾对所有「已与对方互为笔友」的信件 **整封跳过**，导致 **status=运输中** 的平邮在 Archive 全量接口可见，却在 `GET /mailbox/postal` 中消失。 | 已改为：笔友关系下 **仍返回运输中** 信件；非运输中且已是笔友则继续不进入邮政 Tab 列表（与「首封建联」语义一致）。 |
| **收件人 B** 的平邮在途：`toItem` 中 `hideBody = !fromMe && delivering && standard && !openedEarly` 不变，列表/详情仍 **内容遮挡**。 | 与需求「B 与现在一样做信息遮挡」一致。 |
| **Flutter 邮票** | 邮箱顶栏等曾独立请求 `/api/stamps/balance`，与 `appSessionProvider`（`/api/auth/me` 的 `stampsBalance`）不同步；扣费后只刷新前者时个人中心仍显示旧值。**已改**：统一以 `appSessionProvider` 展示；发信/加速成功后 `refreshSessionFromServer()`；回到前台时邮箱页顺带刷新 session。 |

---

## 13. 平邮提前拆信后列表仍显示运输中（2026-05-09）

| 事实 | 说明 |
|------|------|
| **`earlyOpenLetter`** 仅写入 `recipient_early_open_at`，**未更新** `bu_letter.status`，VO 仍下发 `status=1`，Flutter 列表 chip 仍为 Delivering；`toItem` 已因 `openedEarly` 放开正文，造成「看得见正文却像未送达」。 | **代码**：提前拆信成功时同时 `status=2`、`actual_arrival_time=now()`。**数据**：`V15__letter_early_open_status_backfill.sql` 修正历史行。 |

---

## 11. 可审计表与 DB 列对齐（2026-05-09）

| 事实 | 说明 |
|------|------|
| **V1** 中 `bu_user_blacklist`、`bu_im_message`、`bu_visitor_record`、`log_admin_operation` 等仅含 `created_at`+`del_flag`（或缺 `created_by`/`updated_by`），而对应 **Domain 继承 `AbstractAuditableDomain`**，MyBatis-Plus 生成 `SELECT ... created_by ...` 时在 PostgreSQL 上报错。 | **Flyway `V14__auditable_columns_bu_and_log.sql`**：为上述表及 `bu_im_conversation`、`bu_daily_publish_record` 补齐与框架一致的审计列。 |
| **未纳入 V14** | `bu_password_reset_token`（`PasswordResetTokenDomain` 非可审计）、`bu_stamp_daily_grant`（幂等流水、非 `AbstractAuditableDomain`）保持原语义。 |

---

## 12. App 明信片评论列表口径（2026-05-09）

| 事实 | 说明 |
|------|------|
| **`AppPostcardServiceImpl.commentsPage`** 曾固定 `review_status = 1 AND status = 1`，导致 **待审核（0）** 评论不出现在 App，用户刚发的评论在详情里看不到。 | 已改为：`status = 1` 且 **`review_status IS DISTINCT FROM 2`**（排除驳回）；与 **`countVisibleComments`**（原 `countApprovedComments`）及墙/详情 **commentCount** 一致。 |

