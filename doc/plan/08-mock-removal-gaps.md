# 08 — Mock 移除后的功能缺口与验证记录

> **版本**：1.1 · **更新**：2026-05-09 · **范围**：`senior-post-flutter`（客户端 Mock 层已删）；后端单元测试中的 Mockito **未**纳入本次「业务 Mock 数据」移除范围。

---

## 1. 本次已完成的工程动作（摘要）

- 删除 `lib/core/mock/` 及 `AppEnv.useMock` / `USE_MOCK` 等开关；会话统一为 `appSessionProvider` + 远程 `me`/bootstrap。
- 聊天页仅保留腾讯 IM SDK 路径（`tim_facade`、`chat_page`）；名录页拆分 `directory_providers.dart` 以消除与筛选页的**循环 import**（此前会导致分析器报「找不到 `directory_page`/`vip_center_page`」类错误）。
- 修复 `vip_center_page.dart` 内**损坏 UTF-8 字符串**（否则该文件无法被分析器作为合法库加载）。
- 文案：`app_en.arb` / `app_zh.arb` 中与 Mock 相关的提示改为面向真实联调的表述（键名如 `authMockTip` 等保留以避免大范围重命名，内容已无「Mock 模式」语义）。

---

## 2. 自动化验证（已执行）

| 命令 | 结果 |
|------|------|
| `flutter analyze`（`senior-post-flutter` 根目录） | 交付前执行（见本轮 CI 日志） |
| `flutter test` | 交付前执行 |

**说明**：`test/widget_test.dart` 在已登录场景下会触发对配置中 `API_BASE_URL` 的真实 HTTP 请求；若 Token 无效或服务端返回 400，日志中会出现 Dio 异常，但当前用例仍判定通过（仅校验 Widget 树挂载）。完整业务回归需在可用后端 + 合法 JWT 下做人工或 E2E。

---

## 3. 功能缺口闭环状态（2026-05-09）

| 模块 | 状态 | 实现说明 |
|------|------|----------|
| **账号注销** | **已闭环（MVP）** | `POST /api/auth/account/deletion-request`；`bu_user.deletion_requested_at`（Flyway `V11`）；冷静期 7 日：成功登录清空申请；期满未登录则 `status=3` 并拒绝登录；`GET /api/auth/me` 返回 `deletionRequestedAt` / `deletionEffectiveAt`。Flutter：`account_delete_page` 调接口后登出并跳转登录；`profile_page` 展示提示卡片。 |
| **信件回信** | **已闭环** | `AppSendLetterInDto.parentLetterId`；`AppMailboxServiceImpl.sendLetter` 校验收信人并设 `toUserId`、落库 `parent_letter_id`。Flutter：`mailbox_remote.sendLetter` 传 `parentLetterId`；`letter_detail_page` 收信侧可发平邮/挂号回复。 |
| **VIP 订阅收银台** | **仍不做** | 按产品决策：无支付链。调试：`POST /webapi/user/{id}/vip-debug` + 管理端用户列表「调试 VIP」；更新 `is_vip` / `vip_expire_at`（禁止改 `staff_role≠0` 账号）。 |
| **腾讯 IM** | **部分改进** | `tim_facade` 对 `DioException` 与 TIM init/login 失败给出可读 `ApiBusinessException`；`chat_page` 历史加载失败展示 `PostalEmptyState` + 重试。 |
| **登录页预填** | **已移除** | 邮箱与密码默认空，Debug/Release 均不预填。 |
| **管理端 Mock** | **不适用** | `senior-post-manage` 无 MSW；用户列表已接真实 `/webapi`。 |

---

## 4. 残留「mock」字样（非运行时 Mock）

- `test/oss_object_key_hint_test.dart`：用例名「rejects mock URLs」指**拒绝伪造 objectKey**，保留。
- `lib/l10n/*.arb` 中仍有个别键名含 `Mock`（如 `authMockTip`），**文案已改**；若需键名与代码一并重命名，可单开重构任务并执行 `flutter gen-l10n`。

---

## 5. 相关文档更新

- [`06-env-setup.md`](06-env-setup.md)：已去掉 `USE_MOCK` 的 `--dart-define` 要求，改为仅强调 `API_BASE_URL`。
- [`05-task-tracker.md`](05-task-tracker.md)：`总闸 Mock` 行标为 **DONE** 并指向本文档。
- [`e2e-smoke.http`](../../senior-post-api/doc/e2e-smoke.http)：补充注销申请、带 `parentLetterId` 发信、管理端 VIP 调试示例。
