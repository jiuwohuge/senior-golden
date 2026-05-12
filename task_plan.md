# 任务总表（索引）

> **文档元信息**  
> **版本**：1.6 · **更新**：2026-05-09 · **维护人**：AI + Owner

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
| P1 | M2 主路径 REST + Flutter 远程 | [x] 核心已交付；Mock 已移除（见 `08`） |
| P2 | M3：平邮、邮票、信箱、Manage 运营页 | [x] Worker=**PG 定时**（**不做 Redis ZSET**）；邮票/IM/流水/设备拉黑已落地；**平邮区间配置化**仍可选（FP-A5d-001） |
| P3 | 合规横切：邮件、AES、设备、公告 | [~] **注销 MVP** 已落地；**待**：**FP-A1-006**、**FP-X-001**、**FP-A1-007**、**FP-X-003**（结构化版本公告）、**FP-A10-001** |
| P4 | （已合并） | [x] 原 B14/B15、全量 ARB 专项、UAT/E2E 等 **已从 backlog 移除**（2026-05-09） |
| P5 | 质量闸门 | [~] `flutter analyze` / 后端单测常态绿；**不设**双用户 E2E 专项；生产 IM 配置仍依赖运维 |

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
| 2026-05-09 | 决策 | **PLAN A7**：**FP-A7-001** `bootstrap` → `vipProduct`；**真订阅/支付与 FP-A7-002** 从 backlog **移除**；**FP-A7-003** 保留 |
| 2026-05-09 | 决策 | **平邮送达**：仅 **PG + `@Scheduled`**，**关闭** Redis ZSET 方案 |
| 2026-05-09 | 决策 | **删除 backlog**：FP-A1-004、A3-008、A7-002、A8-004/增强、A9-004、A10 ARB 专项、B14/B15、X-004、E2E/UAT 专项、OSS 历史批量迁移脚本 |
| 2026-05-09 | 决策 | **FP-X-003** 定案：**结构化字段**（标题、版本号展示、纯文本更新内容）+ App **模板排版**；**不做** Markdown/自由富文本默认；见 `findings.md` §18 |
| 2026-05-09 | 决策 | **B14/B15** 不作为交付项，**PLAN 阻塞表**标为已移除 |
| 2026-05-09 | 决策 | **下一开发波次**：**FP-A1-006** → **FP-X-001** → **FP-A1-007** → **FP-X-003** → **FP-A10-001**（见 `05` Sprint 4、`07` §3） |
| 2026-05-09 | 决策 | **注销生效**：冷静期结束 `finalizeAccountDeletion` 前 **`bu_friendship` → status=0** + 腾讯 REST **`sns/friend_delete`（Delete_Type_Both）**；细节见 `findings.md` §15 |

---

## 下一步（执行开发时）

1. 打开 [`07-gap-analysis-and-roadmap.md`](doc/plan/07-gap-analysis-and-roadmap.md) **§2.0 / §3** 与 [`01-feature-list.md`](doc/plan/01-feature-list.md) 核对缺口；再打开 [`05-task-tracker.md`](doc/plan/05-task-tracker.md) 勾选具体 FP。
2. 每完成一个 FP：更新 `01`/`05`、在 [progress.md](progress.md) 写一行、必要时回写 `PLAN.md` 勾选。

---

## OSS 私有读改造（2026-05-08 规划）

**决策**：不引入匿名公共桶/公共前缀；**仅**通过服务端 **GET 预签名 URL** 让 App / Web 展示私有桶对象。跟踪 FP：**[FP-X-005](doc/plan/05-task-tracker.md)**；事实与约束见 [findings.md §6](findings.md)。

| 子阶段 | 内容 | 状态 |
|--------|------|------|
| O1 | **契约**：`client` 增加 `GET` 或 `POST` 读签名 API（如批量 `objectKeys` → `signedUrl` + `expireAt`）；`OssProperties` 增加 `getExpireSeconds`（与 PUT TTL 分离） | [x] |
| O2 | **服务**：`AppOssService` 抽取可复用 OSSClient 构建；实现 `signGet`；**校验** key 属于 `keyPrefix`、可选 `scene/userId` 与当前用户及业务权限（明信片作者/审核态、信件参与者等） | [x] |
| O3 | **读路径集成（选一或组合）**：(a) 列表/详情 VO 出站前把存库的 URL/`objectKey` 转为短时 signed URL；(b) 独立批量换签供 Flutter/Web 懒加载 | [x] |
| O4 | **数据口径**：约定 DB 存 **objectKey**（或 `https://bucket...` 可解析出 key）；兼容层解析历史全 URL；**不配置** `public-read-base-url` 于生产私有桶；**历史批量迁移脚本不纳入首发**（Owner 2026-05-09） | [x] |
| O5 | **Flutter**：发帖仍 `put-sign` + PUT；展示侧对 403/过期重拉列表或调换签；`Image.network` 错误回调 | [x] `PostalOssNetworkImage` + `/api/oss/get-sign` 单次自愈；墙/详情/头像 |
| O6 | **Manage**：审核台图片走 `/webapi` 鉴权后换签（可与 App 共用 service，Controller 分轨） | [x] `AdminOssController` + `api.ts` |
| O7 | **验证**：`mvn … test` 覆盖签名校验与非法 key；Knife4j 手动换签 + 浏览器打开图片；`dart analyze` | [~] `OssReadableKeyValidatorTest` + `oss_object_key_hint_test`；Knife4j/浏览器仍建议人工过一遍 |

**非目标（本 FP）**：独立公开 OSS 目录、Bucket Policy 匿名读、CDN 对公匿名回源。
