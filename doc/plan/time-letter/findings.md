# 时光邮局 — 研究发现

> **版本**：1.0 · **更新**：2026-05-25 · **维护人**：AI + Owner  
> 本文档记录**仓库内可验证事实**与定稿差异，供 [task_plan.md](./task_plan.md) 引用。

## Requirements（§5 摘要）

- **产品边界**：老年人同龄慢社交，**非**家族/亲友 App
- **对象**：未来的自己 + Connections 互关好友
- **核心体验**：滑动封缄 + 拆信仪式；纯文本 v1
- **触达**：仅 App 内（角标/Banner），无 Push v1
- **Manage**：列表查看 + 下架 + 异常复核

## 现网代码事实（2026-05-25 摸底）

### 尚无时光信实现

- 代码库内无 `time_letter` / `TimeLetter` / `bu_time_letter`
- 最新 Flyway：**V25__moderation_sys_config.sql** → 新迁移建议 **V26**

### 可复用组件

| 能力 | 路径 | 复用方式 |
|------|------|----------|
| 互关校验 | `FriendshipService.areActiveFriends` | 发送前强制（与 IM/Directory 一致） |
| 黑名单 | `AppBlacklistService.areMutuallyBlocked` | 封缄前校验；拉黑后取消待发 |
| 邮票 CAS | `StampAccountService.tryDecrementBalance` | 封缄扣票 + 取消/失败退票 |
| 敏感词 | `SensitiveWordService.assertPlainTextAllowed` | 封缄时校验 |
| 平邮调度模式 | `StandardLetterDeliveryService` + `@Scheduled` | 仿照，改扫描条件为 `delivery_date + tz` |
| Manage 列表模板 | `PostcardList.tsx` + `AdminContentController` | 下架 Drawer + paging |
| 邮政 UI 组件 | `postal_painters.dart`, `PostalStampBadge` | 拆信/封缄视觉 |

### 不可混用（红线）

| 现网 | 原因 |
|------|------|
| `bu_letter` / `LetterBizStatus` | 绑 Accept 建联、10–120 分钟平邮 |
| `/api/mailbox/*` postal/archive | inbox 语义是 `recipient_read_at`，非未来封存 |
| `sendLetter` 好友规则 | **不要求**互关；时光信必须互关 |
| `speedUpLetter` / `earlyOpenLetter` | v1 明确不加急 |
| `StandardLetterDeliveryScheduler` 直接扫同表 | 状态/时长语义不对 |

### 社交信 vs 时光信：好友语义差异

```
社交信 sendLetter：任意合法用户（仅黑名单）→ 送达后 acceptPostalContact 建联
时光信 seal：必须先 areActiveFriends → 再写入 PENDING
```

参考：`AppMailboxServiceImpl.sendLetter` vs 拟 `AppTimeLetterServiceImpl.seal`

## Flutter 落点

| 项 | 现状 | 计划 |
|----|------|------|
| Mailbox Tab | 2 Tab：Postal / Connections | 增第 3 Tab「时光」 |
| 用户卡寄信 | `showPostalSendLetterSheet` | 增「寄 TA 时光信」（须互关） |
| Connections | 仅进 `/chat/:userId` | 增时光信入口 |
| 路由 | 无 time-letter | 新增 compose/open |
| 模块目录 | 无 | `lib/features/time_letter/` |

## 数据域补充（相对 §5.6）

§5.6 骨架基础上，实现建议补充：

| 字段 | 用途 |
|------|------|
| `reply_to_id` | Past Me ↔ Future 回信链 |
| `seal_request_id` | 封缄幂等，防弱网重复扣票 |
| `cancelled_at`, `fail_reason`, `takedown_reason` | 审计 |
| `status` 含 `DRAFT/CANCELLED/FAILED` | 完整状态机 |

`content_tag`：v1 **单选**（与 §5.3 四类标签一致）

## 注销与长周期信

- 删号冷静期：`V11__user_deletion_request.sql` + `AppAuthService.finalizeAccountDeletion`
- 时光信最长 2 年：进入冷静期须展示**待发清单**，用户选取消或继续（§4 B8 / Cursor 审阅补充）
- 冷静期结束：`FriendshipService.deactivateAllFriendshipsForUser` 已存在 → 在途笔友信应转 FAILED + 退票

## v1.5 / v2（本次不实现）

单图 JPG、ASR、心情反馈 opt-in、兴趣推荐、PDF、Push/IM、周期信、AI 润色 — 见提案 §5.4–§5.5

## Resources

| 文档/路径 | 说明 |
|-----------|------|
| [时光邮局功能提案.md](../../../时光邮局功能提案.md) | §5 唯一对外定稿 |
| [01-dev-plan.md](./01-dev-plan.md) | API/文件/测试清单 |
| `.cursor/plans/时光邮局_v1_开发_44a13890.plan.md` | Cursor 完整开发计划 |
| `senior-post-api/.../AppMailboxServiceImpl.java` | 邮票/发信参考 |
| `senior-post-api/.../StandardLetterDeliveryService.java` | 调度参考 |
| `senior-post-flutter/.../mailbox_page.dart` | 第三 Tab 落点 |

## Issues Encountered

| Issue | Resolution |
|-------|------------|
| 根目录 `task_plan.md` 已是全项目索引 | 时光信专用计划放入 `doc/plan/time-letter/` |
