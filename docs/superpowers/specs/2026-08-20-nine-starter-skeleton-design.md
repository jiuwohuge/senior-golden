# nine-starter 全栈骨架设计

日期：2026-08-20  
状态：已与用户对齐，待确认后实施  
源项目：`C:\01_workplace\01_code_place\01_owner\senior-golden`  
目标路径：`C:\01_workplace\01_code_place\01_owner\nine-starter`

## 1. 目标

做一个可运行的全栈空壳仓库：架构、配置、打包方式对齐 Senior Post，但不包含产品业务（含账号体系）。后续新项目改名字、库名、数据目录即可开始写业务。

成功标准：

1. 在 `nine-starter` 根目录执行 `.\scripts\dev-up.ps1` 后，API 与 Manage 可访问。
2. App `/api/demo/items` 与 Admin `/webapi/demo/items` 的分页 CRUD 可用（App 走 AES，Admin 明文）。
3. Flutter 启动后直接进入 Demo 列表，可增删改。
4. `.\scripts\new-app.ps1 -Name "<kebab-name>"` 能在 `01_owner` 下生成独立仓库，替换项目名/包名/库名/数据目录。
5. 骨架与生成项目中均无信件、邮局、登录、用户等 Senior Post 业务代码或标识残留（允许文档中作为「源项目」提及一次）。

## 2. 非目标

- 不实现登录、注册、Token、用户表、Google OAuth。
- 不包含 OSS、邮件、机审、Spring AI、百度 SDK、JWT、Firebase、定位。
- 不把 Senior Post 整仓复制后再删；只抽基础设施，Demo 与空壳页面重写。
- 不改 Senior Post 仓库的业务代码（本 spec 仅作为设计文档落在源仓库）。
- 不在骨架默认端口上与 Senior Post 错开；两套不能同时起（用户已确认）。
- 骨架不发布到 Maven Central；继续依赖本机已安装的 `cn.nine.commons:commons-framework:1.1-SNAPSHOT`。

## 3. 仓库结构

```
nine-starter/
  README.md
  docs/NEW_PROJECT.md
  .env.example
  .gitignore
  docker-compose.yml
  scripts/dev-up.ps1
  scripts/dev-up.sh
  scripts/new-app.ps1
  .cursor/rules/          # 通用化后的分层 / Compose / 注释 / 前端设计 / 全栈路由
  .cursor/skills/
    backend-foundation-capabilities/
    frontend-engineering-conventions/
  nine-starter-api/       # Maven 父 POM + biz / client / server
  nine-starter-manage/    # Vite + React + Ant Design
  nine-starter-flutter/   # Flutter 空壳 + Demo 列表
```

不拷贝：`.cursor/skills/tencent-rtc-skills`、`.cursor/plans`、产品文档、里程碑计划。

## 4. 命名与默认配置

| 项 | 骨架默认值 |
|---|---|
| 目录 / Compose 服务前缀 | `nine-starter` |
| Java 包 | `cn.nine.starter` |
| Maven groupId | `cn.nine.starter` |
| 父 artifact | `nine-starter-pom` |
| 子 artifact | `nine-starter-biz` / `nine-starter-client` / `nine-starter-server` |
| 启动类 | `cn.nine.starter.server.NineStarterApplication` |
| `@SpringBootApplication(scanBasePackages)` | `cn.nine.starter` |
| `@MapperScan` | `cn.nine.starter.biz.mapper` |
| YAML 业务前缀 | `nine-starter`（仅占位，骨架可不挂业务 properties） |
| Postgres 库名 | `nine_starter` |
| API 端口 / context-path | `9011` / `/backend` |
| Manage 宿主机端口 | `8080`（容器 Vite `5174`） |
| Postgres / Redis 宿主机端口 | `65432` / `6379` |
| Postgres 数据目录 | `D:/06_docker_workplace/nine-starter/postgresql` |
| Redis 数据目录 | `D:/06_docker_workplace/nine-starter/redis-data` |
| AES key（本地默认，与现网一致便于对照） | `8e32de3646dc4c02ae2507511202c7ca` |

`commons-framework` 父 POM 保持 `cn.nine.commons:commons-framework:1.1-SNAPSHOT`，不改 group。

## 5. 后端

### 5.1 模块与依赖

对齐现有三模块。**biz 只保留框架所需依赖**，不带产品 SDK：

- 保留：`commons-web`、`commons-redis-starter`、`feign-bridge-mybatis`、`commons-data`（经 client）、MyBatis-Plus、MapStruct、Lombok、spring-boot-starter-test、H2（test）。
- 去掉：阿里云 OSS、百度 AIP、Google API client、JJWT、`spring-boot-starter-mail`、`spring-ai-starter-model-deepseek`、`spring-security-crypto`（无登录则不需要 PasswordEncoder）。

server 保留：web、commons-security（`@EnableEncrypt`）、biz、actuator、postgresql、jdbc、flyway、spring-boot-maven-plugin + antrun 复制 JAR 到 `nine-starter-api/dist/`。

client 保留：commons-data、validation、springdoc、`AppServiceDefine`（`/api` 与 `/webapi`）。

### 5.2 配置

从 `application.yml` / `application-local.yml` 抽出框架段，删除 `senior-post.auth` / `oauth` / `mail` / `oss` / `moderation` / `mailbox` / `time-letter` 以及 `spring.ai`。

强制约定：

- `jh.config.auth: false`，`jh.config.token-auth: false`。新项目自己加鉴权后再打开，并配置 `exclude-interceptor-pattern`。
- `jh.config.interceptor-pattern` 仍为 `["/api/**", "/webapi/**"]`。
- AES：`/api/**` 加解密；`/webapi/**` 明文忽略。与现网一致。
- Flyway：`enabled: true`，`locations: classpath:db/migration`，`baseline-on-migrate: true`。
- MyBatis-Plus 逻辑删除：`delFlag` / true / false。
- Knife4j + springdoc 两组：`ADMIN-API` 扫 `cn.nine.starter.biz.controller.admin`，`APP-API` 扫 `...controller.app`。
- 无鉴权时 `exclude-interceptor-pattern` 只保留将来扩展位；不必列登录白名单。

`application-local.yml` 数据源默认连 `127.0.0.1:65432/nine_starter`（Compose 内用环境变量覆盖为 `postgresql:5432`）。

不提供 `PasswordEncoder` Bean。不启用 `@EnableScheduling`（无定时任务）；可保留 `@EnableAsync`。

### 5.3 Demo 表与 API

唯一迁移：`V1__init.sql` 建 `demo_item`。

```sql
CREATE TABLE demo_item (
    id          BIGSERIAL PRIMARY KEY,
    title       VARCHAR(100) NOT NULL,
    content     TEXT,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by  BIGINT,
    updated_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by  BIGINT,
    del_flag    BOOLEAN NOT NULL DEFAULT FALSE
);
```

`DemoItemDomain` 继承 `AbstractAuditableDomain`。无登录时 `MyRequestContextHolder.userId()` 为 `null`：Biz 仅在 `userId != null` 时调用 `initAudit` / `updateAudit` / `markDeleted`；否则只靠数据库 `DEFAULT NOW()` 填时间，`created_by` / `updated_by` 保持 `null`。

五层（App / Admin 共用 Domain、Mapper、base Service 和同一个 `DemoItemBizService`）：

```
Controller → DemoItemBizService → DemoItemService / Impl → DemoItemMapper → demo_item
```

Client 接口风格对齐现网（Controller 实现 API 接口）：

| 方法 | App | Admin |
|---|---|---|
| 分页 | `POST /api/demo/items/paging` | `POST /webapi/demo/items/paging` |
| 详情 | `GET /api/demo/items/{id}` | `GET /webapi/demo/items/{id}` |
| 保存（有 id 更新，无 id 新增） | `POST /api/demo/items/save` | `POST /webapi/demo/items/save` |
| 软删 | `POST /api/demo/items/{id}/delete` | `POST /webapi/demo/items/{id}/delete` |

入参：

- `DemoItemQueryInDto`：内嵌 `PageQuery page`，可选 `title` 模糊过滤。
- `DemoItemSaveInDto`：`id`（可选）、`title`（必填，最长 100）、`content`（可选）。

出参：`DemoItemDTO`（id、title、content、审计字段）。分页返回 `PageData<DemoItemDTO>`。Controller 不包 `ApiResponse`。

Biz 公开方法写 Javadoc；保存/删除打 INFO 日志（带 id，不打完整 content 若过长可截断）。查询下沉到 `DemoItemService` 命名方法（如 `pageActive(PageQuery, title)`），Biz 禁止 Wrapper。

提供 1 个后端测试：`DemoItemServiceImpl`（或 Biz）在 H2 上保存一条再分页查出，`mvn test` 必须通过。不强制整容器 `@SpringBootTest`。

## 6. 管理端（nine-starter-manage）

栈不变：React 18 + Vite + Ant Design 5 + axios。

保留可复用件：`request.ts`（统一 `success/code/message/data`）、`AdminProTable.tsx`、空壳 `AdminLayout`（侧栏 + 顶栏）。

去掉：Login 页、所有业务页面、OSS 上传、token 跳转登录逻辑。`jh.config.auth` 为 false，Manage 不读 `admin_token`，不因 85xx 跳登录。

默认页：Demo 列表（表格 + 新增/编辑弹窗 + 删除）。菜单仅「Demo 条目」。

`VITE_API_BASE_URL` 默认 `http://localhost:9011/backend`（不依赖本机共享 nginx）。`VITE_BASE_PATH` 仍为 `/manage/`。Compose 映射 `8080:5174`，volume 挂源码，`dev-up.ps1` 行为与现网一致。

## 7. Flutter（nine-starter-flutter）

栈：Flutter + Riverpod + go_router + dio + encrypt。去掉 google_sign_in、firebase、geolocator、image_picker、crop。

保留精简 `core`：

- `api_response` / `api_exception`
- `jh_api_crypto`（与 `jh.security.key` 一致；`API_AES_ENABLED` 默认真）
- `dio_provider`：AES 包装 `/api/**`；带 `versionCode`、`deviceId`；**不带 Token / 登录刷新**
- `api_base_url`：Web 默认 `http://localhost:9011/backend`；Android 模拟器 `http://10.0.2.2:9011/backend`；可用 `--dart-define=API_BASE_URL=` 覆盖

启动无登录，首页即 Demo 列表（拉取 paging、保存、删除）。视觉走中性后台/工具风，不用邮政主题，不套 Senior Post 适老化条款。仍遵守 `frontend-design` skill（避免套模板紫渐变）。

`pubspec` 名：`nine_starter_flutter`。Android `applicationId` 与 iOS `CFBundleIdentifier` 均为 `cn.nine.starter`，由 `new-app.ps1` 一并替换。

## 8. Docker 与本地启动

`docker-compose.yml` 服务：`postgresql`、`redis`、`nine-starter-api`、`nine-starter-manage`。nginx **仍保留服务定义**，但默认配置与数据目录改为项目可覆盖的 `.env` 变量，避免写死共享的 `D:/06_docker_workplace/nginx` 把 Senior Post 反代冲掉。若本机没有独立 nginx 目录，文档写明可先不 `up nginx`，Manage/Flutter 直连 `9011`。

API 镜像：`eclipse-temurin:17-jre-alpine`，`JAR_FILE=dist/nine-starter-server-*.jar`。

`scripts/dev-up.ps1`：`mvn clean package -Dmaven.test.skip=true` → 复制 `nine-starter-server-*.jar` 到 `nine-starter-api/dist/` → `docker compose build` API → `--force-recreate` API（及可选 Manage）。中间件 `--no-recreate`。不使用宿主机 `spring-boot:run` 作为默认路径。

`.env.example` 列出：端口、`POSTGRES_*`、`SPRING_DATASOURCE_*`、Redis、`JAVA_OPTS`、`VITE_*`。不含 OSS/Google/DeepSeek/百度。

## 9. Cursor 规则

从源项目拷贝并改名：

- `backend-foundation-capabilities`：路径从 `senior-post-api` 改为 `nine-starter-api`，包名改为 `cn.nine.starter`。
- `frontend-engineering-conventions`：去掉 postal / 适老化产品条款，范围改为 `nine-starter-flutter` / `nine-starter-manage`。
- rules：`backend-layered-architecture`、`comments-and-logging-required`、`docker-compose-dev-services`、`frontend-design-required`、全栈路由（文件名改为 `fullstack-task-routing.mdc`）。

`frontend-design-required` 不再写「45+ 银发 / 邮政」；改为：Flutter 与 Manage 做 UI 前必须读 frontend-design skill。

## 10. 开项目脚本

`scripts/new-app.ps1`：

```powershell
.\scripts\new-app.ps1 -Name "order-hub" [-Dest <parent>] [-Package cn.nine.orderhub] [-DbName order_hub] [-SkipDemo]
```

行为：

1. 校验 `-Name` 为 kebab-case（`^[a-z][a-z0-9-]*$`）。目标目录不存在才创建。
2. 复制骨架到 `$Dest\$Name`，排除 `.git`、`node_modules`、`target`、`dist`、`build`、`.dart_tool`、`.idea`、`.env`。
3. 按映射替换文件内容与路径/文件名：

| 骨架 | 新项目（例 `order-hub`） |
|---|---|
| `nine-starter` | `order-hub` |
| `nine_starter` | `order_hub` |
| `nineStarter` | `orderHub` |
| `NineStarter` | `OrderHub` |
| `cn.nine.starter` | `cn.nine.orderhub`（或 `-Package`） |
| `NINE_STARTER` | `ORDER_HUB` |

4. Java 包目录从 `cn/nine/starter` 重命名为包路径。
5. `.env.example` 中库名、`POSTGRES_DATA_DIR` / `REDIS_DATA_DIR` 改为 `D:/06_docker_workplace/<Name>/...`。
6. 端口不改。
7. `-SkipDemo`：删除 Demo 的 Java/TS/Dart 文件，并将 `V1__init.sql` 改为仅含注释、不含 `CREATE TABLE`（Flyway 仍执行该版本）。第一张业务表从 `V2__*.sql` 写起。
8. 目标目录 `git init`（不创建 Cursor remote）。
9. 打印后续步骤：复制 `.env`、`dev-up.ps1`、`flutter run`。

`docs/NEW_PROJECT.md` 用同一套替换表写手动步骤，使不用脚本也能开项目。

替换必须覆盖：源码、pom、yml、gradle/AndroidManifest/Info.plist、pubspec、package.json、compose、rules/skills、README。复制后扫描残留 `nine-starter` / `cn.nine.starter` / `senior-post` / `senior_golden`（skills 里若需举例源项目，只用「本骨架」表述）。

## 11. 实施顺序

1. 用 Cursor `create_project` 在 `01_owner/nine-starter` 建仓并切工作区（或本会话在该路径写文件）。
2. 落地 API 父 POM + 三模块 + 框架 yml + Flyway V1 + Demo 五层 + 启动类 + Dockerfile。
3. `docker-compose.yml`、`.env.example`、`dev-up.ps1`。
4. Manage 空壳 + Demo 页。
5. Flutter 空壳 + Demo 页 + AES Dio。
6. Cursor rules/skills 通用化拷贝。
7. `new-app.ps1` + `docs/NEW_PROJECT.md` + 根 README。
8. 验证：`mvn test`（或约定的 Demo 测试）、`mvn package`；能的话 `dev-up` 起容器后打 paging 接口。

## 12. 风险与约束

- 本机必须已能解析 `cn.nine.commons:commons-framework:1.1-SNAPSHOT`（与 Senior Post 相同）。
- 与 Senior Post **不能同时**占用 `9011/8080/65432/6379`。数据目录已隔离，先后切换不会混库。
- 共享 nginx（若仍指向 `D:/06_docker_workplace/nginx`）可能影响 Senior Post 反代；骨架默认让 Flutter/Manage 直连 `9011`，nginx 为可选。

## 13. 交付清单（实施完成时）

- 新仓库 `nine-starter` 可启动。
- Demo 三端 CRUD。
- `scripts/new-app.ps1` + `docs/NEW_PROJECT.md`。
- 无 Senior Post 业务代码。
- 本 spec 不要求把骨架提交到 Senior Post 的 git；骨架自己 `git init`。
