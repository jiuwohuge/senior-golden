# 任务总表（索引）

**角色**：与根目录 [`PLAN.md`](PLAN.md) 对齐；本文件只做**进度总览 + 文档导航**，细则见 [`doc/plan/`](doc/plan/)。

| 文档 | 说明 |
|------|------|
| [01-feature-list.md](doc/plan/01-feature-list.md) | 功能点清单（FP 编号 + 已有/缺口状态） |
| [02-requirements.md](doc/plan/02-requirements.md) | 逐 FP：目标、场景、业务逻辑、技术要点、验收 |
| [03-priority-grouping.md](doc/plan/03-priority-grouping.md) | P0–P3、依赖图、Sprint 1–4 分组 |
| [04-dev-plan.md](doc/plan/04-dev-plan.md) | 技术方案摘要、人日、风险 |
| [05-task-tracker.md](doc/plan/05-task-tracker.md) | 负责人、周期、状态、交付物 |
| [06-env-setup.md](doc/plan/06-env-setup.md) | 环境与外部依赖勾选清单 |
| [findings.md](findings.md) | 摸底事实与代码证据（持续追加） |
| [progress.md](progress.md) | 会话级动作日志 |

**默认口径**：负责人 `AI + Owner`；周期 **人日（D）**；日历用 **Wn** 相对周，避免与真实日历强绑。

---

## Phase 进度（勾选即完成）

| Phase | 摘要 | 状态 |
|-------|------|------|
| P0 | 阅读 `PLAN.md`「功能清单 / 开发计划 / 阻塞」并与 `01` 表对齐 | [ ] |
| P1 | M2 主路径：发帖/评论/目录/写信/OSS/Flutter Mock→REST | [ ] |
| P2 | M3：平邮延迟队列、邮票事务、信箱全 REST、Manage 邮票页 | [ ] |
| P3 | M1/M4：资料 API、邮件、AES、GDPR、举报 App 端、版本强更 | [ ] |
| P4 | 体验债：B14 主题、B15 登录注册视觉 | [ ] |
| P5 | 质量闸门：`flutter analyze`、后端冒烟、IM 双端 | [ ] |

---

## 决策与错误记录

| 日期 | 类型 | 内容 |
|------|------|------|
| 2026-05-02 | 决策 | 外部不可信内容只写入 `findings.md`，不写回本索引 |
| 2026-05-02 | 错误 | `session-catchup.py` 本机缺失 → 跳过，以仓库事实为准 |
| 2026-05-02 | 决策 | 文档体系 hybrid：`task_plan.md` + `doc/plan/01–06` |

---

## 下一步（执行开发时）

1. 打开 [05-task-tracker.md](doc/plan/05-task-tracker.md)，从 **Sprint 1 / P0** 第一条 `TODO` 开始勾选。
2. 每完成一个 FP：更新 `05`、在 [progress.md](progress.md) 写一行、必要时回写 `PLAN.md` 勾选。
