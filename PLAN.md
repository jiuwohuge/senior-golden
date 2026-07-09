# PLAN · 慢邮件邮局系统 4.0（银发慢邮）

> **版本**：4.0 · **分支**：`feature_4.0` · **更新**：2026-07-09 · **维护**：项目 Owner + AI 架构师
> **需求真源**：[`doc/4.0需求改版.md`](doc/4.0需求改版.md)（PRD v4.0，§1~§20）
> **后端框架能力真源**：[`senior-post-api/底层框架能力.md`](senior-post-api/底层框架能力.md)
> **治理**：旧版 `doc/plan/**`、`doc/requirements/**`、根目录 `findings.md/progress.md/task_plan.md` 已废弃删除；本文件为唯一规划基线。

---

## 0. 4.0 内核判断（为什么重构）

| 维度 | 3.0 现状 | 4.0 目标（PRD） |
|------|----------|-----------------|
| 目标人群 | 泛社交 | **45+ 银发用户**，适老化为第一设计原则（§12.8） |
| 产品内核 | 明信片墙 Feed + 通讯录指定发信 | **匹配算法驱动**：POST_OFFICE 无收件人 → 匹配池分发（§7） |
| 信件模式 | 均指定收件人 | `POST_OFFICE`(匹配) / `DIRECT`(指定) / `SELF_TIME`(时光信)（§4.2） |
| 底部导航 | 明信片/信箱等 | **邮局 / 笔友 / 信箱 / 我的**（§12.1） |
| 关系 | friendship 二元 | **极简**：仅"笔友"+"申请中"持久化，其余为往来派生态（§10） |
| 内容安全 | 先审后发 | **敏感词前置 + 默认放行进入投递 + 审核/举报拦截**（§4.3 `audit_status`、§15.6） |
| 商业 | 邮票货币 + VIP | **表达增强付费**（皮肤/模板/字体/附件/时光信扩展/导出），不影响匹配公平（§16） |
| 灵魂系统 | 无 | **匹配算法 + 行为系统 + 推荐系统**（§7/§14/§9） |
| 配置 | 散落硬编码 | **统一管理后台配置驱动**（§20.2） |
| 后端分层 | Controller 直调 Mapper 等混杂写法 | **强制五层链路**，数据访问收口 IService（§1.1） |
| 代码治理 | 废弃功能留档/打补丁 | **废弃即删除**，保持工作区整洁（§1.2） |
| 库表迁移 | Flyway V1~V28 历史脚本 | **清空重来**，开发期从 `V1__init.sql` 重建（§1.3） |

**核心闭环（§17）**：写信 → 匹配/投递 → 收信(读信) → 回信 → 达阈值加笔友 → 行为反馈优化匹配。

---

## 1. [当前栈]（复用，不变更）

| 层级 | 选型 | 说明 |
|------|------|------|
| 后端语言 | Java 17 | `commons-framework` 父 POM 统一管理 |
| 后端框架 | Spring Boot 3.x + MyBatis-Plus 3.5.16 | 多模块 `client`/`biz`/`server` |
| 库表迁移 | Flyway | `senior-post-api/server/src/main/resources/db/migration`（**开发期重置，见 §1.3**） |
| 数据库 | PostgreSQL | 主事务库 |
| 缓存 | Redis | 缓存；**延迟投递用 PG + `@Scheduled`**，ZSet 仅列为后续优化（§6.3） |
| 对象存储 | 阿里云 OSS | `put-sign`/`get-sign` 预签名直传（图片附件） |
| IM | 腾讯云 Chat | 现有能力，4.0 非核心（慢邮件为主，非即时聊天 §17 原则1） |
| AI 能力 | DeepSeek(文本) + 百度(图片) | 图片机审复用；**匹配情绪/风格特征在 v2 阶段接入**（§7.3） |
| 移动端 | Flutter 3.x + Riverpod + go_router + dio | Postal 复古设计系统 + **适老化约束 §12.8** |
| 管理后台 | React 18 + Vite + Ant Design 5 | `senior-post-manage`，`/webapi`；承载 §20.2 全部配置项 |
| 架构 | 单体优先 | `senior-post-api` 单进程 |

约定：App `/api/**`（可 AES）、Manage `/webapi/**`（明文）；鉴权异常统一 `85xx`；分页 `PageQuery`/`PageData`；上下文 `MyRequestContextHolder`；审计字段走 auditable 域方法。

### 1.1 后端分层规范（强制）

**所有后端实现必须遵循以下调用链，禁止跨层直调：**

```
Controller → Business Service → Base IService (IService / ServiceImpl) → Mapper → Table
```

| 层级 | 职责 | 禁止 |
|------|------|------|
| **Controller** | 入参校验、鉴权上下文读取、调用 Business Service、返回 DTO | ❌ 注入/调用 Mapper；❌ 编写 SQL/Wrapper 查询；❌ 承载业务编排 |
| **Business Service** | 业务编排、领域规则、事务边界、组合多个 Base Service | ❌ 直调 Mapper；❌ 在 Controller 内实现同等逻辑 |
| **Base IService / ServiceImpl** | **所有数据库访问的唯一收口**：基于 MyBatis-Plus `IService`/`ServiceImpl` 封装可复用查询/更新方法 | ❌ 业务规则堆叠（应上提 Business Service） |
| **Mapper** | 单表/简单 SQL 映射，仅被对应 ServiceImpl 调用 | ❌ 被 Controller 或 Business Service 直接注入 |
| **Table / Domain** | 实体与表结构映射 | — |

**落地要求：**
- 每个 `bu_*` 表对应：`XxxMapper` + `XxxService`(extends `IService<Xxx>`) + `XxxServiceImpl`(extends `ServiceImpl<XxxMapper, Xxx>`)
- 可复用查询（按 ID、按用户、分页、状态过滤等）**必须**写在 `ServiceImpl` 公共方法中，供 Business Service 复用
- M0 起：**存量代码凡 Controller 直调 Mapper 的，一律重构**；新代码 Code Review 以本规范为硬门槛
- 复杂跨表业务：Business Service 编排多个 Base IService，不在 Controller 拼装

### 1.2 废弃代码治理（强制）

**废弃功能不做留档、不打补丁、不 `@Deprecated` 挂尸。**

- 判定废弃 → **直接删除**对应 Controller / Service / Mapper / Domain / DTO / 前端 feature / 路由 / 测试 / 文档引用
- 禁止：`// TODO remove later`、注释大块旧代码、保留空壳 Controller、保留无用 Flyway 脚本
- 目标：本次构建的工作区**只保留 4.0 有效代码**，便于阅读、编译、评审

### 1.3 Flyway 重置策略（开发期）

项目仍处于开发期，**不保留历史迁移链**。

- **删除** `db/migration` 下全部 `V1~V28` 脚本
- **重建**单一初始化脚本 `V1__init.sql`（及后续按需 `V2+`），表结构直接对齐 4.0 PRD + PLAN 当前设计
- **本地/开发库**：`flyway clean`（仅 dev）或 drop schema 后由 Flyway 重新 migrate
- **约束**：生产环境未上线，无历史数据迁移负担；后续若上线再冻结迁移链

---

## 2. 系统 × 现有资产映射（复用 / 改造 / 新建 / 废弃）

> 图例：✅ 直接复用　🔧 改造升级　🆕 新建　❌ 废弃并删除

| PRD 系统 | 状态 | 现有资产 → 4.0 落点 |
|----------|------|---------------------|
| §2 账户 | ✅+🆕 | ✅ `AppAuthController`/`UserIdentityDomain`/`LoginDomain`/`UserDeviceDomain`/`PasswordResetTokenDomain`；🆕 **邮箱验证绑定**(仅邮箱账号 §2.9)、**异常登录风控**(§2.5)；注册去验证码(§2.1)；**分层重构** |
| §3 用户 | ✅+🆕 | ✅ `UserDomain`/`TagDomain`/`UserTagDomain`/`CountryDomain`；🆕 **自动定位**(§3.3)、**Haversine**(§3.4)、**写作风格标签**(§3.7)；gender 二值(§3.1) |
| §4 信件 | 🔧 | 🔧 `LetterDomain` 扩展 `mode`/`audit_status`/`parent_letter_id`/`content`(§4)；时光信对齐 `SELF_TIME` |
| §5 时间与仪式 | 🔧+🆕 | 🔧 时间字段/事件流；🆕 邮戳/投递动画/开信仪式(§5.4) |
| §6 投递 | 🔧 | 🔧 定时投递服务；延迟公式扩展，速度=距离+关系(§6.1) |
| §7 匹配 | 🆕 | **全新算法引擎**(§7) |
| §8 笔友页 | 🔧 | 🔧 `AppDirectoryController` + `directory/*` → 笔友页三 Tab(§8.2/§12.3) |
| §9 推荐 | 🆕 | 🆕 每日推荐(§9) |
| §10 关系 | 🔧 | 🔧 `FriendshipDomain` → 极简笔友模型(§10) |
| §11 邮局首页 | 🆕 | 🆕 首页 + 写信分流 + 推送(§11) |
| §12 UI | 🔧+🆕 | 🔧 四 Tab；🆕 读信页/适老化(§12) |
| §13 个人中心 | 🔧 | 🔧 `profile/*` 分组重构(§13) |
| §14 行为 | 🆕 | 🆕 行为事件采集(§14) |
| §15 风控 | ✅+🔧 | ✅ 黑名单/举报/敏感词；🔧 审核策略改版(§15.6) |
| §16 商业 | ❌+🆕 | ❌ 邮票货币**整模块删除**；🆕 表达增强付费(§16) |
| §20 配置 | 🔧 | 🔧 管理后台配置项(§20.2) |

### 明确废弃清单（直接删除，不留档）

| 废弃项 | 删除范围 |
|--------|----------|
| 明信片墙 Feed | 后端：`AppPostcardController`、`PostcardDomain`/`PostcardComment*` 及 Mapper/Service；前端：`features/post_wall/**`、`my_postcards_page`；Flyway：明信片相关表（在 `V1__init` 中不再创建） |
| 邮票货币 | 后端：`AppStampsController`、`StampTransactionDomain`/`StampDailyGrantDomain` 及 Mapper/Service；前端：`speed_up_sheet`、`stamps_ledger_page`、邮票相关路由；Flyway：邮票相关表不再创建 |
| 脚手架示例 | `ExampleDomain`/`FoodDomain` 及全部 Mapper/Service/Controller/测试 |

---

## 3. [功能清单]（依赖排序里程碑）

> 原则：**M0 先清场**（Flyway 重置 + 废弃代码删除 + 分层基线）→ 账户/用户 → 信件/投递/首页/读信 → 匹配/行为 → 关系/笔友页/推荐 → 仪式/商业/配置。

### M0 — 清场 + 基座 + 适老化基线（约 1~2 周）

**Flyway 重置**
- [ ] 删除 `db/migration/V1~V28` 全部脚本
- [ ] 编写 `V1__init.sql`：仅包含 4.0 保留表结构（用户/身份/信件/关系/黑名单/举报/配置/行为等），不含明信片/邮票/示例表
- [ ] 开发库执行 clean + migrate，验证启动与基线表一致

**废弃代码直接删除**
- [ ] 后端：删除 `AppPostcardController`、`AppStampsController`、`Postcard*`、`Stamp*`、`Example`/`Food` 全链路（Controller/Service/Mapper/Domain/DTO）
- [ ] 前端：删除 `features/post_wall/**`、`my_postcards_page`、`speed_up_sheet`、`stamps_ledger_page` 及路由引用
- [ ] 管理后台：删除明信片/邮票相关页面与 API 调用（若有）
- [ ] 全仓 `grep` 确认无残留 import/路由/菜单

**后端分层基线**
- [ ] 确立包结构约定：`controller` / `service.biz` / `service.base` / `mapper` / `model.domain`
- [ ] 存量 Controller **禁止直调 Mapper**：逐模块重构为 Controller → BizService → XxxServiceImpl → Mapper
- [ ] 为保留域补齐/规范 `IService` + `ServiceImpl` 公共查询方法（用户、信件、关系、登录记录等）
- [ ] CI/自检：`biz` 模块编译通过；抽查无 Controller 注入 Mapper

**前端基线**
- [ ] `main_shell` 底部四 Tab：**邮局 / 笔友 / 信箱 / 我的**（骨架页占位）
- [ ] 适老化基线：字号下限 / 触控≥48dp / 图文双标签 / 大按钮 → 主题与通用组件

**验证**
- [ ] `mvn -pl biz,client -am compile` 通过
- [ ] `flutter analyze` 通过
- [ ] 应用可启动；认证 + 基础用户接口可用

### M1 — 账户 + 用户内核（约 2~3 周）
- [ ] 账户：注册去验证码(§2.1)；邮箱验证绑定(§2.9)；登录记录 + 异常登录(§2.5/2.6)
- [ ] 用户：自动定位(§3.3)、Haversine(§3.4)、写作风格标签规则版(§3.7)、gender 二值(§3.1)
- [ ] 语言：跟随设备 + 中/英本地化(§3.5)
- [ ] Flyway `V2+`（若 init 后需增量）：`email_verified`、定位字段等
- [ ] 新接口均走分层规范(§1.1)

### M2 — 信件 + 投递 + 邮局首页 + 读信页（约 3~4 周）
- [ ] 信件：`mode`/`audit_status`/`parent_letter_id`/分模式状态机(§4.3)
- [ ] 写信分流(POST_OFFICE/时光信 §11.5)、回信(§4.7)、读信页(§12.6)
- [ ] 投递：延迟公式扩展(§6.1)；邮局首页(§11)
- [ ] 时光信对齐 `SELF_TIME`

### M3 — 匹配 + 行为 + 审核 + POST_OFFICE 闭环（约 3~4 周）
- [ ] 行为事件采集(§14)；匹配 v1 规则版(§7)
- [ ] POST_OFFICE 端到端；内容审核(§15.6)；风控额度/保护池(§15)

### M4 — 关系 + 笔友页 + 推荐 + 个人中心 + 信箱（约 3~4 周）
- [ ] 关系极简模型(§10)；笔友页三 Tab(§8/§12.3)；推荐(§9)
- [ ] 个人中心(§13)；信箱流水(§12.4)

### M5 — 仪式 + 商业 + 配置 + 推送 + 匹配 v2（4 周+）
- [ ] 仪式/商业/管理后台配置(§5.4/§16/§20.2)；推送(§11.6)；匹配 v2 AI(§7.3)

---

## 4. [改动预测]（M0 首批；每次 ≤3 文件、断点式交付）

**Flyway**
- 删除：`db/migration/V1__init.sql` … `V28__*.sql`（全部）
- 新增：`V1__init.sql`（4.0 基线表结构）

**后端删除（示例批次，按模块分批提交）**
- `AppPostcardController` + `Postcard*` 全链路
- `AppStampsController` + `Stamp*` 全链路
- `ExampleDomain`/`FoodDomain` 全链路

**后端分层重构（示例批次）**
- 保留 Controller 逐个改为只调 BizService
- 补齐 `XxxService`/`XxxServiceImpl` 公共 DB 方法

**前端**
- `main_shell.dart`、`app_router.dart`
- 删除 `features/post_wall/**` 等废弃目录

> M0 完成后工作区应：**无废弃模块文件、无 V2~V28 脚本、Controller 无 Mapper 注入**。

---

## 5. [验证策略]

- **后端编译**：`mvn -pl biz,client -am compile`
- **分层合规**：静态检查 Controller 不注入 Mapper；BizService 不跳过 Base IService 直写 SQL
- **Flyway**：dev 库 clean + migrate 后表结构与 `V1__init` 一致；应用启动无迁移错误
- **废弃清理**：全仓搜索废弃类名/路由为零命中
- **Flutter**：`dart format` + `flutter analyze`
- **业务冒烟**：注册/登录/用户资料/写信收发基础链路（随里程碑递进）
- **数据一致性**：信件双状态、关系申请、额度扣退（M2+）

---

## 6. [关键决策记录]

| 日期 | 决策 |
|------|------|
| 2026-07-08 | Feed 废弃；邮票货币废弃改表达增强付费；匹配分阶段(规则→AI)；旧文档全删 |
| 2026-07-08 | 关系极简；成笔友唯一路径；系统推荐只在笔友页；适老化全局约束 |
| 2026-07-08 | 写信+回信计额度(配置驱动)；审核=敏感词前置+默认放行+拦截 |
| 2026-07-09 | 注册无验证码；设置内邮箱验证绑定；自动定位优先；gender 男/女 |
| 2026-07-09 | 投递速度=距离+关系；读信页；写信分流；举报/拉黑入口 |
| **2026-07-09** | **后端强制五层**：Controller → Business Service → IService/ServiceImpl → Mapper → Table；Controller 禁止直调 Mapper |
| **2026-07-09** | **废弃代码直接删除**，不留档不打补丁，保持工作区整洁 |
| **2026-07-09** | **Flyway 清空重来**：删除 V1~V28，从 `V1__init.sql` 重建（开发期） |
| 继承自 3.0 | JWT 单端在线；OSS 直传；`@Scheduled` 延迟投递；Riverpod；Manage 用 React |

---

## 7. [状态]

- [x] S0. 创建 `feature_4.0` 分支
- [x] S1. 3.0 现状盘点
- [x] S2. 4.0 复用/改造/新建/废弃评估
- [x] S3. 旧文档全量清理
- [x] S4. PRD v4.0 定稿
- [x] S5. 按 PRD 重排里程碑 M0~M5
- [x] S6. 补充工程治理：后端分层 / 废弃即删 / Flyway 重置
- [ ] S7. M0 清场执行（Flyway 重置 + 废弃删除 + 分层基线 + 四 Tab 骨架）（待启动）
