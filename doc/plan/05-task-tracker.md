# 05 — 功能开发任务跟踪表

> **文档元信息**  
> **版本**：1.2 · **更新**：2026-05-09 · **维护人**：AI + Owner

**负责人**：默认 `AI + Owner`（替换 `Owner` 为实际姓名即可）。  
**周期**：`WnDx` = 第 n 周第 x 个工作日（相对，非自然日）。  
**状态**：`TODO` | `DOING` | `BLOCK` | `DONE`。

---

## Sprint 1（P0 后端为主）

| FP | 负责人 | Sprint | 起 | 止 | 状态 | 验收标准 | 交付物 |
|----|--------|--------|----|----|------|----------|--------|
| FP-X-002 | AI + Owner | S1 | W1D1 | W1D2 | DONE | 配置 OSS 后 Knife4j 调 `GET /api/oss/put-sign`；客户端 PUT 200 | `AppOssApi`、`AppOssController`、`AppOssServiceImpl`、`OssProperties`、`aliyun-sdk-oss:3.17.4` |
| FP-A6-001 | AI + Owner | S1 | W1D1 | W1D2 | DONE | `GET /api/stamps/balance` 与 `bu_user.stamps_balance` 一致 | `AppStampsApi`、`AppStampsController`、`AppStampBalanceVO` |
| FP-A6-002 | AI + Owner | S1 | W1D1 | W1D2 | DONE | `POST /api/stamps/ledger/paging` 分页 | `AppStampLedgerPageInDto`、`ledgerPaging` |
| FP-A5-001 | AI + Owner | S1 | W1D3 | W1D3 | DONE | Knife4j 发信成功；非 VIP 挂号扣 1 邮票且 `log_stamp_transaction` 有记录 | `AppSendLetterInDto`、`AppMailboxServiceImpl.sendLetter` |
| FP-A5-Fl | AI + Owner | S2 | W2D1 | W2D1 | DONE | `USE_MOCK=false`：postal/archive/detail/send/accept、邮票顶栏、`friendship-active` | `mailbox_remote.dart`、各 mailbox/directory 页 |
| FP-A6-004 | AI + Owner | S1 | W1D2 | W1D3 | DONE | 并发压测 100 次无负余额；CAS 扣减抽取为 `StampAccountService` | `StampAccountService`/`Impl`、H2 JDBC 并发单测、`StampAccountServiceImplTest` |
| FP-A5-002 | AI + Owner | S1 | W1D2 | W1D4 | DONE | sync 时间戳一致；端上刷新/前台恢复拉新 | `AppMailboxServiceImpl` COALESCE；`mailbox_page` RefreshIndicator + `WidgetsBindingObserver` |
| FP-A3-001 | AI + Owner | S1 | W1D3 | W1D4 | DONE | 未审帖不在 App 列表（`review_status=1`） | `AppPostcardServiceImpl.wallPage` |
| FP-A3-002 | AI + Owner | S1 | W1D4 | W1D4 | DONE | 未审详情对非作者不可见 | `getDetail` |
| FP-A3-003 | AI + Owner | S1 | W1D4 | W1D5 | DONE | 发帖落库 + OSS 可选 URL | `AppPostcardServiceImpl.create` |
| FP-A3-004 | AI + Owner | S1 | W1D5 | W1D6 | DONE | 评论分页与发表 | `commentsPaging` / `createComment` |
| FP-A2-001 | AI + Owner | S1 | W1D5 | W1D6 | DONE | `PATCH /api/auth/profile` + Flutter 编辑页/登录会话与 `me` 一致 | `AppAuthProfilePatchInDto`、`AuthRepository` |
| FP-A2-003 | AI + Owner | S2 | W2D6 | W2D6 | DONE | 兴趣 ≥3：`PATCH` `interestTagIds`；`AppPublicUserVO` 带标签 id/名；名录选项 `GET /api/directory/interest-tag-options`；筛选仍传 `tag_name` | `AppAuthService`、`UserTagService`、`AppDirectoryController`、`interests_picker_page`、`MockUser.interestTagIds` |
| FP-A4-001 | AI + Owner | S1 | W1D6 | W1D7 | DONE | 分页 total 正确 | `AppDirectoryServiceImpl`、`directory_remote` |
| FP-A6-002-Fl | AI + Owner | S2 | W2D1 | W2D1 | DONE | `USE_MOCK=false` 流水页调 ledger paging | `stamps_remote.dart`、`stamps_ledger_page.dart` |

---

## Sprint 2（P0 Flutter + 联调）

| FP | 负责人 | Sprint | 起 | 止 | 状态 | 验收标准 | 交付物 |
|----|--------|--------|----|----|------|----------|--------|
| 总闸 Mock | AI + Owner | S2 | W2D1 | W2D1 | TODO | `USE_MOCK=false` 主路径可演示 | `app_env` 文档 + 默认策略决策 |
| FP-A3-* UI | AI + Owner | S2 | W2D1 | W2D4 | DONE | Tab1 全真数据 | `post_wall_remote`、compose/detail |
| FP-A5-* UI | AI + Owner | S2 | W2D2 | W2D4 | DONE | 发信后列表刷新 | `mailbox_providers` + sheet（见 FP-A5-Fl） |
| FP-A2/A4 UI | AI + Owner | S2 | W2D4 | W2D5 | DONE | 编辑保存成功 | profile/directory |
| E2E 冒烟 | AI + Owner | S2 | W2D5 | W2D5 | TODO | 脚本或录屏通过 | `doc/plan/` 或 `tests/` 记录 |
| FP-X-005 | AI + Owner | S2 | W2D5 | W2D6 | DONE | 私有桶：出站 `OssDisplayUrlService` + `POST /api/oss/get-sign`；Manage `/webapi/oss/get-sign`；Flutter `PostalOssNetworkImage` 首帧失败解析 key 单次换签；`OSS_KEY_PREFIX` 与后端 `keyPrefix` 对齐 | 同上 + `postal_oss_network_image`、`oss_get_sign_service`、`oss_object_key_hint_test` |

---

## Sprint 3（P1）

| FP | 负责人 | Sprint | 起 | 止 | 状态 | 验收标准 | 交付物 |
|----|--------|--------|----|----|------|----------|--------|
| FP-A5d-002 | AI + Owner | S3 | W3D1 | W3D3 | DONE | 平邮到期自动送达 | `StandardLetterDeliveryService`、`StandardLetterDeliveryScheduler`、`V7` 索引、`StandardLetterDeliveryServiceTest` |
| FP-A5-005 | AI + Owner | S3 | W3D2 | W3D3 | DONE | 扣邮票后变已送达 | `POST .../speed-up`、`AppMailboxServiceImpl.speedUpLetter`、`mailbox_remote` |
| FP-A5d-004 | AI + Owner | S3 | W3D3 | W3D4 | DONE | REST `account_import`+`friend_add` 双向；可配置关闭；重试与日志 | `TencentImRestApiClient`、`TencentImFriendshipNotifier`、`TencentImProperties` 扩展、单测 |
| FP-A6-003 | AI + Owner | S3 | W3D4 | W3D5 | DONE | 登录/注册/发帖赠票；UTC 日切与日上限；`bu_stamp_daily_grant` 幂等 | `StampGrantService`、`V10`、`senior-post.stamps-grant`、单测 |
| FP-A7-* | AI + Owner | S3 | W3D4 | W3D6 | TODO | VIP 开关影响扣费 | VO + Flutter |
| FP-A3-005 | AI + Owner | S3 | W3D5 | W3D5 | DONE | 举报单进后台；工单列表可看举报人 | `AppReport*` + Manage `report/List.tsx` |
| FP-A4-002~004 | AI + Owner | S3 | W3D5 | W3D6 | DONE | 筛选 + 排序（`sort`）全链；独立公开页 API 仍属 FP-A4-004 | `AppDirectoryPageInDto`、`AppDirectoryServiceImpl`、`directory_remote`、筛选 Sheet |

---

## Sprint 4（P2/P3）

| FP | 负责人 | Sprint | 起 | 止 | 状态 | 验收标准 | 交付物 |
|----|--------|--------|----|----|------|----------|--------|
| FP-X-001 | AI + Owner | S4 | W4D1 | W4D3 | TODO | 本地收到测试邮件 | EmailService + 表 |
| FP-A1-003 | AI + Owner | S4 | W4D2 | W4D3 | DONE | 重置后可用新密码登录 | Flyway V8 + Auth API + 可选 SMTP / 本地日志 |
| FP-A1-007 | AI + Owner | S4 | W4D3 | W4D5 | TODO | 加解密与后端互通 | Flutter 拦截器 + 配置说明 |
| FP-A8-005 | AI + Owner | S4 | W4D4 | W4D5 | TODO | 注销策略可演示 | API + Job + Flutter |
| FP-X-003 | AI + Owner | S4 | W4D5 | W4D5 | TODO | 低版本拦截 | bootstrap 或 version API |
| FP-A9-002 | AI + Owner | S4 | W4D5 | W4D6 | DONE | 管理端分页查 `log_stamp_transaction`；可选 userId、reason 过滤 | `AdminStampsApi`、`AdminStampsController`、`StampLedgerList.tsx` |
| FP-A9-003 | AI + Owner | S4 | W4D5 | W4D6 | TODO | 用户列表接通 `blockDevice` | `UserList` + `api.blockDevice` |
| FP-B14/B15 | AI + Owner | S4 | W4D6 | W4D7 | TODO | 设计走查通过 | 主题 PR + 截图 |

---

## 阻塞登记

| 日期 | FP | 描述 | 处理人 | 解除条件 |
|------|-----|------|--------|----------|
| — | — | — | — | — |

---

## 变更记录

| 日期 | 变更 |
|------|------|
| 2026-05-02 | 初版：按 `04-dev-plan` 与 `03-priority-grouping` 生成 |
| 2026-05-02 | FP-A2-001：`PATCH /api/auth/profile`、Flutter `refreshSessionFromServer` / `updateProfileOnServer`、资料页拉 `me` |
| 2026-05-02 | 文档回写 A3/A4/A5/A6；Sprint1 标 DONE：FP-A3-001~004、FP-A4-001；修正重复 FP 编号为 FP-A5-002；FP-A6-002-Fl 流水页 |
| 2026-05-08 | FP-A6-004：`StampAccountService` 统一 CAS；`StampBalanceCasConcurrencyJdbcTest`（H2 100/200 线程）；`StampAccountServiceImplTest` |
| 2026-05-09 | FP-A9-002 DONE；`05` Sprint4 拆分 A9-002/003 行；`01` FP-A6-005 同步 |
| 2026-05-09 | FP-A3-005/007 + FP-A5-002：敏感词发帖/评/信 + 词库缓存失效；`sync` COALESCE；邮箱页下拉刷新与 `resumed` 刷新；举报列表 `reporterUserId` + `records`/`list` |
