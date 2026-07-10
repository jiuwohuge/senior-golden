---
name: frontend-engineering-conventions
description: Enforces senior-post frontend engineering conventions for Flutter (senior-post-flutter) and Manage (senior-post-manage): industry-standard comments on public APIs/complex branches, key-path logging without PII, Riverpod/go_router/dio patterns, and Ant Design React clarity. Use when implementing, modifying, or reviewing Dart/TS/TSX business logic, providers, remotes, pages, or services — not for pure visual design (use frontend-design for UI aesthetics).
---

# Frontend Engineering Conventions

## Scope

| 端 | 路径 | 栈 |
|----|------|-----|
| App | `senior-post-flutter/` | Flutter + Riverpod + go_router + dio |
| Admin | `senior-post-manage/` | React 18 + Vite + Ant Design 5 |

视觉/适老化仍遵循 `frontend-design` skill + `.cursor/rules/frontend-design-required.mdc`。  
**本 skill 管：注释、日志、业务可读性与排障约定。**

## Mandatory Rules

1. **Public / 复杂逻辑必须有注释** — 见 §Comments。
2. **关键路径必须有日志** — 见 §Logging；禁止刷屏与敏感信息。
3. Prefer existing project patterns（`postal_*` widgets、`*_remote.dart`、`services/api.ts`）over ad-hoc duplicates.
4. Do not comment out dead code; delete unused features（与 PLAN「废弃即删」一致）.

## Comments

目标：解释 **为什么 / 业务约束 / 分支条件**，不复述语法。

| 位置 | 必须写什么 |
|------|------------|
| **公开 Widget / Page 类** | 一句话职责（对谁、解决什么） |
| **Provider / Repository / Remote 公开方法** | 对应后端 API、副作用、错误如何上抛 |
| **复杂 `if` / `switch` / 状态机** | 每个非显然分支的业务原因（额度、审核、未登录、幂等） |
| **非显然常量 / 魔法数** | 来源（bootstrap 字段、PRD、设计 token） |
| **Manage 页面/服务导出函数** | 接口路径与权限假设（若非显然） |

**禁止：**

- `// increment i` 类废话
- 大段注释掉的旧实现
- 注释中写 Token、密码、完整用户隐私

### Flutter 示例

```dart
/// 邮局首页：展示今日额度与信箱摘要，主 CTA 进入写信。
/// 数据：bootstrap.dailyLetterQuota + postalInboxLettersProvider。
class PostOfficeHomePage extends ConsumerWidget {
  // ...
}

// 在途：仅统计投递中状态（与信箱 Tab「在途」语义对齐）
final inTransit = letters.where((l) => l.status == LetterStatus.delivering).length;
```

### Manage (TS/TSX) 示例

```ts
/**
 * 拉取仪表盘汇总。失败时由页面 ErrorBoundary / message 处理。
 * GET /webapi/dashboard/stats
 */
export async function fetchDashboardStats(): Promise<DashboardStats> {
  // ...
}
```

## Logging

### Flutter

- 使用 `debugPrint` / 项目已有 logger；**仅 Debug 或显式诊断路径**，避免 Release 噪音。
- **必须记录：** API 失败（含 path + 业务 code，不含 body 明文敏感字段）、登录态失效清理、关键写操作失败（发信/资料保存）。
- 成功路径默认不打日志；仅在难复现流程（IM 登录、OSS 直传）保留简短 `debugPrint`。

```dart
try {
  await remote.sendLetter(body);
} catch (e, st) {
  debugPrint('sendLetter failed: $e\n$st');
  rethrow;
}
```

### Manage

- 使用 `console.warn` / `console.error`（或项目统一 logger）；开发态可 `console.debug`。
- **必须记录：** API 非 2xx、上传失败、权限不足导致的跳转。
- 禁止 `console.log` 整包 response（易含 PII）；只打 `code` / `message` / 资源 id。

## Self-Check

- [ ] 新增/修改的公开方法或复杂分支有「为何」注释
- [ ] 关键写路径 / API 失败有日志，且无 Token/密码/敏感 PII
- [ ] 无大段注释死代码
- [ ] UI 任务仍遵守 `frontend-design` + 适老化规则（若涉及界面）
