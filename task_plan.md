# 任务总表（索引）

**角色**：与根目录 [`PLAN.md`](PLAN.md) 对齐；本文件只做**进度总览 + 文档导航**，细则见 [`doc/plan/`](doc/plan/)。

| 文档 | 说明 |
|------|------|
| [feature-overview.md](doc/feature-overview.md) | **精简功能总览**：模块→功能表（描述、状态、预期、验收） |
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
| P0 | 阅读 `PLAN.md`「功能清单 / 开发计划 / 阻塞」并与 `01` 表对齐 | [ ] |
| P1 | M2 主路径：发帖/评论/目录/写信/OSS/Flutter Mock→REST | [ ] |
| P2 | M3：平邮延迟队列、邮票事务、信箱全 REST、Manage 邮票页 | [~] 平邮到期 Worker 已落地（`05` FP-A5d-002 DONE）；Redis ZSET 可选 |
| P3 | M1/M4：资料 API、邮件、AES、GDPR、举报 App 端、版本强更 | [ ] |
| P4 | 体验债：B14 主题、B15 登录注册视觉 | [ ] |
| P5 | 质量闸门：`flutter analyze`、后端冒烟、IM 双端 | [ ] |

---

## 决策与错误记录

| 日期 | 类型 | 内容 |
|------|------|------|
| 2026-05-02 | 决策 | 外部不可信内容只写入 `findings.md`，不写回本索引 |
| 2026-05-02 | 错误 | `session-catchup.py` 本机缺失 → 跳过，以仓库事实为准 |
| 2026-05-07 | 错误 | `session-catchup.py` 再次不可用（exit 9009）→ 跳过 |
| 2026-05-02 | 决策 | 文档体系 hybrid：`task_plan.md` + `doc/plan/01–07` |
| 2026-05-07 | 决策 | 遗漏项与执行顺序以 [`07-gap-analysis-and-roadmap.md`](doc/plan/07-gap-analysis-and-roadmap.md) 为单一叙事入口；`01`/`05` 仍为 FP 勾选源 |

---

## 下一步（执行开发时）

1. 打开 [07-gap-analysis-and-roadmap.md](doc/plan/07-gap-analysis-and-roadmap.md) 对照推荐波次；再打开 [05-task-tracker.md](doc/plan/05-task-tracker.md) 勾选具体 FP。
2. 每完成一个 FP：更新 `01`/`05`、在 [progress.md](progress.md) 写一行、必要时回写 `PLAN.md` 勾选。

---

## OSS 私有读改造（2026-05-08 规划）

**决策**：不引入匿名公共桶/公共前缀；**仅**通过服务端 **GET 预签名 URL** 让 App / Web 展示私有桶对象。跟踪 FP：**[FP-X-005](doc/plan/05-task-tracker.md)**；事实与约束见 [findings.md §6](findings.md)。

| 子阶段 | 内容 | 状态 |
|--------|------|------|
| O1 | **契约**：`client` 增加 `GET` 或 `POST` 读签名 API（如批量 `objectKeys` → `signedUrl` + `expireAt`）；`OssProperties` 增加 `getExpireSeconds`（与 PUT TTL 分离） | [ ] |
| O2 | **服务**：`AppOssService` 抽取可复用 OSSClient 构建；实现 `signGet`；**校验** key 属于 `keyPrefix`、可选 `scene/userId` 与当前用户及业务权限（明信片作者/审核态、信件参与者等） | [ ] |
| O3 | **读路径集成（选一或组合）**：(a) 列表/详情 VO 出站前把存库的 URL/`objectKey` 转为短时 signed URL；(b) 独立批量换签供 Flutter/Web 懒加载 | [ ] |
| O4 | **数据口径**：约定 DB 存 **objectKey**（或 `https://bucket...` 可解析出 key）；迁移脚本或兼容层：历史全 URL 尝试解析为 key；**不配置** `public-read-base-url` 于生产私有桶 | [ ] |
| O5 | **Flutter**：发帖仍 `put-sign` + PUT；展示侧对 403/过期重拉列表或调换签；`Image.network` 错误回调 | [ ] |
| O6 | **Manage**：审核台图片走 `/webapi` 鉴权后换签（可与 App 共用 service，Controller 分轨） | [ ] |
| O7 | **验证**：`mvn … test` 覆盖签名校验与非法 key；Knife4j 手动换签 + 浏览器打开图片；`dart analyze` | [ ] |

**非目标（本 FP）**：独立公开 OSS 目录、Bucket Policy 匿名读、CDN 对公匿名回源。
