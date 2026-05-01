---
name: backend-foundation-capabilities
description: Enforces senior-post backend base-framework conventions for Spring Boot API and service development, including MyRequestContextHolder usage, unified response (ResultResponseHandlerMethodProcessor), 85xx token error codes, PageQuery/PageData pagination, audit domain fields, Feign bridge CRUD, Redis template, AES encrypt (@EnableEncrypt / wj.security), graceful shutdown, Locale interceptor, codegen templates, and prohibitions from commons-* modules. Use when implementing, modifying, or reviewing backend code in senior-post (Controller, Service, Domain, Mapper, Feign, Redis).
---

# Backend Foundation Capabilities

## API prefixes

- **App**: `AppServiceDefine.SERVER_PREFIX` → `/api`（可加解密由 `@EnableEncrypt` 与 `wj.security` 等配置决定；客户端需按文档携带请求头）。
- **Admin**: `AppServiceDefine.WEBAPI_PREFIX` → `/webapi`（对内明文 JSON，一般不走 AES；统一响应与 `/api` 一致，`85xx` 约定相同）。
- DB schema changes: **Flyway** scripts under `senior-post-api/server/src/main/resources/db/migration`.

## Scope

Framework modules (能力来自 `commons-*`，详见源文档模块表):

- `commons-basic` — 请求上下文、Token、异常、工具类
- `commons-data` — 领域/DTO 基类、分页
- `commons-web` — 统一响应、认证过滤器、异常处理、优雅停机、Locale
- `commons-security` — APP 接口 AES 加解密
- `commons-feign-bridge-core` / `commons-feign-bridge-mybatis` — 代码生成模板、Feign CRUD 基类
- `commons-redis-starter` — Redis 模板

## Mandatory Rules

1. Never parse `HttpServletRequest` manually for user/client context in business code; use `MyRequestContextHolder`.
2. Never manually wrap controller returns as `ApiResponse`; framework uses `ResultResponseHandlerMethodProcessor`.
3. Never hardcode user identity; use `MyRequestContextHolder.userId()`（`Long`，未登录可为 `null`）或 `getContext().getTokenInfo()`。
4. Prefer framework components over ad-hoc duplicates.
5. Do not use `new Date()` for business timestamps; use `LocalDateTime.now()`（与源文档「禁止事项」一致）.

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

异常体系以 `BaseRuntimeException` 为抽象基类；业务侧常用 `BusinessException`（包：`cn.nine.commons.basic.exception.unchecked`）、`BadRequestException`、`DataValidationException`、`CommonsScopeException`（包：`cn.nine.commons.basic.exception`）。Token 错误对齐 **`85xx`** 常量（8500–8505）。

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

## Prohibitions (align with source doc §十二)

1. 禁止自行解析 `HttpServletRequest` 取用户/客户端信息  
2. 禁止手动包装 Controller 返回值为 `ApiResponse`  
3. 禁止在 Service 中用 `new Date()` 写时间，使用 `LocalDateTime.now()`  
4. 禁止硬编码用户 ID  
5. 禁止重复造轮子，优先使用框架组件  

## Delivery Self-Check

- Context：`MyRequestContextHolder`，无手搓 request 解析  
- Controller：无手动 `ApiResponse` 包装  
- Exceptions：框架异常类型 + Token **`85xx`**  
- Pagination：`PageQuery` + `PageData`  
- Audit：`initAudit` / `updateAudit` / 软删 `markDeleted`  
- APP 加密：注解与 `wj.security` 配置一致（若该接口在加密范围内）  
- 新增仅依赖源文档与 `commons-*` 已有能力时，已查源文档 FAQ/禁止项  

## Source

Canonical detail、示例代码与目录结构见 **`senior-post-api/底层框架能力.md`**（含 §13 模块结构、§14 优雅停机与 Locale、附录依赖坐标）。
