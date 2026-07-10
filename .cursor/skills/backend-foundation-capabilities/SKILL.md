---
name: backend-foundation-capabilities
description: Enforces senior-post backend base-framework conventions for Spring Boot API and service development, including mandatory five-layer architecture (Controller → Business Service → IService/ServiceImpl → Mapper → Table), industry-standard Javadoc/comments and key-path SLF4J logging, MyRequestContextHolder usage, unified response (ResultResponseHandlerMethodProcessor), 85xx token error codes, PageQuery/PageData pagination, audit domain fields, Feign bridge CRUD, Redis template, AES encrypt (@EnableEncrypt / wj.security), graceful shutdown, Locale interceptor, codegen templates, and prohibitions from commons-* modules. Use when implementing, modifying, or reviewing backend code in senior-post (Controller, Service, Domain, Mapper, Feign, Redis).
---

# Backend Foundation Capabilities

## API prefixes

- **App**: `AppServiceDefine.SERVER_PREFIX` → `/api`（可加解密由 `@EnableEncrypt` 与 `wj.security` 等配置决定；客户端需按文档携带请求头）。
- **Admin**: `AppServiceDefine.WEBAPI_PREFIX` → `/webapi`（对内明文 JSON，一般不走 AES；统一响应与 `/api` 一致，`85xx` 约定相同）。
- DB schema changes: **Flyway** scripts under `senior-post-api/server/src/main/resources/db/migration`.
  - **Dev policy (PLAN §1.3)**: append incremental `Vn__*.sql` only; do **not** consolidate/rewrite/delete the migration chain during milestones.
  - **Pre-launch**: one-time migration cleanup window; not a recurring milestone task.
- **Local run**: start API + Manage via root `docker-compose.yml` (see `.cursor/rules/docker-compose-dev-services.mdc`); always `mvn clean package` before API image rebuild (`scripts/dev-up.ps1`).

## Scope

Framework modules (能力来自 `commons-*`，详见源文档模块表):

- `commons-basic` — 请求上下文、Token、异常、工具类
- `commons-data` — 领域/DTO 基类、分页
- `commons-web` — 统一响应、认证过滤器、异常处理、优雅停机、Locale
- `commons-security` — APP 接口 AES 加解密
- `commons-feign-bridge-core` / `commons-feign-bridge-mybatis` — 代码生成模板、Feign CRUD 基类
- `commons-redis-starter` — Redis 模板

## Mandatory Rules

1. **Layered architecture (hard requirement)** — follow §10 below; Controller must not inject or call Mapper.
2. Never parse `HttpServletRequest` manually for user/client context in business code; use `MyRequestContextHolder`.
3. Never manually wrap controller returns as `ApiResponse`; framework uses `ResultResponseHandlerMethodProcessor`.
4. Never hardcode user identity; use `MyRequestContextHolder.userId()`（`Long`，未登录可为 `null`）或 `getContext().getTokenInfo()`。
5. Prefer framework components over ad-hoc duplicates.
6. Do not use `new Date()` for business timestamps; use `LocalDateTime.now()`（与源文档「禁止事项」一致）.
7. **Comments + logging (hard requirement)** — follow §11 below; public/Biz methods, complex branches, and key business paths must be documented and logged appropriately.

## Client request headers (typical)

客户端需按约定携带（网关/过滤器会参与解析）: `Token`, `versionCode`, `deviceId`, `Trace-Id`, `X-Real-IP` 等 — 细节以 `senior-post-api/底层框架能力.md` §2.4 为准。

## Capability Checklist

- Request context via `MyRequestContextHolder`（`userId()`, `version()`, `clientType()`, `equipmentId()`, `ipAddress()`, `country()`, `attribution()`, `getContext()` 内 `getTraceId()` / `getTokenInfo()` / `getBody()` / headers 等）
- Unified API response auto-wrapping → `ApiResponse`（`code` / `message` / `data` / `success`）
- Global exception handling; business errors via typed exceptions
- Token-related HTTP 业务码 **`8500`–`8505`**（`TOKEN_NOT_FOUND_CODE` … `TOKEN_INVALID_CODE`）
- Pagination: DTO 内嵌 `PageQuery`，返回 `PageData`（可用 `PageData.of`、`builder()`、`empty()`、`hasRecords()`）
- Optional AES: `@EnableEncrypt`，`wj.security.*`，方法级 `@Decrypt` / `@Encrypt` / `@EncryptIgnore`
- Auditable：`AbstractAuditableDomain` / `AbstractAuditableDTO`，`initAudit` / `updateAudit` / `markDeleted`（参数 `Long userId`）
- Feign：`IFeignClient` + `AbstractMybatisFeignClient`
- Redis：`StringObjectRedisTemplate`
- Codegen：Domain/DTO/分页入参/Mapstruct/Mapper/Service/Feign/Web 等模板（含 VM 与可选 Web 页面模板，见源文档 §10）
- **commons-web 扩展**：优雅停机 `wj.graceful.shutdown.*`；Locale 由拦截器设置，业务侧可用 `LocaleContextHolder.getLocale()`

## Implementation Patterns

### 1) Request Context

Use `MyRequestContextHolder` per `底层框架能力.md` §2: 禁止在 Service/Controller 内自行从 request 解析用户信息；审计字段用 `Long userId = MyRequestContextHolder.userId()`；登录判断可用 `getContext().getTokenInfo()`。

### 2) Controller Return Convention

直接返回 DTO / `List` / `PageData` / `null`（`null` 时框架将 `data` 处理为空串等约定行为）；不要手动包 `ApiResponse`。

### 3) Exception Convention

异常体系以 `BaseRuntimeException` 为抽象基类；业务侧常用 `BusinessException`（包：`cn.nine.commons.basic.exception.unchecked`）、`BadRequestException`、`DataValidationException`、`CommonsScopeException`（包：`cn.nine.commons.basic.exception`）。Token 错误对齐 **`85xx`** 常量（8500–8505）。BusinessException默认编码4501,作为提示信息显示

### 4) Pagination Convention

- 请求体/入参 DTO 嵌入 `PageQuery page`（`page` + `size`）
- Service 返回 `PageData<T>`，由 MyBatis-Plus `Page` 结果与 MapStruct 转换后组装

### 5) Encryption Convention (App APIs)

- 启动类：`@EnableEncrypt`
- 配置：`wj.security.key`、`debug`、`android-version` / `ios-version` 等
- 方法：`@Decrypt` + `@Encrypt`；`@EncryptIgnore` 绕过

### 6) Auditable Domain/DTO

- Domain 继承 `AbstractAuditableDomain`：`createdAt` / `createdBy` / `updatedAt` / `updatedBy` / `delFlag`
- `initAudit(userId)`、`updateAudit(userId)`、`markDeleted(userId)`
- DTO 可继承 `AbstractAuditableDTO`

### 7) Feign Bridge Convention

- Client：`interface XxxFeignClient extends IFeignClient<Long, XxxDTO>`
- Resource：`AbstractMybatisFeignClient<Long, Domain, DTO, Mapstruct>` + `setBaseMapper`
- 优先使用继承的 `feignAdd` / `feignQueryById` / `feignPage` 等标准方法

### 8) Redis Convention

注入 `StringObjectRedisTemplate`：`opsForValue` / `expire`；键名按业务前缀（如 `user:{id}`）。

### 9) Code Generation Convention

`CodeConfig` + `DatabaseCodeMapping.execute`；`templateList` 常用 `TemplatePackageConstant.domain`, `dtoDb`, `mapstruct`, `repository`, `client`, `resource`, `feignClient`, `feignResource` 等 — 完整模板清单见源文档 §10.1。

### 10) Layered Architecture Convention（强制 · PLAN §1.1）

**所有数据库访问必须走五层调用链，禁止跨层直调：**

```
Controller → Business Service → Base IService (IService / ServiceImpl) → Mapper → Table
```

#### 包结构约定（`senior-post-api/biz`）

| 包 | 职责 |
|----|------|
| `...controller.app` / `...controller.admin` | HTTP 入参、鉴权上下文、调 BizService、返回 DTO |
| `...service.biz` | 业务编排、领域规则、**事务边界**、组合多个 Base Service |
| `...service.base` | `IService<T>` 接口 + `ServiceImpl<M, T>` 实现，**所有可复用 DB 方法收口于此** |
| `...mapper` | MyBatis Mapper，**仅**被对应 `ServiceImpl` 调用 |
| `...model.domain` | 表实体 / Domain |

#### 每层禁止事项

| 层级 | 允许 | 禁止 |
|------|------|------|
| **Controller** | 校验、调 `XxxBizService`、返回 DTO/`PageData` | ❌ 注入 `Mapper`；❌ `LambdaQueryWrapper` / SQL；❌ 业务编排 |
| **Business Service** | 调多个 `XxxService`、抛业务异常、`@Transactional` | ❌ 注入 `Mapper`；❌ 直写 SQL |
| **Base IService / ServiceImpl** | `getById`、条件查询、分页、批量更新等**可复用**方法 | ❌ 堆叠跨域业务流程（上提 BizService） |
| **Mapper** | 单表映射、简单自定义 SQL | ❌ 被 Controller 或 BizService 注入 |

#### 表域标准形态

每个保留的 `bu_*` 表至少具备：

- `XxxMapper` extends `BaseMapper<XxxDomain>`
- `XxxService` extends `IService<XxxDomain>`
- `XxxServiceImpl` extends `ServiceImpl<XxxMapper, XxxDomain>` implements `XxxService`
- `XxxBizService`（按需）编排 `XxxService` 与其他 Service

可复用查询（按 ID、按 userId、按状态分页等）**写在 `ServiceImpl` 公共方法**，供多个 BizService 复用，禁止在 Controller 或 BizService 内重复拼装相同 Wrapper。

#### 示例

```java
// ❌ BAD — Controller 直调 Mapper
@RestController
public class AppLetterController {
    @Resource
    private LetterMapper letterMapper;

    @GetMapping("/{id}")
    public LetterDTO get(@PathVariable Long id) {
        return map(letterMapper.selectById(id));
    }
}

// ✅ GOOD — 五层链路
@RestController
public class AppLetterController {
    @Resource
    private LetterBizService letterBizService;

    @GetMapping("/{id}")
    public LetterDTO get(@PathVariable Long id) {
        return letterBizService.getLetter(id);
    }
}

@Service
public class LetterBizService {
    @Resource
    private LetterService letterService;

    public LetterDTO getLetter(Long id) {
        LetterDomain domain = letterService.getByIdOrThrow(id);
        return LetterMapstruct.INSTANCE.toDto(domain);
    }
}

@Service
public class LetterServiceImpl
        extends ServiceImpl<LetterMapper, LetterDomain>
        implements LetterService {

    public LetterDomain getByIdOrThrow(Long id) {
        LetterDomain domain = getById(id);
        if (domain == null) {
            throw new BusinessException("信件不存在");
        }
        return domain;
    }
}
```

#### 存量重构要求

- 发现 Controller / BizService 注入 `Mapper` → **必须重构**为经 `ServiceImpl` 公共方法访问。
- 新增接口 Code Review 以本节前述规则为硬门槛。

### 11) Comments & Logging Convention（强制 · 行业标准）

目标：**可读、可维护、可排障**。注释解释「为什么 / 业务约束」，日志记录「关键决策与失败」；禁止无信息量噪音。

#### 注释要求（Javadoc / 行内）

| 位置 | 必须写什么 |
|------|------------|
| **Controller 公开 API 方法** | 一句话业务意图；关键入参约束（可选 `@param` / `@return`） |
| **BizService 公开方法** | 业务目的、前置条件、副作用（写库/发信/扣额度/调外部）、事务边界说明 |
| **复杂分支 / 状态机** | 每个非显然分支旁写「为何走此路径」（额度不足、幂等命中、审核拦截等） |
| **非显然常量 / 魔法数** | 来源（`sys_config` 键、PRD 条款、外部协议） |
| **TODO / FIXME** | 必须带责任上下文与后续里程碑（如 `// TODO(M2): POST_OFFICE 匹配池`） |

**禁止：**

- 复述代码字面意思的废话注释（如 `// get user by id`）
- 大段注释掉的死代码（废弃即删）
- 把密钥、Token、完整 PII 写进注释

**推荐风格（中文业务说明 + 英文标识符）：**

```java
/**
 * 标准信延迟投递：扫描 due 信件并标记送达。
 * <p>幂等：已 delivered 的记录跳过；失败单条记 error 不中断批次。
 */
public void deliverDueStandardLetters() { ... }

// VIP 用户跳过每日额度（PRD §16 / sys_config letter.daily_quota 仅约束非 VIP）
if (user.isVip()) {
    return;
}
```

#### 日志要求（SLF4J）

- BizService / Scheduler / 外部集成类使用 `@Slf4j`（或显式 `Logger`）。
- **级别约定：**

| 级别 | 何时用 |
|------|--------|
| `DEBUG` | 幂等命中、静默安全分支（如「邮箱不存在仍返回成功」）、详细排查信息 |
| `INFO` | 关键业务里程碑：创建成功、投递批次开始/结束、状态迁移（含业务主键 id） |
| `WARN` | 可恢复异常、降级、重试将发生、配置缺失回退默认值 |
| `ERROR` | 失败且需人工关注：外部调用失败、批次内单条失败、数据不一致（带异常栈） |

- **必须打日志的关键处：** 事务提交前的状态变更、外部 API（IM/OSS/邮件/审核）、定时任务入口与汇总、鉴权/额度/审核拒绝、捕获后吞掉或降级的异常。
- **日志内容：** 业务主键（`userId`/`letterId`）、动作、结果；**禁止**打印密码、Token、完整邮件正文、身份证等敏感字段。
- Controller 层默认不打业务流水日志（由统一请求日志过滤器覆盖）；仅在特殊编排或降级时补充。

```java
@Slf4j
@Service
public class LetterBizService {
    public LetterDTO send(long userId, SendLetterInDto in) {
        if (!quotaService.tryConsume(userId)) {
            log.info("letter send rejected: daily quota exhausted, userId={}", userId);
            throw new BadRequestException(...);
        }
        try {
            LetterDomain saved = letterService.create(...);
            log.info("letter created, userId={}, letterId={}, mode={}", userId, saved.getId(), in.getMode());
            return toDto(saved);
        } catch (Exception e) {
            log.error("letter create failed, userId={}", userId, e);
            throw e;
        }
    }
}
```

## Prohibitions (align with source doc §十二)

1. **禁止 Controller / BizService 注入或调用 Mapper**（数据访问仅经 `ServiceImpl`）  
2. 禁止自行解析 `HttpServletRequest` 取用户/客户端信息  
3. 禁止手动包装 Controller 返回值为 `ApiResponse`  
4. 禁止在 Service 中用 `new Date()` 写时间，使用 `LocalDateTime.now()`  
5. 禁止硬编码用户 ID  
6. 禁止重复造轮子，优先使用框架组件  
7. 禁止无业务信息的废话注释；禁止日志打印密钥 / Token / 敏感 PII  
8. 禁止复杂业务分支无注释、关键路径（写库/外部调用/额度/审核）无日志  

## Delivery Self-Check

- **Layering**：Controller → BizService → ServiceImpl → Mapper；Controller/BizService 无 `Mapper` 注入  
- Context：`MyRequestContextHolder`，无手搓 request 解析  
- Controller：无手动 `ApiResponse` 包装  
- Exceptions：框架异常类型 + Token **`85xx`**  
- Pagination：`PageQuery` + `PageData`  
- Audit：`initAudit` / `updateAudit` / 软删 `markDeleted`  
- APP 加密：注解与 `wj.security` 配置一致（若该接口在加密范围内）  
- **Comments**：Biz/公开方法有意图说明；复杂分支有「为何」注释  
- **Logging**：关键写路径 / 外部调用 / 定时任务有 `INFO`/`WARN`/`ERROR`；无敏感字段泄漏  
- 新增仅依赖源文档与 `commons-*` 已有能力时，已查源文档 FAQ/禁止项  


## Source

Canonical detail、示例代码与目录结构见 **`senior-post-api/底层框架能力.md`**（含 §13 模块结构、§14 优雅停机与 Locale、附录依赖坐标）。
