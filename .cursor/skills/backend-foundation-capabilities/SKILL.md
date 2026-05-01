---
name: backend-foundation-capabilities
description: Enforces senior-post backend base-framework conventions for Spring Boot API and service development, including MyRequestContextHolder usage, unified response behavior, 85xx exception conventions, PageQuery/PageData pagination, audit domain fields, Feign bridge CRUD patterns, Redis template usage, and framework code-generation templates. Use when implementing, modifying, or reviewing backend code in senior-post, especially for Controller, Service, Domain, Mapper, Feign, and Redis-related changes.
---

# Backend Foundation Capabilities

## API prefixes

- **App**: `AppServiceDefine.SERVER_PREFIX` → `/api`（可加解密由环境与 `jh.security` 决定，收尾阶段统一客户端封装）。
- **Admin**: `AppServiceDefine.WEBAPI_PREFIX` → `/webapi`（对内明文 JSON，不走 AES；拦截器/统一响应与 `/api` 一致，`85xx` 约定相同）。
- DB schema changes: **Flyway** scripts under `senior-post-api/server/src/main/resources/db/migration`.

## Scope

Use this skill for `senior-post` backend development that relies on framework modules:

- `commons-basic`
- `commons-data`
- `commons-web`
- `commons-security`
- `commons-feign-bridge(-mybatis)`
- `commons-redis-starter`

## Mandatory Rules

1. Never parse `HttpServletRequest` manually for current user/client context in business code.
2. Never manually wrap controller responses as `ApiResponse`.
3. Never hardcode user identity; always read from request context.
4. Prefer framework components over custom duplicated implementations.

## Capability Checklist

- Request context via `MyRequestContextHolder`
- Unified API response auto-wrapping
- Global exception conventions and business error throwing
- Standard pagination with `PageQuery` + `PageData`
- Optional AES request/response encryption for app endpoints
- Auditable domain/DTO base classes and audit field initialization
- Feign CRUD bridge patterns for cross-service calls
- Redis operations via provided template
- Code generation templates for common layered artifacts

## Implementation Patterns

### 1) Request Context

Use `MyRequestContextHolder`:

- `userId()` / `userIdNum()`
- `version()` / `clientType()` / `equipmentId()`
- `ipAddress()` / `country()` / `attribution()`
- `getContext().getTraceId()`

Recommended usage:

- Fill audit fields in service layer using current user ID
- Apply version-based compatibility branches in controller/service
- Persist trace ID in operation logs for chain tracking

### 2) Controller Return Convention

Controller methods return business data directly (DTO/list/page/null).  
Framework response processor wraps output to unified API format.

### 3) Exception Convention

Prefer typed runtime exceptions:

- `BusinessException`
- `BadRequestException`
- `DataValidationException`
- `CommonsScopeException`

Token-related errors follow business code namespace `85xx`.

### 4) Pagination Convention

- Input DTO embeds `PageQuery page`
- Service returns `PageData<T>`
- Build from mapper page result and converted DTO list

### 5) Encryption Convention (App APIs)

Enable with `@EnableEncrypt` and security key config.  
Annotate endpoint methods with:

- `@Decrypt` for request body decryption
- `@Encrypt` for response body encryption
- `@EncryptIgnore` for explicit bypass

### 6) Auditable Domain/DTO

Entity models extend `AbstractAuditableDomain` and call:

- `initAudit(userId)` on create
- `updateAudit(userId)` on update
- `markDeleted(userId)` on soft delete

Transfer models can extend `AbstractAuditableDTO`.

### 7) Feign Bridge Convention

- Define client interface by extending `IFeignClient<PK, DTO>`
- Implement resource by extending `AbstractMybatisFeignClient<...>`
- Reuse inherited standard CRUD/page/count methods first

### 8) Redis Convention

Inject `StringObjectRedisTemplate` and use template ops for:

- set/get cache entries
- expiration control
- key naming by domain prefix (example: `user:{id}`)

### 9) Code Generation Convention

Prefer built-in templates for new modules:

- `domain`, `dtoDb`, `dtoInput`, `mapstruct`, `repository`
- `client`, `resource`, `feignClient`, `feignResource`

## Delivery Self-Check

Before finishing backend feature changes, verify:

- Context access uses `MyRequestContextHolder`
- No manual response wrapper in controller
- Exceptions use framework typed exceptions
- Pagination endpoint follows `PageQuery`/`PageData`
- Audit fields are initialized/updated correctly
- Token/Auth error handling aligns with `85xx`

## Source

Derived from `senior-post-api/底层框架能力.md`.
