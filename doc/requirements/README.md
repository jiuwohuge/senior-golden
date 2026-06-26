# 时光邮局 — 需求文档

本文档覆盖「时光邮局」App 的全部业务需求，按模块独立成文。

---

## 目录

| 文件 | 模块 | 已实现 |
|------|------|--------|
| [01-auth.md](01-auth.md) | 模块 1：注册与登录 | ✅ |
| [02-topic-mailbox.md](02-topic-mailbox.md) | 模块 2：主题信箱（首屏） | ✅ |
| [03-directory.md](03-directory.md) | 模块 3：笔友大厅 | ✅ |
| [04-compose.md](04-compose.md) | 模块 4：统一写信流程 | ✅ |
| [05-time-letter.md](05-time-letter.md) | 模块 5：时光信 | ✅ |
| [06-mailbox.md](06-mailbox.md) | 模块 6：信箱（收件箱 / 笔友对话） | ✅ |
| [07-memorial.md](07-memorial.md) | 模块 7：纪念册 | ✅ |
| [08-profile.md](08-profile.md) | 模块 8：我的（资料 / 设置 / 邮票） | ✅ |
| [09-safety.md](09-safety.md) | 模块 9：安全与反欺诈 | ✅ |
| [10-cold-start.md](10-cold-start.md) | 模块 10：冷启动与种子数据 | ❌ 待开发 |
| [11-payment.md](11-payment.md) | 模块 11：付费与盈利 | ❌ 待开发 |

---

## 需求编号约定

每个需求条目格式：`{模块前缀}-{序号}`

| 前缀 | 模块 |
|------|------|
| AU | 注册与登录 |
| TM | 主题信箱 |
| DL | 笔友大厅 |
| CP | 统一写信流程 |
| TL | 时光信 |
| MB | 信箱 |
| MR | 纪念册 |
| PR | 我的 |
| SF | 安全与反欺诈 |
| CS | 冷启动与种子数据 |
| PM | 付费与盈利 |
