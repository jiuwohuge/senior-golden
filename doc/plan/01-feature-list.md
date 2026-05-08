# 01 — 功能清单（FP 全表）

**状态图例**：`已有` 仓库内可调用或可演示；`部分` 有一侧无闭环；`缺` 未实现或未接契约。

**权威**：以 `senior-post-api` Controller + `client/api` + Flutter `features` 为准；对照 [`PLAN.md`](../../PLAN.md) A1–A10。

---

## A1 账号与认证

| FP ID | 功能点 | 后端 | Flutter | 备注 |
|-------|--------|------|---------|------|
| FP-A1-001 | 邮箱注册 / 登录 / `me` / 资料 PATCH | 已有 `/api/auth/*`（含 `PATCH /api/auth/profile`） | `USE_MOCK=false` 时已有 `dio` 路径；编辑资料写回 | |
| FP-A1-002 | Bootstrap（年龄门槛、国家列表） | 已有 `/api/bootstrap/init` | 已有 `appBootstrapProvider` | |
| FP-A1-003 | 忘记密码 / 重置密码 | **已有**：`POST /api/auth/forgot-password`、`POST /api/auth/reset-password`；`bu_password_reset_token`；SMTP 可选（未配则日志 WARN 出码） | Flutter 三步流 + 6 位码校验 | 生产配 `spring.mail.*` + `PASSWORD_RESET_PEPPER`；持久 outbox 仍属 **FP-X-001** |
| FP-A1-004 | 密码强度 / 重试限制 / 风控 | 缺产品细则与实现 | 部分 UI | |
| FP-A1-005 | JWT、`85xx`、单端登录 | 已有框架能力 | 已有拦截器清 Token | 见底层框架文档 |
| FP-A1-006 | 设备 `deviceUuid` / `deviceId` 上报 | 注册登录 body/头可带 | `dio` 头已写 | 与 `user_device` 落库一致性待核对 |
| FP-A1-007 | App 请求/响应 AES | 配置预留 | **缺** Flutter 拦截器 | PLAN 收尾阶段 |

---

## A2 用户资料中心

| FP ID | 功能点 | 后端 | Flutter | 备注 |
|-------|--------|------|---------|------|
| FP-A2-001 | 资料更新（昵称、国家、简介、兴趣） | **已有** `PATCH /api/auth/profile`（兴趣仍仅 Mock） | `USE_MOCK=false` 时编辑页走接口 | 兴趣写回待用户画像 API |
| FP-A2-002 | 头像上传 | **缺** OSS 签名 + 更新头像 URL | 字母占位头像 | 依赖 FP-X-OSS |
| FP-A2-003 | 兴趣标签 ≥3 校验（注册/编辑） | 缺或与注册 DTO 合并 | 部分 UI | |
| FP-A2-004 | 个人中心展示与 `me` 一致 | 已有 `GET /api/auth/me` | 非 Mock 进入 Tab 拉取 `me`；登录/注册写回 `user` | 冷启动仅 token 时依赖首次进 Profile 拉取 |

---

## A3 Post Wall（明信片墙）

| FP ID | 功能点 | 后端 | Flutter | Manage |
|-------|--------|------|---------|--------|
| FP-A3-001 | App 明信片分页列表（仅已通过审核） | **已有** `POST /api/postcards/paging`（`review_status=1`） | **非 Mock** `post_wall_remote` + Tab1 | 审核已有 `/webapi/content/postcard/*` |
| FP-A3-002 | App 明信片详情 | **已有** `GET /api/postcards/{id}`（未审仅作者可见） | **非 Mock** `post_detail_page` | — |
| FP-A3-003 | App 发布明信片（文+图） | **已有** `POST /api/postcards` | **非 Mock** `post_compose_page`；图走 `oss_upload_service` + `put-sign` | 审核流依赖 `review_status` |
| FP-A3-004 | App 评论列表与发表 | **已有** `.../comments/paging`、`POST .../comments` | **非 Mock** 详情页评论 | 审核已有 comment API |
| FP-A3-005 | App 举报提交 | **已有** `POST /api/reports` | **非 Mock** `PostWallReportSheet` → `post_wall_remote` | **举报工单**页展示举报人列；分页兼容 `records`/`list` |
| FP-A3-006 | OSS 直传签名 | **已有** `GET /api/oss/put-sign` | **部分** 发帖配图上传 | — |
| FP-A3-007 | 敏感词拦截（发帖/评论） | **已有** `SensitiveWordService.assertPlainTextAllowed`（发帖/评论/写信正文）；60s 本地缓存 | — | 词库 CRUD 已有 |
| FP-A3-008 | 审核中 / 仅作者可见等状态展示 | **部分**（详情对作者返回未审帖） | **部分**（未审 UI 提示可加强） | — |

---

## A4 Post Directory（通信名录）

| FP ID | 功能点 | 后端 | Flutter |
|-------|--------|------|---------|
| FP-A4-001 | 名录分页与用户公开字段 | **已有** `POST /api/directory/users/paging` | **非 Mock** `directory_remote` + 列表 |
| FP-A4-002 | 筛选（国家、年龄、兴趣） | **已有**（`interestNames` EXISTS） | **非 Mock** 筛选参数下发 |
| FP-A4-003 | 排序（同龄、同兴趣） | **已有** `sort`：`DEFAULT` / `SAME_AGE` / `SHARED_INTEREST`（`AppDirectoryServiceImpl`） | 筛选 Sheet 内 ChoiceChip；Mock 名录同步 |
| FP-A4-004 | 用户卡 / 详情页数据源 | **部分**（名录 VO 可支撑卡；无单独「用户公开页」） | UI 有 |
| FP-A4-005 | Send Letter 入口与写信联动 | **已有** `POST /api/mailbox/letters/send` | **非 Mock** `send_letter_sheet` |

---

## A5 Post Box（邮政信箱）

| FP ID | 功能点 | 后端 | Flutter |
|-------|--------|------|---------|
| FP-A5-001 | 发信（挂号/平邮）写库 + 业务校验 | **已有** `POST /api/mailbox/letters/send` | **`USE_MOCK=false` 已接** `send_letter_sheet` + `mailbox_remote` |
| FP-A5-002 | 邮政收件箱 / 同步 / 归档 | **已有**；`sync` 增量条件 `COALESCE(updated_at, created_at) > since` | **下拉刷新 + 回到前台自动 invalidate** postal/archive/letters | 双端仍依赖各自拉取；无推送 |
| FP-A5-003 | 建联 Accept | **已有** `POST .../accept-postal` | **非 Mock** `mailbox_remote.acceptPostalContact` |
| FP-A5-004 | 信件详情（单封） | **已有** `GET /api/mailbox/letters/{letterId}` | **非 Mock 已接** `letter_detail` |
| FP-A5-005 | 平邮加速（扣邮票） | **`POST /api/mailbox/letters/{id}/speed-up`** | `mailbox_remote` + `speed_up_sheet` |
| FP-A5-006 | IM UserSig | **已有** `/api/im/usersig` | 非 Mock 已接 |
| FP-A5-007 | 会话列表 + 聊天页 | TIM SDK | 已有 `chat_page` |

---

## A5d 平邮延迟与 IM 好友同步

| FP ID | 功能点 | 后端 | 备注 |
|-------|--------|------|------|
| FP-A5d-001 | 平邮延迟区间（配置驱动） | 缺调度与状态推进 | 与 `sys_config` 键对齐 |
| FP-A5d-002 | 平邮到期自动送达 Worker | **`StandardLetterDeliveryScheduler` + PG 条件更新**；Redis ZSET 可后续加 | Flyway `V7` 索引 |
| FP-A5d-003 | 挂号即时送达状态机 | 缺与发信同事务 | |
| FP-A5d-004 | `TencentImFriendshipNotifier` 调腾讯 REST | **占位**（日志） | `FriendshipServiceImpl` 已调用钩子 |

---

## A6 Chat Stamp（邮票）

| FP ID | 功能点 | 后端 | Flutter |
|-------|--------|------|---------|
| FP-A6-001 | 余额查询 | **已有** `GET /api/stamps/balance` | **邮政 Tab 顶栏**非 Mock 已接 |
| FP-A6-002 | 流水查询分页 | **已有** `POST /api/stamps/ledger/paging` | **非 Mock** `stamps_remote` + `stamps_ledger_page` |
| FP-A6-003 | 登录赠送 / 发帖奖励 / 日上限 | 缺定时或同步任务与配置 | 缺 |
| FP-A6-004 | 挂号消耗、加速消耗原子记账 | **已有** `StampAccountService` CAS + 并发语义单测（H2）；寄信/加速仍依赖业务层先读后写 | — |
| FP-A6-005 | 管理端用户流水查询 | **缺** 页面与 API | — |

---

## A7 VIP

| FP ID | 功能点 | 后端 | Flutter | Manage |
|-------|--------|------|---------|--------|
| FP-A7-001 | App 侧权益查询（无限邮票、免费加速等） | **缺** | Mock 开关 | `VipConfig` 已有配置写 |
| FP-A7-002 | 订阅表与到期校验 | 部分（域/表存在） | — | — |
| FP-A7-003 | VIP 与邮票扣减规则联动 | 缺 | — | — |

---

## A8 风控与合规

| FP ID | 功能点 | 后端 | Flutter | Manage |
|-------|--------|------|---------|--------|
| FP-A8-001 | 用户状态封禁 / 启用 | — | — | **已有** `user/{id}/status` |
| FP-A8-002 | 设备拉黑 | API 存在 | — | **`blockDevice` 未接 UI**（见 findings） |
| FP-A8-003 | 敏感词在 App 写入路径生效 | **已有**（明信片/评论/信件正文） | — | 词库已有 |
| FP-A8-004 | 图片审核（先审后发已部分） | 贴/评审核已有 | App 上传后待审提示 | — |
| FP-A8-005 | GDPR 注销 / 冷静期 | **缺** | `account_delete` Mock | — |
| FP-A8-006 | App 举报与工单闭环 | **缺** App 提交 | 缺入口 | 处理已有 |

---

## A9 管理后台（补口与验收）

| FP ID | 功能点 | 状态 |
|-------|--------|------|
| FP-A9-001 | 看板、用户、内容审核、举报、配置、国家、敏感词、版本、公告、日志 | **已有** 页面与 `/webapi` |
| FP-A9-002 | 邮票流水管理页 + API | **缺** |
| FP-A9-003 | 设备封禁按钮接通 `blockDevice` | **缺** |
| FP-A9-004 | 全链路验收清单（角色权限、85xx） | **缺** 文档化用例 |

---

## A10 国际化

| FP ID | 功能点 | Flutter | Manage |
|-------|--------|---------|--------|
| FP-A10-001 | ARB 中英文案覆盖主流程 | **部分**（多屏已用） | 中文为主 |
| FP-A10-002 | 设置内运行时切换语言 | **缺**（占位 toggle） | 可选 |
| FP-A10-003 | 邮件模板双语 | 缺（依赖 FP-X-001） | — |

---

## X 横切

| FP ID | 功能点 | 状态 |
|-------|--------|------|
| FP-X-001 | `EmailService` + outbox（重置密码、通知） | **缺** |
| FP-X-002 | OSS PUT 预签名（`/api/oss/put-sign`） | **已有**（需配置 `senior-post.oss` 或环境变量） |
| FP-X-005 | OSS 私有桶 **GET** 预签名（读链：批量换签或 VO 出站换签；**不做**公共前缀） | **缺**（见 `task_plan.md` OSS 子阶段 O1–O7） |
| FP-X-003 | App 版本检查 / 强更提示 | **缺**（`versionCode` 写死） |
| FP-X-004 | 可观测性（日志规范、关键指标） | 部分 Actuator |

---

## B 产品阻塞（PLAN）

| FP ID | 功能点 | 状态 |
|-------|--------|------|
| FP-B14-001 | 浅灰复古全局主题与设计令牌 | 待设计定稿与落地 |
| FP-B15-001 | 登录/注册中部卡片、协议必选、状态完整 | 待视觉规范与落地 |

---

## 统计（粗略）

| 状态 | 数量级 |
|------|--------|
| 已有 / 可演示 | ~22 FP |
| 部分 | ~14 FP |
| 缺 | ~38 FP |

*精确数以实现迭代后回写本表为准。*
