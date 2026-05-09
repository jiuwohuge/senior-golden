# 项目文档索引（`doc/`）

> **文档元信息**  
> **版本**：1.0 · **更新**：2026-05-09 · **维护人**：AI + Owner

---

## 快速导航

| 我想… | 打开 |
|--------|------|
| **查某功能是否做完、缺口在哪** | [`plan/01-feature-list.md`](plan/01-feature-list.md) |
| **看 Sprint 谁在做、验收与交付物** | [`plan/05-task-tracker.md`](plan/05-task-tracker.md) |
| **看遗漏与推荐波次（路线图）** | [`plan/07-gap-analysis-and-roadmap.md`](plan/07-gap-analysis-and-roadmap.md)（读完看 **§2.0 对齐表**） |
| **模块一页总览（非 FP）** | [`feature-overview.md`](feature-overview.md) |
| **文档怎么维护、谁是真源、淘汰规则** | [`plan/00-documentation-governance.md`](plan/00-documentation-governance.md) |
| **产品需求全文（不按迭代更新）** | [`1、需求文档.md`](1、需求文档.md) |
| **会话/审计轨迹** | 仓库根目录 [`progress.md`](../progress.md)、[`findings.md`](../findings.md) |
| **架构与技术栈基线** | 仓库根目录 [`PLAN.md`](../PLAN.md) |
| **任务总索引** | 仓库根目录 [`task_plan.md`](../task_plan.md) |

---

## 目录结构

```
doc/
├── README.md                    ← 本索引
├── feature-overview.md          模块级状态总览（须与 01 同步）
├── 1、需求文档.md               产品需求归档（见文首定位说明）
└── plan/
    ├── 00-documentation-governance.md   治理标准（真源、元信息、淘汰）
    ├── 01-feature-list.md       FP 真源
    ├── 02-requirements.md       逐 FP 需求
    ├── 03-priority-grouping.md  优先级与 Sprint 分组
    ├── 04-dev-plan.md           技术方案与人日
    ├── 05-task-tracker.md       任务跟踪真源
    ├── 06-env-setup.md          环境与依赖勾选
    └── 07-gap-analysis-and-roadmap.md  遗漏 + 路线图 + §2.0 代码对齐
```

**后端专项**：`senior-post-api/底层框架能力.md`（框架约定，与 `01` 独立）。

---

## 变更记录

| 日期 | 变更 |
|------|------|
| 2026-05-09 | 初版索引；与 `00-documentation-governance` 配套 |
