# 研究发现（规划会话）

> **文档元信息**  
> **版本**：1.6 · **更新**：2026-05-09 · **维护人**：AI + Owner

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

- **`PLAN.md` S9**：M2 REST 主链路已落地；**E2E 自动化 / UAT 文档化（原 FP-A9-004）已从 backlog 移除**（2026-05-09 Owner 确认）。
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
| `mailbox`（信件） | **远程**：`mailbox_remote` 接 postal/archive/详情/发信（含 **`parentLetterId` 回信**）/建联/好友判断/`speed-up`；**Connections** 接 **`GET /api/mailbox/friends`**；顶栏邮票与 `appSessionProvider` 同步；聊天页用 TIM SDK（UserSig）；见 [`doc/plan/08-mock-removal-gaps.md`](doc/plan/08-mock-removal-gaps.md) |
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
| **后端 `listPostalInbox` / `sync`**（`AppMailboxServiceImpl`）曾按 `areActiveFriends` 分支处理笔友信，与「邮政收件箱与 Connections 完全独立」冲突。 | **已清除**：邮政列表 **不再** 查询好友关系；统一由 `includeInPostalInbox` 判定（见 §14）。 |
| **收件人 B** 的平邮在途：`toItem` 中 `hideBody = !fromMe && delivering && standard && !openedEarly` 不变，列表/详情仍 **内容遮挡**。 | 与需求「B 与现在一样做信息遮挡」一致。 |
| **Flutter 邮票** | 邮箱顶栏等曾独立请求 `/api/stamps/balance`，与 `appSessionProvider`（`/api/auth/me` 的 `stampsBalance`）不同步；扣费后只刷新前者时个人中心仍显示旧值。**已改**：统一以 `appSessionProvider` 展示；发信/加速成功后 `refreshSessionFromServer()`；回到前台时邮箱页顺带刷新 session。 |

---

## 13. 平邮提前拆信后列表仍显示运输中（2026-05-09）

| 事实 | 说明 |
|------|------|
| **`earlyOpenLetter`** 仅写入 `recipient_early_open_at`，**未更新** `bu_letter.status`，VO 仍下发 `status=1`，Flutter 列表 chip 仍为 Delivering；`toItem` 已因 `openedEarly` 放开正文，造成「看得见正文却像未送达」。 | **代码**：提前拆信成功时同时 `status=2`、`actual_arrival_time=now()`。**数据**：`V15__letter_early_open_status_backfill.sql` 修正历史行。 |

---

## 14. 邮政收件箱 / 归档 / 在途 / 已读（2026-05-09，与 Connections 解耦）

| 概念 | 口径 |
|------|------|
| **Connections** | 仅 `listFriends` / 接受请求建联等；**不参与** `listPostalInbox`、`sync`、`listArchive` 的过滤。 |
| **归档（Archive）** | `GET /mailbox/archive` = 当前用户作为发件人或收件人关联的 **全部** 信件（与已读/未读无关）。 |
| **邮政收件箱（Postal）** | `GET /mailbox/postal` 与 `sync`：**收件**且 `recipient_read_at` 为空（含运输中加密、已送达未打开）；**或发件**且 `status=运送中`。已送达发件信不再进入 Postal。实现：`AppMailboxServiceImpl#includeInPostalInbox`。 |
| **在途横幅（App）** | Flutter：`postal` 列表内存在 `LetterStatus.delivering` 即显示「A post is on the way」；与后端 Postal 过滤一致。 |
| **已读 `recipient_read_at` 仅两处写入** | （1）`getLetter`：仅当 **收件人** 且 **已送达** 且原为空时写入（运输中打开详情 **不写**）。（2）`earlyOpenLetter`：提前拆信成功时写入。 |
| **Archive 压力** | 可做分页/截断；与 Postal 的 **未读 + 发件在途** 维度独立。 |

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

---

## 15. Connections 点进聊天「空白」与注销解除 IM 好友（2026-05-09）

### 15.1 排查结论（代码级）

| 可能原因 | 说明 |
|----------|------|
| **好友列表 `peerUserId` 解析为 0** | Flutter 曾仅用 `(m['peerUserId'] as num?)`；若 JSON 为 **String** 或键为 **snake_case**（`peer_user_id`），会得到 **0**，路由变为 `/chat/0`，业务好友校验与 TIM 对端 ID 均异常，界面表现为不可用或异常空态。**已加固**：宽松 `_readIntLoose` + 兼容 `peer_user_id`；入口对 `0`/空 **SnackBar** 提示。 |
| **仅历史消息为空** | `_CloudChatBody` 在 `getC2CHistoryMessageList` 成功且列表空时展示 **「No messages yet」**，并保留输入框；若用户描述为「空白」，需区分是全屏无 Scaffold 还是仅消息区无气泡。 |
| **长时间 Loading** | `ensureLoggedIn()` / `getC2CHistoryMessageList` 阻塞时一直 **CircularProgressIndicator**；若主题对比度或机型问题可能被误认为白屏。 |
| **`/api/im/usersig` 业务失败** | 无好友时服务端拒签（见 `AppImService`）；与 Connections 列表数据源均为 `bu_friendship`，正常应一致；若仍失败应抓 **Dio 业务 message** 与 `Chat unavailable` 副标题。 |

### 15.2 注销与好友关系

- **触发点**：`AppAuthService.finalizeAccountDeletionIfCooldownElapsed`（冷静期满、登录路径触发的最终注销），**非**仅「提交注销申请」当日。
- **本地**：`FriendshipService.deactivateAllFriendshipsForUser` 将涉及该用户的 **`bu_friendship.status` 1→0**。
- **腾讯 IM**：`TencentImFriendshipNotifier.afterFriendshipRemoved` → `TencentImRestApiClient.friendDeleteBoth`（`Delete_Type_Both`），与建联时双向 `friend_add` 配对。

---

## 16. 用户端国际化（App / Flutter，排除管理后台）（2026-05-09）

### 16.1 资源与契约

| 层级 | 机制 | 说明 |
|------|------|------|
| **后端 App API** | `biz/src/main/resources/messages/app.properties`（英文默认）+ `app_zh_CN.properties`；`spring.messages.basename: messages/app` | 业务代码通过 `AppMessages.get("app.error.*", …)` 取文案；**无 `Accept-Language` 时语言以 commons-web `AcceptHeaderLocaleResolver#setDefaultLocale` 为准**（当前框架为 **ENGLISH**；需中文无头回退请改框架默认或在本工程单独声明 `LocaleResolver`）。 |
| **语言解析** | `spring.web.locale-resolver` / `spring.web.locale` 与 Boot WebMvc 配置项；**与手写 `LocaleResolver` Bean 的 default 无必然绑定** | 客户端应随界面语言发送 `Accept-Language`（如 `en`、`zh-CN`）。 |
| **Flutter** | `lib/l10n/app_en.arb` / `app_zh.arb` + `flutter gen-l10n` | 设置页已持久化覆盖；`SeniorPostApp` 用 `resolveSeniorPostLocale`；**Dio 请求头** `Accept-Language` 与有效界面语言一致（`effectiveAppLocaleProvider` + `acceptLanguageHeader`）。 |

### 16.2 文案提取与翻译流程（建议）

1. **后端**：新增错误 → 先在 `app.properties` / `app_zh_CN.properties` 增加同一 `app.error.*` 键，再在 Java 中只引用键名；禁止在 App 路径直接写中英文字符串。  
2. **Flutter**：新增 UI 文案 → 同时编辑 `app_en.arb` 与 `app_zh.arb`（含 `@placeholder` 元数据），运行 `flutter gen-l10n`，页面使用 `AppLocalizations.of(context)!`。  
3. **校验**：`mvn -pl biz -am compile`；`flutter analyze lib`；对关键接口用不同 `Accept-Language` 打桩断言 `message` 字段。

### 16.3 兼容性测试标准（最低门禁）

| 用例 | 期望 |
|------|------|
| Flutter 英语界面 + 后端 | 响应 `message` 为英文；无中文硬编码外露（抽样登录失败、邮票不足、OSS 校验失败）。 |
| Flutter 中文界面 + 后端 | 响应 `message` 为简体中文。 |
| 设置「跟随系统」 | 与系统语言列表一致；Dio 头与 Material `locale` 一致。 |
| 管理后台 `/webapi` | **本迭代未改** Admin 控制器文案；默认仍中文；若浏览器仅发 `Accept-Language: en` 则会得到英文 bundle（可接受或后续为 webapi 单独策略）。 |

### 16.4 已知缺口与规划

- Flutter 仍有部分硬编码文案；**不设专项 FP**，按需迭代。  
- 邮件主题等：**FP-A10-001**（`MessageSource` + Locale）在 **FP-X-001** Outbox 落地后串联（见 `01`）。

---

## 17. 「原 FP-A5d-003」事务边界是什么？什么叫不留脏数据？（2026-05-09）

历史上 **FP-A5d-003** 指：**挂号信（`letter_type=1`）**在 **`sendLetter`** 路径里，**扣减邮票（CAS + 写 `log_stamp_transaction`）** 与 **插入/更新 `bu_letter`（状态、收发信息）** 应在**同一数据库事务**内完成，并满足：

| 失败场景 | 若不同事务可能出现的现象（俗称「脏数据」） |
|----------|---------------------------------------------|
| 扣票成功、写信失败 | 用户**少票**但**没有对应信件** |
| 写信成功、扣票失败 | 库里有**待投递信**但**未扣票**（资产账实不一致） |

**当前状态**：仓库已实现 **CAS 扣票**（`StampAccountService`）与发信主流程；是否在**单一 `@Transactional` 边界**内包裹「扣票 + 插信」、异常时是否完全回滚，属于**实现细节复核**。**Owner 决策（2026-05-09）**：**不设独立 FP**；若压测/线上未见账实不一致，可不立项。若需立项，应新开 FP 编号，附集成测试用例（并发发挂号、模拟 DB 异常等）。

**与平邮 Worker 无关**：平邮到期由 **FP-A5d-002**（PG 定时扫描）处理；**已定案不引入 Redis ZSET**。

---

## 18. FP-X-003：版本公告（非强更）— **结构化字段**（2026-05-09 修订）

### 18.1 产品结论（与 Markdown / 富文本对比）

| 方案 | 评价 |
|------|------|
| Markdown / 自由富文本 | 运营要记语法或面对 XSS/HTML 消毒；**不推荐**作默认方案。 |
| **固定字段 + 版式模板**（推荐） | 与行业常见 **「更新标题 + 版本号 + 更新内容」** 一致；运营只填表单项；App 端**写死排版**（标题区、版本区、正文区），**零解析风险**（正文按**纯文本**展示，允许多行与缩进）。 |

### 18.2 建议数据形态（示例，实现时可微调列名）

| 字段 | 说明 |
|------|------|
| **标题** | 短文案，如「本次更新」 |
| **版本号（展示）** | 给人看的字符串，如 `1.2.0` 或与商店版本对齐的文案 |
| **更新内容** | **纯文本**，多行；仅允许换行、空格/缩进；**禁止 HTML**（存库与展示均按纯文本转义，等价 `white-space: pre-wrap` / Flutter `Text` 保留换行） |
| **生效 / 定向（可选）** | 如 `minVersionCode` / `maxVersionCode`、生效时间、`locale` 等，用于「谁看得到」；**仍不可**做不可关强更 |

### 18.3 Manage 交互

- **多行表单**：标题单行、版本号单行、更新内容 **TextArea**（占位提示：「一段一条，可用换行分段」）。  
- **预览**：右侧或弹窗展示与 App **相同结构**的预览（不跑 Markdown 引擎）。  
- **可选**：若以后要「要点列表」，可再加固定 **3～5 条** 短文本子字段，仍不写自由 HTML。

### 18.4 App 行为（不变）

- 弹层 **可关闭**；**非**商店强更。  
- 若有「前往商店」链接，用**独立按钮** + 白名单 URL 打开，不把任意 HTML 塞进正文。

### 18.5 与 `versionCode`

- 仍可用于**服务端筛选**向哪些客户端推这条公告；**不作为**全屏拦截强更。

> **修订说明**：曾考虑 Markdown/富文本；按 Owner 意见改为 **结构化表单 + 纯文本「更新内容」**（与常见应用商店「更新说明」版式一致）。

---

## 21. Google 登录与 `bu_user_identity`（2026-05-20）

| 项 | 说明 |
|------|------|
| **Flyway** | `V22__user_identity_gender.sql`：建 `bu_user_identity`，迁移 `bu_user.email/password_hash`，加 `bu_user.gender`，DROP 资料表邮箱列 |
| **后端 API** | `POST /api/auth/google`（`idToken` + `agreedTerms` + device）；`POST /api/auth/google/complete`（gender、birthYear、nickname、interests、可选 avatarUrl） |
| **配置** | `senior-post.oauth.google.client-id`（`application.yml` 占位，部署填 Google Cloud OAuth Web Client ID） |
| **Flutter** | `google_sign_in` + `GoogleSignInFacade`；Android 需在 Google Cloud 配置 SHA-1 与 OAuth 客户端；未配置时登录页 Snack 提示，邮箱路径可独立验收 |
| **同邮箱绑定** | Google `email` 已存在 email identity 且未绑 google 行时，同一 `user_id` 新增 google identity |
| **看板用户数** | `AdminDashboard` 使用 `UserService.countActiveAppUsers()`（`del_flag=false AND status=1 AND staff_role=0`） |

---

## 20. 用户删除后释放 UNIQUE 标识（2026-05-20 · 已确认）

| 说明 | 内容 |
|------|------|
| **背景** | `bu_user.email` UNIQUE；迁表后 `bu_user_identity UNIQUE(provider, provider_uid)`。删号若不改写标识，同邮箱 / 同 Google openId 无法再次注册或绑定。 |
| **规则** | 后缀 `+deleted.{epochMillis}`；邮箱在 `@` 前插入；openId 等在末尾追加；幂等；最长 255。 |
| **工具类** | `DeletedUniqueKeySupport.archiveEmail` / `archiveProviderUid`（`DeletedUserEmailSupport` 委托前者） |
| **删除入口** | App 冷静期注销、Manage status=3、Manage 软删 — 须在 V22 改为 `UserIdentityService.releaseAllForUser`，对该用户**所有** identity 行归档 |
| **历史数据** | 已有 `V20` 回填邮箱；V22 需对 identity 中 google/apple 行做同类回填 |
| **注册查询** | `findByEmail` / `findByProviderUid` 仅匹配未含 `+deleted.` 的有效标识 |

---

## 19. 明信片墙/名录排查：为何日志频繁出现 `/api/auth/me`（2026-05-18）

| 发现 | 说明 |
|------|------|
| 终端日志中 `auth/me` 与 `im/usersig` 成对高频出现 | 与业务墙/名录接口无直接映射，属于会话刷新 + IM 预热触发链。 |
| 根因在导航壳重建 | `MainShell` 底部 Tab 使用 `context.go(...)` 切路径，导致 `MainShell` 重建；`ProfilePage.initState` 每次重建都会调用 `refreshSessionFromServer -> /api/auth/me`。 |
| 业务接口本身未被改写 | 墙与名录仓储仍指向 `/api/postcards/*`、`/api/directory/*`；高频 `auth/me` 是副作用噪声。 |

---

## 22. 时光邮局 v1（2026-05-25 · 留档，未开工）

| 项 | 说明 |
|----|------|
| **需求真源** | [时光邮局功能提案.md](../时光邮局功能提案.md) **§5**（Claude 合并定稿） |
| **开发计划** | [doc/plan/time-letter/task_plan.md](doc/plan/time-letter/task_plan.md)（M1–M4） |
| **技术清单** | [doc/plan/time-letter/01-dev-plan.md](doc/plan/time-letter/01-dev-plan.md) |
| **代码现状** | 无 `time_letter` 实现；最新 Flyway **V25** → 新表建议 **V26** |
| **关键差异** | 时光信发送前 **强制互关**；社交信 `sendLetter` 不要求互关 |
| **不可混用** | `bu_letter`、`/api/mailbox/*`、加急/提前拆信 |
| **Flutter 落点** | `mailbox_page.dart` 增第三 Tab「时光」；新建 `lib/features/time_letter/` |
| **详细摸底** | [doc/plan/time-letter/findings.md](doc/plan/time-letter/findings.md) |
