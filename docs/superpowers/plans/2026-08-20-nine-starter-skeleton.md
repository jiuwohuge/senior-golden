# nine-starter Skeleton Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (this session: inline). Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a runnable full-stack skeleton at `C:\01_workplace\01_code_place\01_owner\nine-starter` (API + Manage + Flutter + `new-app.ps1`) with only framework + `demo_item` CRUD.

**Architecture:** Copy Senior Post packaging (Maven biz/client/server, Compose, AES, Flyway, Cursor rules). Do not copy product code. Rewrite Demo five-layer CRUD, empty Manage/Flutter shells, and a rename script.

**Tech Stack:** Java 17, Spring Boot via `commons-framework` 1.1-SNAPSHOT, MyBatis-Plus, Flyway, Postgres, Redis, React 18 + Vite + Ant Design 5, Flutter + Riverpod + dio + encrypt, Docker Compose.

## Global Constraints

- Path: `C:\01_workplace\01_code_place\01_owner\nine-starter`
- Java package / groupId: `cn.nine.starter`
- Artifacts: `nine-starter-pom` / `nine-starter-biz` / `nine-starter-client` / `nine-starter-server`
- DB: `nine_starter`; data dirs `D:/06_docker_workplace/nine-starter/postgresql` and `redis-data`
- Ports: API `9011` `/backend`, Manage `8080`, Postgres `65432`, Redis `6379` (same as Senior Post; do not run both)
- `jh.config.auth: false`; AES on `/api/**`; `/webapi/**` plaintext
- No user/login/OSS/mail/AI/JWT/Firebase
- Demo APIs: `POST .../demo/items/paging|save`, `GET .../{id}`, `POST .../{id}/delete` under `/api` and `/webapi`
- Parent POM remains `cn.nine.commons:commons-framework:1.1-SNAPSHOT`
- Do not commit unless the user asks; `git init` the new repo only
- UI aesthetic: drafting-table workshop — ink `#1C2430`, blueprint `#2F5C86`, paper `#EEF1F4`, brass `#A68549`; signature is a brass title-block rule under the product name. No cream+serif, no purple gradients.

---

### Task 1: Create repo and copy Cursor conventions

**Files:**
- Create: repo root via `create_project`
- Copy then rename: `.cursor/skills/backend-foundation-capabilities/SKILL.md`, `.cursor/skills/frontend-engineering-conventions/SKILL.md`, `.cursor/rules/*.mdc` (not tencent-rtc, not plans)

- [ ] `create_project` path `C:\01_workplace\01_code_place\01_owner\nine-starter`
- [ ] `move_agent_to_root` to that path
- [ ] Copy skills/rules from senior-golden; replace `senior-post-api` → `nine-starter-api`, `senior-post-flutter` → `nine-starter-flutter`, `senior-post-manage` → `nine-starter-manage`, `cn.nine.pros.post` → `cn.nine.starter`, drop 银发/邮政 clauses; rename fullstack rule to `fullstack-task-routing.mdc`

---

### Task 2: Maven API skeleton + Demo five-layer + H2 test

**Files (create under `nine-starter-api/`):**
- `pom.xml`, `biz/pom.xml`, `client/pom.xml`, `server/pom.xml`
- `client/.../AppServiceDefine.java`
- `client/.../model/db/DemoItemDTO.java`
- `client/.../model/input/DemoItemQueryInDto.java`, `DemoItemSaveInDto.java`
- `client/.../api/app/AppDemoItemApi.java`, `api/admin/AdminDemoItemApi.java`
- `biz/.../model/domain/DemoItemDomain.java`, `mapstruct/DemoItemMapstruct.java`, `mapper/DemoItemMapper.java`
- `biz/.../support/PageQueryNormalize.java`
- `biz/.../service/base/DemoItemService.java` + `impl/DemoItemServiceImpl.java`
- `biz/.../service/biz/DemoItemBizService.java`
- `biz/.../controller/app/AppPageHelper.java`, `AppDemoItemController.java`
- `biz/.../controller/admin/AdminPageHelper.java`, `AdminDemoItemController.java`
- `biz/.../config/MybatisPlusConfig.java`
- `server/.../NineStarterApplication.java`
- `server/src/main/resources/application.yml`, `application-local.yml`, `logback-spring.xml`, `db/migration/V1__init.sql`
- `biz/src/test/.../DemoItemServiceImplTest.java` + `BizTestApplication.java` + `application-test.yml` + `schema.sql`
- `Dockerfile`, `.gitignore`

**Interfaces:**
- `DemoItemService.pageActive(PageQuery pageQuery, String title)` → `Page<DemoItemDomain>`
- `DemoItemService.getByIdOrThrow(Long id)` → `DemoItemDomain`
- `DemoItemService.create(String title, String content, Long userId)` → `DemoItemDomain`
- `DemoItemService.updateTitleContent(Long id, String title, String content, Long userId)` → `DemoItemDomain`
- `DemoItemService.softDelete(Long id, Long userId)` → void
- `DemoItemBizService.paging/get/save/delete` as specified in spec §5.3

- [ ] Write H2 test that saves then pages
- [ ] Run `mvn -pl biz -am test` from `nine-starter-api` — expect PASS
- [ ] Implement remaining Java/yml/Dockerfile
- [ ] `mvn clean package -Dmaven.test.skip=true` — expect `server/target/nine-starter-server-1.0-SNAPSHOT.jar`

---

### Task 3: Compose, env, dev-up

**Files:** root `docker-compose.yml`, `.env.example`, `.gitignore`, `scripts/dev-up.ps1`, `scripts/dev-up.sh`

- [ ] Services: postgresql, redis, nine-starter-api, nine-starter-manage; nginx optional with overridable config dir
- [ ] `dev-up.ps1` packages JAR into `nine-starter-api/dist/` then rebuilds API (and Manage unless `-ApiOnly`)

---

### Task 4: Manage shell + Demo page

**Files:** `nine-starter-manage/` package.json, vite, tsconfig, Dockerfile, src (request, api, AdminProTable, AdminLayout, DemoItemList, App, index.css)

- [ ] Default `VITE_API_BASE_URL=http://localhost:9011/backend`
- [ ] No login; menu only Demo 条目
- [ ] Drafting-table tokens in CSS / ConfigProvider

---

### Task 5: Flutter shell + Demo page

**Files:** `flutter create --org cn.nine --project-name nine_starter_flutter nine-starter-flutter` then replace lib/

- [ ] Core: api_response, api_exception, jh_api_crypto, dio_provider (AES, no Token), api_base_url, device_ids
- [ ] Demo list/save/delete; home is Demo
- [ ] applicationId `cn.nine.starter`; INTERNET permission only

---

### Task 6: new-app.ps1 + docs

**Files:** `scripts/new-app.ps1`, `docs/NEW_PROJECT.md`, `README.md`

- [ ] Replace map: `cn.nine.starter`, `NineStarter`, `nineStarter`, `nine-starter`, `nine_starter`, `NINE_STARTER` (longest first)
- [ ] Exclude `.git` `node_modules` `target` `dist` `build` `.dart_tool`
- [ ] `-SkipDemo` deletes Demo sources; V1 becomes comment-only
- [ ] Dry-run mentally against `order-hub`; script prints next steps

---

### Task 7: Verify

- [ ] `mvn test` in `nine-starter-api` passes
- [ ] Grep skeleton for `senior-post` / `senior_golden` / `笔友` / `信件` — none in source (docs may mention source project once in README)
- [ ] If Docker available and ports free: `.\scripts\dev-up.ps1` then POST paging
