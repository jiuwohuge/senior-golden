# 06 — 开发环境、工具与资源清单

> **文档元信息**  
> **版本**：1.1 · **更新**：2026-05-09 · **维护人**：AI + Owner

勾选表示**本机已就绪**；未勾为启动开发前需补齐。

---

## 1. 通用

| 项 | 状态 | 说明 |
|----|------|------|
| Git | [ ] | `senior-golden` 可克隆、分支策略自定 |
| IDE | [ ] | IntelliJ + Flutter 插件 / VS Code + Dart |
| Knife4j / OpenAPI | [ ] | 启动 `senior-post-api` 后访问 `/doc.html`（以启动日志为准） |

---

## 2. 后端 `senior-post-api`

| 项 | 状态 | 说明 |
|----|------|------|
| JDK 17 | [ ] | 与 `pom` 一致 |
| Maven | [ ] | 可构建 `commons-framework` 依赖（见 PLAN：本地仓库） |
| PostgreSQL | [ ] | `application-local.yml` 指向实例；Flyway 自动迁移（含 `V10` 邮票赠送幂等表） |
| Redis | [ ] | 与 `application-local.yml` 一致；P1 延迟队列依赖 |
| 环境 Profile | [ ] | `local` 启动；`/api/**` 明文联调策略与 `jh.security` 白名单已读 |
| 腾讯 IM | [ ] | `senior-post.tencent-im`：`TENCENT_IM_SDK_APP_ID`、`TENCENT_IM_SECRET_KEY`；测 `/api/im/usersig`。**好友同步（FP-A5d-004）**：控制台创建 **App 管理员**账号，设置环境变量 `TENCENT_IM_REST_IDENTIFIER`（与管理员 UserID 一致）；海外地域时可配 `TENCENT_IM_REST_HOST`（默认 `console.tim.qq.com`） |
| 阿里云 OSS | [ ] | 环境变量：`ALIYUN_OSS_ENDPOINT`、`ALIYUN_OSS_ACCESS_KEY_ID`、`ALIYUN_OSS_ACCESS_KEY_SECRET`、`ALIYUN_OSS_BUCKET`；可选 `ALIYUN_OSS_PUBLIC_BASE_URL`（CDN）；Bucket CORS 允许 App 源站 **PUT**；对应 `senior-post.oss.*` |
| SMTP / 邮件 | [ ] | 本地可用 MailHog / 企业测试邮箱；**FP-X-001 前必配** |

---

## 3. Flutter `senior-post-flutter`

| 项 | 状态 | 说明 |
|----|------|------|
| Dart SDK | [ ] | `pubspec`：`>=3.9.0 <4.0.0`；对齐 `tool/flutter_sdk_version.txt` 推荐 |
| `flutter pub get` | [ ] | 无报错 |
| `--dart-define` | [ ] | `USE_MOCK=false`、`API_BASE_URL=http(s)://...`（见 PLAN 真机说明） |
| Android/iOS 网络 | [ ] | Debug 明文 HTTP、iOS `NSAllowsLocalNetworking`（见 PLAN 历史记录） |
| 腾讯 IM 真机 | [ ] | `TENCENT_IM_*` 与后端一致 |

---

## 4. 管理端 `senior-post-manage`

| 项 | 状态 | 说明 |
|----|------|------|
| Node LTS | [ ] | 与团队约定一致 |
| `npm i` / `pnpm i` | [ ] | 可 `vite` 启动 |
| `/webapi` 代理 | [ ] | 指向本地后端；登录拿 Token |
| 管理员种子 | [ ] | Flyway `V3__seed_super_admin.sql` 已执行 |

---

## 5. 工具与资产

| 项 | 状态 | 说明 |
|----|------|------|
| Postman / Hoppscotch | [ ] | 集合：auth → postcard → mailbox |
| 设计稿 B14/B15 | [ ] | Figma 或静态规范；未齐则 Sprint 4 标 BLOCK |
| 隐私政策 / 用户协议 URL | [ ] | 注册页已链；内容法务审核 |

---

## 6. 启动顺序（建议）

1. 起 PostgreSQL + Redis  
2. `mvn -pl senior-post-api/server -am spring-boot:run`（或模块等价命令）  
3. 验 `/doc.html` 与 `/api/bootstrap/init`  
4. `flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=...`  
5. `npm run dev`（manage）并登录 `/webapi`

---

## 7. 完成定义（环境侧）

- [ ] 新成员按本节从零到「能跑通注册+Knife4j」≤ 4 小时  
- [ ] 敏感配置仅 `.yml` / 环境变量，**不入库**
