# 任务总表（索引）

> **文档元信息**  
> **版本**：1.4 · **更新**：2026-05-09 · **维护人**：AI + Owner

**角色**：与根目录 [`PLAN.md`](PLAN.md) 对齐；本文件只做**进度总览 + 文档导航**，细则见 [`doc/plan/`](doc/plan/) 与 [`doc/plan/00-documentation-governance.md`](doc/plan/00-documentation-governance.md)。

| 文档 | 说明 |
|------|------|
| [feature-overview.md](doc/feature-overview.md) | **精简功能总览**：模块→功能表（描述、状态、预期、验收） |
| [doc/README.md](doc/README.md) | **`doc/` 索引**：分类导航与快速链接 |
| [00-documentation-governance.md](doc/plan/00-documentation-governance.md) | **文档治理**：真源层级、元信息、淘汰与对齐流程 |
| [01-feature-list.md](doc/plan/01-feature-list.md) | 功能点清单（FP 编号 + 已有/缺口状态） |
| [02-requirements.md](doc/plan/02-requirements.md) | 逐 FP：目标、场景、业务逻辑、技术要点、验收 |
| [03-priority-grouping.md](doc/plan/03-priority-grouping.md) | P0–P3、依赖图、Sprint 1–4 分组 |
| [04-dev-plan.md](doc/plan/04-dev-plan.md) | 技术方案摘要、人日、风险 |
| [05-task-tracker.md](doc/plan/05-task-tracker.md) | 负责人、周期、状态、交付物 |
| [06-env-setup.md](doc/plan/06-env-setup.md) | 环境与外部依赖勾选清单 |
| [07-gap-analysis-and-roadmap.md](doc/plan/07-gap-analysis-and-roadmap.md) | 遗漏功能系统化清单 + 四阶段路线图 + 资源口径 |
| [findings.md](findings.md) | 摸底事实与代码证据（持续追加） |
| [progress.md](progress.md) | 会话级动作日志 |

**默认口径**：负责人 `AI + Owner`；周期 **人日（D）**；日历用 **Wn** 相对周，避免与真实日历强绑。

---

## Phase 进度（勾选即完成）

| Phase | 摘要 | 状态 |
|-------|------|------|
| P0 | 阅读 `PLAN.md`「功能清单 / 开发计划 / 阻塞」并与 `01` 表对齐 | [x] 2026-05-09 全量梳理已对齐 `01`/`05`/`progress` |
| P1 | M2 主路径：发帖/评论/目录/写信/OSS/Flutter Mock→REST | [~] 核心 REST 已接；**总闸 Mock 策略文档化**、**E2E 冒烟自动化/录屏**、审核态 UX 加强仍待 |
| P2 | M3：平邮延迟队列、邮票事务、信箱全 REST、Manage 邮票页 | [~] 平邮到期 Worker、加速、赠票、IM REST、Connections、**Manage 邮票流水页**、**用户设备拉黑 UI** 已落地；**平邮区间配置化**、**挂号事务边界复审** 仍待 |
| P3 | M1/M4：邮件 outbox、AES、GDPR、版本强更、密码风控 | [ ] |
| P4 | 体验债：B14 主题、B15 登录注册视觉、A10 扫尾 | [ ] |
| P5 | 质量闸门：`flutter analyze`、后端冒烟、IM 双端、UAT 清单 | [~] 分析/单测常态绿；**双用户集成/E2E**、**生产 IM 配置验收** 仍待 |

---

## 决策与错误记录

| 日期 | 类型 | 内容 |
|------|------|------|
| 2026-05-02 | 决策 | 外部不可信内容只写入 `findings.md`，不写回本索引 |
| 2026-05-02 | 错误 | `session-catchup.py` 本机缺失 → 跳过，以仓库事实为准 |
| 2026-05-07 | 错误 | `session-catchup.py` 再次不可用（exit 9009）→ 跳过 |
| 2026-05-02 | 决策 | 文档体系 hybrid：`task_plan.md` + `doc/plan/01–07` |
| 2026-05-07 | 决策 | 路线图叙事入口：[`07-gap-analysis-and-roadmap.md`](doc/plan/07-gap-analysis-and-roadmap.md)；**执行状态**以 [`01-feature-list.md`](doc/plan/01-feature-list.md) + **§2.0**（`07`）+ [`05-task-tracker.md`](doc/plan/05-task-tracker.md) 为准 |
| 2026-05-09 | 决策 | 文档真源：`01`+`05` 为功能与 Sprint；`PLAN` 为架构基线；新增 `doc/README.md`、`00-documentation-governance.md` |
| 2026-05-09 | 决策 | **FP-A9-003**：`GET /webapi/user/{userId}/devices` + Manage `UserList`「设备拉黑」；`blockDevice` 请求体与后端 DTO 对齐 |
| 2026-05-09 | 决策 | **PLAN A7**：**FP-A7-001** 以 **`bootstrap/init` → `vipProduct`** 交付；**FP-A7-002/003**（订阅全链、扣费真源）仍为缺口，见 `01` |

---

## 下一步（执行开发时）

1. 打开 [`07-gap-analysis-and-roadmap.md`](doc/plan/07-gap-analysis-and-roadmap.md) **§2.0** 与 [`01-feature-list.md`](doc/plan/01-feature-list.md) 核对缺口；再打开 [`05-task-tracker.md`](doc/plan/05-task-tracker.md) 勾选具体 FP。
2. 每完成一个 FP：更新 `01`/`05`、在 [progress.md](progress.md) 写一行、必要时回写 `PLAN.md` 勾选。

---

## OSS 私有读改造（2026-05-08 规划）

**决策**：不引入匿名公共桶/公共前缀；**仅**通过服务端 **GET 预签名 URL** 让 App / Web 展示私有桶对象。跟踪 FP：**[FP-X-005](doc/plan/05-task-tracker.md)**；事实与约束见 [findings.md §6](findings.md)。

| 子阶段 | 内容 | 状态 |
|--------|------|------|
| O1 | **契约**：`client` 增加 `GET` 或 `POST` 读签名 API（如批量 `objectKeys` → `signedUrl` + `expireAt`）；`OssProperties` 增加 `getExpireSeconds`（与 PUT TTL 分离） | [x] |
| O2 | **服务**：`AppOssService` 抽取可复用 OSSClient 构建；实现 `signGet`；**校验** key 属于 `keyPrefix`、可选 `scene/userId` 与当前用户及业务权限（明信片作者/审核态、信件参与者等） | [x] |
| O3 | **读路径集成（选一或组合）**：(a) 列表/详情 VO 出站前把存库的 URL/`objectKey` 转为短时 signed URL；(b) 独立批量换签供 Flutter/Web 懒加载 | [x] |
| O4 | **数据口径**：约定 DB 存 **objectKey**（或 `https://bucket...` 可解析出 key）；迁移脚本或兼容层：历史全 URL 尝试解析为 key；**不配置** `public-read-base-url` 于生产私有桶 | [~] 解析层已有；历史数据迁移脚本非首发硬需求 |
| O5 | **Flutter**：发帖仍 `put-sign` + PUT；展示侧对 403/过期重拉列表或调换签；`Image.network` 错误回调 | [x] `PostalOssNetworkImage` + `/api/oss/get-sign` 单次自愈；墙/详情/头像 |
| O6 | **Manage**：审核台图片走 `/webapi` 鉴权后换签（可与 App 共用 service，Controller 分轨） | [x] `AdminOssController` + `api.ts` |
| O7 | **验证**：`mvn … test` 覆盖签名校验与非法 key；Knife4j 手动换签 + 浏览器打开图片；`dart analyze` | [~] `OssReadableKeyValidatorTest` + `oss_object_key_hint_test`；Knife4j/浏览器仍建议人工过一遍 |

**非目标（本 FP）**：独立公开 OSS 目录、Bucket Policy 匿名读、CDN 对公匿名回源。
