# 功能总览（模块 → 功能）

> **文档元信息**  
> **版本**：1.6 · **更新**：2026-05-09 · **维护人**：AI + Owner

**用途**：快速把握各模块能力边界与完成度。  
**状态取值**：`已完成` | `进行中` | `未开始`（以 App + `senior-post-api` + Manage 可联调闭环为准）。  
**维护**：迭代后须与 [`doc/plan/01-feature-list.md`](plan/01-feature-list.md) 同步；任务排期见 [`doc/plan/05-task-tracker.md`](plan/05-task-tracker.md)；**治理标准**见 [`doc/plan/00-documentation-governance.md`](plan/00-documentation-governance.md)。

---

## 1. 账号与认证

| 功能 | 状态 | 预期行为 | 验收标准 |
|------|------|----------|----------|
| 注册 / 登录 / 会话 / `me` | 已完成 | 新用户可注册，老用户 JWT 登录，拉取当前用户资料 | `POST /api/auth/register|login`、`GET /api/auth/me`；Flutter 远程可登录进首页 |
| 启动配置（年龄门槛、国家） | 已完成 | 未登录可拉注册所需配置 | `GET /api/bootstrap/init`；注册页国家与年龄范围与接口一致 |
| 资料 PATCH | 已完成 | 已登录用户可改昵称、国家、简介等 | `PATCH /api/auth/profile`；编辑页保存后 `me` 一致 |
| 忘记密码 / 重置 | 已交付（A1-003） | 6 位邮件验证码 + 一次性核销 + 新密码登录 | SMTP 可选；持久 outbox 仍归 X-001 |
| 设备标识与挤下线 | 已完成（**FP-A1-006**） | `equipmentId` 与体 `deviceUuid` 一致；`deviceType` 规范 ios/android | `AppAuthService` |
| App 请求 AES 加解密 | 已完成（**FP-A1-007**） | 与 `jh.security` 白名单 + Flutter ECB 包装 `data` 字段 | `jh_api_crypto` + `dio_provider` |

---

## 2. 用户资料

| 功能 | 状态 | 预期行为 | 验收标准 |
|------|------|----------|----------|
| 个人中心展示 | 已完成 | Tab 展示与 `me` 一致 | 远程下资料字段正确 |
| 兴趣标签写回与校验 | 已完成 | 注册/编辑 ≥3 兴趣并持久化 | `interestTagIds`、名录筛选与 VO 一致 |
| 头像 OSS 上传与写回 | 已完成 | 选图 → 直传 OSS → 头像 URL 更新 | `put-sign`（`avatar`）+ `PATCH profile.avatarUrl` |
| 冷启动仅 Token 时资料新鲜度 | 进行中 | 进入 Shell 即刷新 `me`，不依赖先进 Profile Tab | 杀进程重开后面板数据已更新 |

---

## 3. 明信片墙（Post Wall）

| 功能 | 状态 | 预期行为 | 验收标准 |
|------|------|----------|----------|
| 列表 / 详情（仅已过审对公众） | 已完成 | 墙列表仅 `review_status` 通过；作者可见己稿 | 分页与详情与审核规则一致 |
| 发帖（文 + 多图） | 已完成 | 发帖入审；图可走 OSS | `POST /api/postcards`；Compose 真机成功 |
| 评论列表与发表 | 已完成 | 详情页分页评论与发评 | 接口与 UI 非 Mock 闭环 |
| OSS 发帖/头像签名 | 已完成 | 登录用户按 scene 取上传参数 | `GET /api/oss/put-sign` 可 PUT 成功 |
| 举报（帖/评） | 已完成 | 用户提交举报单，后台可处理 | `POST /api/reports`；Manage **举报工单**展示举报人；分页 `records`/`list` 兼容 |
| 发帖/评论敏感词 | 已完成 | 命中词库则拒绝 | `SensitiveWordService.assertPlainTextAllowed`；发帖/评论/信件正文；词库变更后缓存失效 |

---

## 4. 通信名录（Directory）

| 功能 | 状态 | 预期行为 | 验收标准 |
|------|------|----------|----------|
| 分页与公开字段 | 已完成 | 条件分页返回用户卡所需字段 | `POST /api/directory/users/paging` |
| 筛选（国家/年龄/兴趣） | 已完成 | 筛选参数生效 | Flutter 筛选与 total 正确 |
| 同龄/同兴趣排序 | 已完成 | `DEFAULT`/`SAME_AGE`/`SHARED_INTEREST`；同龄按出生年差升序，同兴趣按共同标签数降序 | 筛选 Sheet 选择排序；`POST .../directory/users/paging` 带 `sort` |
| 用户卡 / 公开页 | 已完成 | 卡页数据与名录一致 | `GET /api/directory/users/{userId}` + Flutter 远程用户卡 |
| 名录内发起写信 | 已完成 | 从名录进入写信并发信 | `send_letter_sheet` + `POST .../letters/send` |

---

## 5. 邮政信箱（Mailbox）

| 功能 | 状态 | 预期行为 | 验收标准 |
|------|------|----------|----------|
| 发信（挂号/平邮） | 已完成 | 校验、写库、扣票规则正确 | 非 VIP 挂号扣 1 票有流水；平邮进入运输态 |
| 收件箱 / 同步 / 归档 | 已完成 | postal、sync、archive 数据正确 | Flutter 列表与归档一致 |
| 平邮到期自动送达 | 已完成 | 预计到达后状态变为已送达 | **PG + `@Scheduled`**（**不**用 Redis ZSET）；DB `actual_arrival_time` 正确 |
| 挂号扣票事务说明 | 已关闭（不设 FP） | 含义见 `findings.md` §17；线上无账实问题则不立项 | — |
| 平邮加速（扣票） | 已完成 | 发件人可对运输中平邮加速 | `speed-up` + UI；VIP 免扣与流水正确 |
| Accept 建联 | 已完成 | 收信方可 Accept 进入 IM 路径 | `accept-postal` + TIM 侧一致 |
| **Connections（好友列表）** | 已完成 | 邮政 Tab 第二分段展示 **活跃笔友/好友**，与 TIM **会话列表**区分 | **`GET /api/mailbox/friends`**（`bu_friendship`）；**不等同** `getConversationList` |
| 信件详情 | 已完成 | 单封正文与元数据 | `GET .../letters/{id}` |
| IM UserSig 与聊天 | 已完成 | 登录后可与好友发起 **C2C 聊天**并发消息 | `/api/im/usersig` + TIM SDK（聊天页；列表仍以 `/friends` 为准） |
| 双用户 postal/sync 一致性 | 已完成（拉取侧） | 收件方及时看到依赖刷新；增量 `sync` 用 `COALESCE(updated_at,created_at)` | 下拉刷新 + App `resumed` 自动刷新 postal/archive；双机仍建议人工点刷新或后续推送 |
| 从信件上下文「回信」 | 已完成 | 详情页发起回复，后端 `parentLetterId` 关联 | `AppSendLetterInDto.parentLetterId` + Flutter；见 [`doc/plan/08-mock-removal-gaps.md`](plan/08-mock-removal-gaps.md) |

---

## 6. 平邮参数与 IM 好友同步

| 功能 | 状态 | 预期行为 | 验收标准 |
|------|------|----------|----------|
| 平邮延迟区间配置化 | 未开始 | min/max 来自配置非硬编码 | `sys_config` + 发信逻辑读配置 |
| 腾讯 IM 好友 Notifier | 已完成 | 业务建联后调官方 REST，可重试可观测 | `TencentImRestApiClient`、`TencentImFriendshipNotifier`；需 `TENCENT_IM_REST_IDENTIFIER` |

---

## 7. 邮票（Chat Stamp）

| 功能 | 状态 | 预期行为 | 验收标准 |
|------|------|----------|----------|
| 余额查询 | 已完成 | App 展示与 `bu_user` 一致 | `GET /api/stamps/balance` |
| 流水分页 | 已完成 | 用户可查交易历史 | `POST /api/stamps/ledger/paging` + 流水页 |
| 登录赠票 / 发帖奖 / 日上限 | 已完成 | 规则可配置、幂等记账 | `StampGrantService`、`bu_stamp_daily_grant`、`senior-post.stamps-grant.*` |
| 并发扣票安全 | 已完成 | CAS 扣减统一在 `StampAccountService`；并发下余额不为负 | `StampBalanceCasConcurrencyJdbcTest` + `mvn -pl biz test`；寄信/加速走同一 CAS |
| Manage 用户邮票流水页 | 已完成 | 运营分页查询流水 | `POST /webapi/stamps/ledger/paging` + `StampLedgerList` |

---

## 8. VIP

| 功能 | 状态 | 预期行为 | 验收标准 |
|------|------|----------|----------|
| 权益查询与展示 | 已完成（A7-001） | App 从 bootstrap 读 `vipProduct` 展示；`me`/余额仍带 `isVip` | `GET /api/bootstrap/init` 含 `vipProduct`；VIP 中心页读 bootstrap |
| 真订阅 / 应用内支付 | 已关闭 | **不做**；运营/测试用 Manage **`vip-debug`** | 见 `08` §3 |
| VIP 与扣票/加速规则 | 进行中（**FP-A7-003**） | VIP 挂号/加速按配置减免；与调试 VIP 一致 | 与 `VipConfig` / `me` 一致 |

---

## 9. 风控与合规

| 功能 | 状态 | 预期行为 | 验收标准 |
|------|------|----------|----------|
| 用户封禁 / 启用 | 已完成 | 后台操作后 App 行为符合设计 | Manage `user` 状态接口 |
| 设备拉黑 | 已完成 | 后台一键拉黑设备 | `GET /webapi/user/{userId}/devices` + `POST /webapi/user/device/block`；Manage 用户列表 |
| 敏感词在 App 写路径 | 已完成 | 与 §3 一致 | 见 §3 |
| GDPR / 账号注销 | 已完成（MVP） | 申请注销、冷静期、期满冻结；正式注销前解除好友与腾讯删好友 | 见 `08` §3 |
| 举报工单闭环 | 已完成 | 从 App 提交到后台处理 | App + Manage 列表与处理按钮 |

---

## 10. 管理后台（Manage）

| 功能 | 状态 | 预期行为 | 验收标准 |
|------|------|----------|----------|
| 看板 / 用户 / 内容审核 / 举报 / 配置 / 国家 / 敏感词 / 版本 / 公告 / 日志 | 已完成 | 各页可完成日常运营 | `/webapi` 与页面可用 |
| **运营公告（可关闭，非强更）** | 已完成（**FP-X-003**） | 固定版式：标题、版本号、更新说明（纯文本多行） | 见 `findings.md` §18 |
| 邮票流水管理 | 已完成 | 查询用户邮票流水 | `stampLedgerPaging` + 邮票流水页 |
| 设备封禁 UI | 已完成 | 用户列表可操作 `blockDevice` | 同 §9「设备拉黑」 |

---

## 11. 国际化（App / 邮件）

| 功能 | 状态 | 预期行为 | 验收标准 |
|------|------|----------|----------|
| App ARB + 运行时语言 | 已完成（基线） | 设置内切换、`Accept-Language` 与后端一致 | `appLocaleProvider` + ARB + Dio 头 |
| 邮件模板多语言 | 已完成（**FP-A10-001**） | 发信侧按 Locale 渲染 subject/body | `app.mail.passwordReset.*` + Outbox `locale_tag` |

---

## 12. 横切与版本

| 功能 | 状态 | 预期行为 | 验收标准 |
|------|------|----------|----------|
| 邮件服务 + Outbox | 已完成（**FP-X-001**） | 异步发信可重试 | `sys_mail_outbox` + 调度 |
| OSS 预签名 | 已完成 | 各 scene 可上传 | 配置 `senior-post.oss` 后可用 |
| **运营公告（可关闭，非强更）** | 已完成（**FP-X-003**） | 固定版式：标题、版本号、更新说明（纯文本多行）；Manage 表单 + App 模板 | 见 `findings.md` §18 |

---

## 13. 进度速览（按模块）

| 模块 | 已完成（概览） | 主要缺口 |
|------|----------------|----------|
| 1–2 | 注册登录、bootstrap、资料 PATCH、忘记密码、兴趣、头像 | 冷启动拉 `me` 等体验项（不设专项 FP） |
| 3–4 | 墙/名录主链路、写信入口、举报、敏感词、排序 | 按需 UX（不设专项 FP） |
| 5–6 | 发收信、归档、PG Worker、加速、IM、回信 | **FP-A5d-001** 延迟配置化（可选） |
| 7–8 | 余额、流水、赠票、CAS、VIP bootstrap、`vip-debug` | **FP-A7-003** 规则对齐 |
| 9–11 | Manage 主体、注销 MVP、i18n 基线 | 运营公告与邮件横切已闭环 |

---

*文档版本：1.6 · 与 `01-feature-list` v1.8 对齐 2026-05-09；细粒度 FP 以 `01` 为准。*
