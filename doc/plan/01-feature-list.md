# 01 — 功能清单（FP 全表）

> **文档元信息**  
> **版本**：1.9 · **更新**：2026-05-09 · **维护人**：AI + Owner  
> **2026-05-09 产品裁剪**：真订阅/支付与 **FP-A7-002** 从 backlog **移除**（再启时另开 FP）；若干文档化/体验类 FP **删除**；平邮送达 **已定案** 仅用 **PG + `@Scheduled`**（不引入 Redis ZSET）。详见根目录 `task_plan.md` 决策表与 [`findings.md`](../../findings.md) §17～§18。

**状态图例**：`已有` 仓库内可调用或可演示；`部分` 有一侧无闭环；`缺` 未实现或未接契约。

**权威**：以 `senior-post-api` Controller + `client/api` + Flutter `features` 为准；对照 [`PLAN.md`](../../PLAN.md) A1–A10。

---

## A1 账号与认证

| FP ID | 功能点 | 后端 | Flutter | 备注 |
|-------|--------|------|---------|------|
| FP-A1-001 | 邮箱注册 / 登录 / `me` / 资料 PATCH | 已有 `/api/auth/*`（含 `PATCH /api/auth/profile`） | 远程 `dio` 路径；编辑资料写回 | |
| FP-A1-002 | Bootstrap（年龄门槛、国家列表） | 已有 `/api/bootstrap/init` | 已有 `appBootstrapProvider` | |
| FP-A1-003 | 忘记密码 / 重置密码 | **已有**：`POST /api/auth/forgot-password`、`POST /api/auth/reset-password`；`bu_password_reset_token`；SMTP 可选（未配则日志 WARN 出码） | Flutter 三步流 + 6 位码校验 | 生产配 `spring.mail.*` + `PASSWORD_RESET_PEPPER`；可靠投递见 **FP-X-001** |
| FP-A1-005 | JWT、`85xx`、单端登录 | 已有框架能力 | 已有拦截器清 Token | 见底层框架文档 |
| FP-A1-006 | 设备 `deviceUuid` / `equipmentId` 与 **`user_device` 落库一致** | **已有**：`equipmentId` 非空时须与体 `deviceUuid` 一致；`deviceType` 规范 ios/android | `dio` 头体一致 + 安装 ID 兜底 | 见 `AppAuthService.assertDeviceUuidMatchesHeaderOrBody` |
| FP-A1-007 | App 请求/响应 AES | **已有**：`jh.security` 收窄明文 URI；`android-version`/`ios-version`；Flutter `jh_api_crypto` + Dio 包装 `data` | `--dart-define=JH_AES_KEY` / `API_VERSION_CODE` | 与 `application.yml` 白名单同步维护 |

---

## A2 用户资料中心

| FP ID | 功能点 | 后端 | Flutter | 备注 |
|-------|--------|------|---------|------|
| FP-A2-001 | 资料更新（昵称、国家、简介、兴趣） | **已有** `PATCH /api/auth/profile`（含 `interestTagIds` 写 `bu_user_tag`） | 编辑页走接口 | `me`/PATCH 返回 `interestTagNames` + `interestTagIds` |
| FP-A2-002 | 头像上传 | **已有** `put-sign`（`avatar` 场景）+ `PATCH profile.avatarUrl` 校验归属 | 选图→裁切→PUT→PATCH（见 `progress.md` 2026-05-08） | 与 FP-X-005 私有读换签一致 |
| FP-A2-003 | 兴趣标签 ≥3 校验（注册/编辑） | **已有** 注册 `AppRegisterInDto.interestTagIds`（≥3）+ 写 `bu_user_tag`；`GET /api/bootstrap/init?lang=` 带 `interestTagOptions`；名录项 `interestTagIds`/`interestTagNames` | 注册页多选；`interests_picker` PATCH；名录 VO 展示兴趣 | — |
| FP-A2-004 | 个人中心展示与 `me` 一致 | 已有 `GET /api/auth/me` | 进入 Tab 拉取 `me`；登录/注册写回 `user` | 冷启动仅 token 时依赖首次进 Profile 拉取 |

---

## A3 Post Wall（明信片墙）

| FP ID | 功能点 | 后端 | Flutter | Manage |
|-------|--------|------|---------|--------|
| FP-A3-001 | App 明信片分页列表（仅已通过审核） | **已有** `POST /api/postcards/paging`（`review_status=1`） | `post_wall_remote` + Tab1 | 审核已有 `/webapi/content/postcard/*` |
| FP-A3-002 | App 明信片详情 | **已有** `GET /api/postcards/{id}`（未审仅作者可见） | `post_detail_page` | — |
| FP-A3-003 | App 发布明信片（文+图） | **已有** `POST /api/postcards` | `post_compose_page`；图走 `oss_upload_service` + `put-sign` | 审核流依赖 `review_status` |
| FP-A3-004 | App 评论列表与发表 | **已有** `.../comments/paging`、`POST .../comments` | 详情页评论 | 审核已有 comment API |
| FP-A3-005 | App 举报提交 | **已有** `POST /api/reports` | `PostWallReportSheet` → `post_wall_remote` | **举报工单**页展示举报人列；分页兼容 `records`/`list` |
| FP-A3-006 | OSS 直传签名 | **已有** `GET /api/oss/put-sign` | **部分** 发帖配图上传 | — |
| FP-A3-007 | 敏感词拦截（发帖/评论） | **已有** `SensitiveWordService.assertPlainTextAllowed`（发帖/评论/写信正文）；60s 本地缓存 | — | 词库 CRUD 已有 |

---

## A4 Post Directory（通信名录）

| FP ID | 功能点 | 后端 | Flutter |
|-------|--------|------|---------|
| FP-A4-001 | 名录分页与用户公开字段 | **已有** `POST /api/directory/users/paging` | `directory_remote` + 列表 |
| FP-A4-002 | 筛选（国家、年龄、兴趣） | **已有**（`interestNames` EXISTS） | 筛选参数下发 |
| FP-A4-003 | 排序（同龄、同兴趣） | **已有** `sort`：`DEFAULT` / `SAME_AGE` / `SHARED_INTEREST`（`AppDirectoryServiceImpl`） | 筛选 Sheet 内 ChoiceChip |
| FP-A4-004 | 用户卡 / 详情页数据源 | **已有** `GET /api/directory/users/{userId}`；名录 VO 支撑卡 | Flutter `UserCardPage` 走远程 |
| FP-A4-005 | Send Letter 入口与写信联动 | **已有** `POST /api/mailbox/letters/send` | `send_letter_sheet` |

---

## A5 Post Box（邮政信箱）

| FP ID | 功能点 | 后端 | Flutter |
|-------|--------|------|---------|
| FP-A5-001 | 发信（挂号/平邮）写库 + 业务校验 | **已有** `POST /api/mailbox/letters/send`（含 **`parentLetterId` 回信** 校验与落库） | `send_letter_sheet` + `mailbox_remote`；详情页回信见 [`08-mock-removal-gaps.md`](08-mock-removal-gaps.md) |
| FP-A5-002 | 邮政收件箱 / 同步 / 归档 | **已有**；`sync` 增量条件 `COALESCE(updated_at, created_at) > since` | **下拉刷新 + 回到前台自动 invalidate** postal/archive/letters；双端仍依赖各自拉取；无推送 |
| FP-A5-003 | 建联 Accept | **已有** `POST .../accept-postal` | `mailbox_remote.acceptPostalContact` |
| FP-A5-004 | 信件详情（单封） | **已有** `GET /api/mailbox/letters/{letterId}` | `letter_detail` |
| FP-A5-005 | 平邮加速（扣邮票） | **`POST /api/mailbox/letters/{id}/speed-up`** | `mailbox_remote` + `speed_up_sheet` |
| FP-A5-006 | IM UserSig | **已有** `/api/im/usersig` | 已接 |
| FP-A5-007 | **Connections = 好友列表**（`/mailbox/friends`）+ C2C 聊天页 | **`GET /api/mailbox/friends`**；TIM 仅用于登录与聊天 | **`mailboxFriendsProvider` + `chat_page`**（数据来源 **非** `getConversationList`） |

---

## A5d 平邮延迟与 IM 好友同步

| FP ID | 功能点 | 后端 | 备注 |
|-------|--------|------|------|
| FP-A5d-001 | 平邮延迟区间（配置驱动） | **部分**：`sendLetter` 仍用代码内随机区间；**送达**已由 `StandardLetterDeliveryScheduler`（FP-A5d-002）按 `expected_arrival_time` 推进 | 读 `sys_config` min/max 替换硬编码 |
| FP-A5d-002 | 平邮到期自动送达 Worker | **`StandardLetterDeliveryScheduler` + PG 条件更新** | **已定案**：仅用定时扫描 + PG，**不**引入 Redis ZSET；Flyway `V7` 索引 |
| FP-A5d-004 | `TencentImFriendshipNotifier` 调腾讯 REST | **已有** `TencentImRestApiClient`（`account_import`、`sns/friend_add` 双向） | 需配置 `TENCENT_IM_REST_IDENTIFIER`（App 管理员） |

> **（原 FP-A5d-003 已移出 backlog）**「挂号扣票与写 `bu_letter` 同事务、失败不留脏信件/不错扣」的含义与是否需单独立项，见 [`findings.md`](../../findings.md) **§17**。

---

## A6 Chat Stamp（邮票）

| FP ID | 功能点 | 后端 | Flutter |
|-------|--------|------|---------|
| FP-A6-001 | 余额查询 | **已有** `GET /api/stamps/balance` | 邮政 Tab 顶栏与 `appSessionProvider` |
| FP-A6-002 | 流水查询分页 | **已有** `POST /api/stamps/ledger/paging` | `stamps_remote` + `stamps_ledger_page` |
| FP-A6-003 | 登录赠送 / 发帖奖励 / 日上限 | **已有** `StampGrantService`；UTC 日切；`bu_stamp_daily_grant` 幂等；`senior-post.stamps-grant.*` | 管理端改参数仍走 `sys_config` 可选后续 |
| FP-A6-004 | 挂号消耗、加速消耗原子记账 | **已有** `StampAccountService` CAS + 并发语义单测（H2）；寄信/加速仍依赖业务层先读后写 | — |
| FP-A6-005 | 管理端用户流水查询 | **已有** `POST /webapi/stamps/ledger/paging` + Manage `StampLedgerList` | — |

---

## A7 VIP

| FP ID | 功能点 | 后端 | Flutter | Manage |
|-------|--------|------|---------|--------|
| FP-A7-001 | App 侧权益查询（无限邮票、免费加速等） | **已有**：`GET /api/bootstrap/init` 返回 `vipProduct`（读 `sys_config` vip 键） | `vip_center_page` 读 bootstrap；**真订阅/支付不做** | Manage `VipConfig` 写同源键；调试用 **`vip-debug`**（见 `08-mock-removal-gaps.md`） |
| FP-A7-003 | VIP 与邮票扣减规则联动 | **部分** | — | 与 `me` / `vipProduct` / 调试 VIP 一致；**原 A7-002 订阅/支付本期移除**，再启时新开 FP |

---

## A8 风控与合规

| FP ID | 功能点 | 后端 | Flutter | Manage |
|-------|--------|------|---------|--------|
| FP-A8-001 | 用户状态封禁 / 启用 | — | — | **已有** `user/{id}/status` |
| FP-A8-002 | 设备拉黑 | **已有** `POST /webapi/user/device/block` | — | **已有** 用户列表「设备拉黑」+ `GET /webapi/user/{userId}/devices` |
| FP-A8-003 | 敏感词在 App 写入路径生效 | **已有**（明信片/评论/信件正文） | — | 词库已有 |
| FP-A8-005 | GDPR 注销 / 冷静期 | **部分（MVP）**：`POST /api/auth/account/deletion-request`；冷静期与期满 `status=3`；**正式注销前**解除好友 + 腾讯双向删好友（见 `findings.md` §15.2） | `account_delete_page` + Profile 提示 | 见 [`08-mock-removal-gaps.md`](08-mock-removal-gaps.md) §3 |
| FP-A8-006 | App 举报与工单闭环 | **已有** `POST /api/reports` | `PostWallReportSheet` → `post_wall_remote` | Manage 列表含 Reporter（见 FP-A3-005） |

---

## A9 管理后台（补口与验收）

| FP ID | 功能点 | 状态 |
|-------|--------|------|
| FP-A9-001 | 看板、用户、内容审核、举报、配置、国家、敏感词、版本、公告、日志 | **已有** 页面与 `/webapi` |
| FP-A9-002 | 邮票流水管理页 + API | **已有** `POST /webapi/stamps/ledger/paging`；Manage「用户管理 → 邮票流水」 |
| FP-A9-003 | 设备封禁按钮接通 `blockDevice` | **已有**（同 FP-A8-002 Manage 侧） |

---

## A10 国际化（本期范围）

| FP ID | 功能点 | 说明 |
|-------|--------|------|
| FP-A10-001 | **邮件模板国际化** | **已有**：`app.mail.passwordReset.*` + `MessageSource`；Outbox 存 `locale_tag`；worker 按行渲染 | 依赖 **FP-X-001** Outbox | 与 `Accept-Language` / `LocaleContextHolder` 对齐 |

> App 端 UI 已有 ARB + `Accept-Language` 基线；**不设**单独 FP 跟踪「ARB 全量扫尾 / 运行时语言专项」。

---

## X 横切

| FP ID | 功能点 | 状态 |
|-------|--------|------|
| FP-X-001 | `EmailService` + **outbox**（重置密码、通知可重试） | **已有**：`sys_mail_outbox` + 调度重试；忘记密码入队；见 `V17__mail_outbox.sql` |
| FP-X-002 | OSS PUT 预签名（`/api/oss/put-sign`） | **已有**（需配置 `senior-post.oss` 或环境变量） |
| FP-X-003 | **版本公告（非强更）**：固定字段 **标题 + 版本号（展示）+ 更新内容（纯文本多行）**；Manage **表单 + 与 App 同结构预览**；App **可关闭**弹层；可选 `versionCode` 区间定向 | **已有**：`V18` + `GET /api/bootstrap/release-note` + Manage + Flutter；细则见 [`findings.md`](../../findings.md) **§18** |
| FP-X-005 | OSS 私有桶 **GET** 预签名 | **已有** 出站换签 + `POST /api/oss/get-sign` + Flutter `PostalOssNetworkImage` |

---

## 统计（粗略）

| 状态 | 说明 |
|------|------|
| 已有 / 可演示 | 主路径 FP 已 majority |
| 部分 | A5d-001、A7-003、A8-005 等 |
| 缺（本期规划优先） | Sprint 4 五项 FP（A1-006 / X-001 / A1-007 / X-003 / A10-001）已在代码侧闭环；后续以线上观测为主 |

*精确数以迭代后回写为准。*
