# 时光邮局 v1 — 开发任务计划

> **文档元信息**  
> **版本**：1.0 · **创建**：2026-05-25 · **状态**：留档待开工 · **维护人**：AI + Owner  
> **需求真源**：[时光邮局功能提案.md](../../../时光邮局功能提案.md) **§5（最终统一方案）**  
> **Cursor 合并计划**：`.cursor/plans/时光邮局_v1_开发_44a13890.plan.md`

## Goal

交付 **时光邮局 v1**：老年人慢社交 App 内，用户给**未来的自己**或 **Connections 互关笔友**写纯文本私密信；**滑动封缄**扣票 → 按收信人当地日定时送达 → **拆信仪式**阅读；独立 `bu_time_letter` 数据域，与 `bu_letter` 短平邮严格分离。

## Current Phase

**Phase 0 — 留档与研究**（未开工）

## Phases

### Phase 0：需求定稿与留档

- [x] 多轮辩论 §2.1～§2.14
- [x] Cursor §4 + Claude §5 合并定稿
- [x] 开发计划与代码摸底
- [x] 本目录 planning-with-files 留档
- **Status:** complete

### M1：数据域 + 后端垂直切片（P0，~1 周）

- [ ] Flyway `V26__time_letter.sql`（下一序号以仓库最新 migration 为准）
- [ ] `TimeLetterDomain` / Mapper / Enums / `TimeLetterProperties`
- [ ] `AppTimeLetterApi` + DTO/VO（client）
- [ ] `AppTimeLetterServiceImpl`：draft / seal / cancel / list / open / limits
- [ ] `TimeLetterDeliveryService` + Scheduler（时区送达 + FAILED 退票）
- [ ] 单元测试：互关、限额、24h 取消、时区边界
- **Status:** pending
- **验收：** Postman seal → 改 delivery_date → scheduler → open

### M2：Flutter 核心 UX（P0，~1 周）

- [ ] `mailbox_page.dart` TabController 2→3，「时光」子 Tab
- [ ] `lib/features/time_letter/*`（remote / providers / compose / open / seal）
- [ ] 路由 `/time-letter/compose`、`/time-letter/:id/open`
- [ ] 入口：用户卡 / Connections / 最近 3 位收信人
- [ ] l10n 中英文
- **Status:** pending
- **验收：** 真机主路径；余额不足阻断；24h 取消退票

### M3：仪式、纪念册、触达与促活（P1，~1 周，可裁剪）

- [ ] 滑动封缄 / 拆信邮戳动效 / 封缄成功页
- [ ] 纪念册 + 星标 + 私密统计
- [ ] App 内 Banner（在途 / 今日待拆 / 7·3·1·当天）
- [ ] 新手引导 + 冷启动「3 个月后第一封给自己」
- [ ] Past Me 回信 / 快捷回邮（可选裁剪）
- [ ] PIN / 年历 / 90 天·周年 gentle 提示（可选裁剪）
- **Status:** pending

### M4：Manage + 安全兜底（P0 合规，~3–4 天）

- [ ] `AdminTimeLetterApi` + Controller
- [ ] `TimeLetterList.tsx` 列表 + 下架（reason 必填）
- [ ] 异常高频 / 被举报复核队列（v1 可简化为 Manage 筛选）
- [ ] 注销冷静期：待发信清单 API（对接 `V11` 删号流程）
- **Status:** pending

### Phase 5：验收与交付

- [ ] §5.3 DoD：自己+笔友闭环 / 拉黑失败退票 / Manage 下架
- [ ] `mvn -pl biz -am test` + `flutter analyze`
- **Status:** pending

## 共识基线（§5.1，开发不可违背）

1. 收信人：仅自己 + 互关笔友；未成年不可收社交信
2. 独立表 `bu_time_letter`，禁止扩展 `bu_letter`
3. 封缄扣 1 邮票；24h 内取消全额退票
4. 送达：收信人当地日历日 00:00；最长 2 年
5. v1 不做：Push/IM 通知、加急、批量寄、上墙、游戏化、图片（v1.5）

## 状态机

```
DRAFT → PENDING → DELIVERED → READ
         ↓              ↓
     CANCELLED        FAILED
```

## 默认配额（§5.7）

| 项 | 默认值 |
|----|--------|
| 每日创建 | ≤ 5 |
| 同一收件人 30 天 | ≤ 3 |
| 在途总数 | ≤ 20 |
| 正文字数硬上限 | 1500（≥800 软提示） |
| 封缄后预览正文 | 不能（仅可取消） |

## Key Questions（开工前确认）

1. Flyway 版本号：当前最新 **V25**，新迁移建议 **V26**
2. Flutter TTS：项目是否已有 `flutter_tts`？无则 M2 评估引入或延后
3. 删号冷静期 hook：`AppAuthService.finalizeAccountDeletion` 是否在本迭代挂待发信清单？
4. M3 裁剪范围：是否 v1 首发必须含年历/PIN/促活提示？

## Decisions Made

| 决策 | 理由 |
|------|------|
| 表名 `bu_time_letter` | 避免与明信片墙 `postcard` 混淆 |
| API 前缀 `/api/app/time-letter/*` | 与 `/api/mailbox/*` 分离 |
| 互关发送前强制 `areActiveFriends` | 社交信 `sendLetter` 不要求互关，时光信必须 |
| 仅星标，无三档重要度 | §5.2 拍板 |
| Mailbox「时光」第三 Tab | 不新增底部 Tab |
| PG 定时扫表 | 与平邮一致，不用 Redis ZSET |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
| — | — | 尚未开工 |

## Notes

- 实现约束详见 [findings.md](./findings.md)
- 会话日志见 [progress.md](./progress.md)
- 完整 API/文件清单见 [01-dev-plan.md](./01-dev-plan.md)
