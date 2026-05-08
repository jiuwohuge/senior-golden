# 会话进度日志

## 2026-05-02 — planning-with-files：未实现功能规划

- **动作**：读取 `PLAN.md`（功能清单、M1–M4、状态 S9、阻塞 B14/B15）；检索 `AppMailboxApi`、Flutter `useMock` 引用。
- **产出**：新建 `task_plan.md`、`findings.md`、`progress.md`（项目根目录）。
- **session-catchup.py**：本机 `$env:USERPROFILE\.claude\skills\planning-with-files\...` 不存在，已跳过。
- **下一步建议**：从 `task_plan.md` Phase 1 选取「发信 API + Flutter 联调」或「Post Wall 审核链路」之一作为首个迭代目标，并在本文件追加一行日志。

## 2026-05-02 — 未实现功能规划文档体系（落地）

- **动作**：按计划重写 `task_plan.md` 为索引 + Phase 表；新建 `doc/plan/01-feature-list.md` ~ `06-env-setup.md`；扩充 `findings.md` §5 摸底清单。
- **未改**：`.cursor/plans/*.plan.md`（用户要求不编辑计划文件本身）。
- **下一步建议**：打开 `doc/plan/05-task-tracker.md`，将 **Sprint 1 / FP-X-002** 与 **FP-A6-001** 标为 `DOING`，从 OSS 签名与余额接口开始实现。

## 2026-05-02 — Sprint1：OSS 预签名 + 邮票 API（后端）

- **动作**：新增 `AppOssApi`（`GET /api/oss/put-sign`）、`AppStampsApi`（`GET /api/stamps/balance`、`POST /api/stamps/ledger/paging`）；`senior-post.oss` 配置与 `jh.security` 白名单；`biz` 引入 `aliyun-sdk-oss:3.17.4`；`mvn -pl server -am compile -DskipTests` 通过。
- **下一步建议**：Flutter 接线邮票与 OSS；Sprint1 继续 **FP-A5-001 发信** 或 **FP-A3-001 明信片列表**。

## 2026-05-02 — FP-A5-001：发信 API

- **动作**：`POST /api/mailbox/letters/send`（`AppSendLetterInDto`）；平邮 `status=1` + 随机预计 10–120 分钟；挂号非 VIP 扣 1 邮票 CAS 更新 + 流水；挂号 VIP `sendMode=3` 不扣票；`mvn -pl server -am compile -DskipTests` 通过。
- **下一步建议**：Flutter `send_letter_sheet` 接该接口；后端 **FP-A5d** 平邮到期自动变已送达仍待做。

## 2026-05-02 — 邮票流水 Flutter + 计划文档对齐

- **动作**：新增 `stamps_remote.dart`；`stamps_ledger_provider` 在 `USE_MOCK=false` 时调 `POST /api/stamps/ledger/paging`；更新 `doc/plan/01-feature-list.md`（A1/A3/A4/A5/A6）、`PLAN.md` 功能清单与改动预测、`05-task-tracker.md`（FP-A3-001~004、FP-A4-001、FP-A6-002-Fl、Sprint2 若干 DONE；`FP-A5-001` 重复行改为 `FP-A5-002`）。
- **验证**：`dart analyze`。
- **下一步建议**：FP-A3-005 举报、FP-A5-005 加速 API，或 FP-A6-004 压测单测。

## 2026-05-02 — FP-A2-001：资料 PATCH + 个人中心拉 me

- **动作**：后端 `AppAuthProfilePatchInDto`、`PATCH /api/auth/profile`；`AppAuthService.updateProfile`；Flutter `AuthRepository.refreshSessionFromServer` / `updateProfileOnServer`、`mockSessionProvider.applyFromPublicUserVo`；登录/注册响应 `user` 写会话；`profile_edit_page` / `profile_page` 非 Mock 联调；`doc/plan/01`、`05` 与 `progress` 更新。
- **验证**：`mvn -pl server -am compile -DskipTests`、`dart analyze` 已通过。
- **下一步建议**：兴趣标签写回（FP-A2-003）或邮票流水页接 `ledger/paging`。

## 2026-05-02 — Flutter 信箱 × 邮票 REST 接线

- **动作**：新增 `mailbox_remote.dart`（postal/archive/letters/send/accept/friendship、stamps balance）；`mailbox_providers`、`mailbox_archive`、`letter_detail`、`mailbox_page`、`send_letter_sheet` 在 `USE_MOCK=false` 时走 `dio`；后端补 `GET /api/mailbox/letters/{id}`、`GET .../friendship-active`，`MailboxLetterItemVO.content` 详情用。
- **验证**：`dart analyze`（上述目录）无告警。
- **下一步建议**：Post Wall / Directory 真接口；平邮 **FP-A5d** Worker；Flutter **Speed Up** 接后端。

## 2026-05-06 — FP-A5-005：平邮加速 API + Flutter

- **动作**：`POST /api/mailbox/letters/{letterId}/speed-up`（仅发件人、平邮运输中、VIP 免扣、非 VIP CAS 扣 1 票 + `log_stamp_transaction`）；`mailbox_remote.speedUp`、`speed_up_sheet` 非 Mock 分支、`letter_detail` 对本人平邮运输中展示 Speed Up（去 Mock 专属门闸）。
- **验证**：`mvn -pl server -am compile -DskipTests`；`dart analyze`（上述 mailbox 三文件）无告警。
- **下一步建议**：**FP-A5d-002** 平邮到期自动送达 Worker，或 **FP-A3-005** 举报。

## 2026-05-07 — FP-A5d-002：平邮到期自动送达（planning-with-files）

- **动作**：`@EnableScheduling`；`StandardLetterDeliveryService`（`letter_type=2`、`status=1`、`expected_arrival_time <= now` 幂等更新为已送达）；`StandardLetterDeliveryScheduler`（`senior-post.mailbox.standard-delivery-*`）；Flyway **`V7__letter_standard_due_index.sql`**；`StandardLetterDeliveryServiceTest`（Mockito）。
- **说明**：当前以 **PG 扫描 + 条件 UPDATE** 实现 PLAN B3 平邮延迟闭环；**Redis ZSET** 可作为高并发优化后续加。
- **验证**：`mvn -pl biz -am test -Dtest=StandardLetterDeliveryServiceTest` 通过。
- **session-catchup.py**：本机未找到可执行脚本，已跳过（与 `task_plan.md` 历史记录一致）。
- **下一步建议**：**FP-A3-005** 管理端举报列表与 App 举报联动验收；或 **FP-A5d-004** IM Notifier。

## 2026-05-07 — 遗漏功能系统化文档（planning-with-files）

- **动作**：新建 [`doc/plan/07-gap-analysis-and-roadmap.md`](doc/plan/07-gap-analysis-and-roadmap.md)（遗漏项：描述 / 预期行为 / P0–P3 / 与现有模块关联；四阶段路线图：顺序、技术方案、资源粗估）；更新 [`task_plan.md`](task_plan.md) 索引与「下一步」；勘误 [`findings.md`](findings.md) §2.1、§5.1、§5.3、§5.5（与当前 `client` 及 `USE_MOCK=false` 接线对齐）。
- **下一步建议**：按 `07` 第一阶段从 **FP-A6-004**、**FP-A3-005**、敏感词、**FP-A5-002**、**FP-A4-003** 顺序执行，并在 `05` 勾选。

## 2026-05-08 — FP-A6-004：邮票 CAS 抽取 + 并发单测（planning-with-files）

- **动作**：新增 `StampAccountService` / `StampAccountServiceImpl`；`AppMailboxServiceImpl` 挂号扣票与平邮加速改走统一 CAS；`biz` 增加 **`com.h2database:h2`（test）**；`StampBalanceCasConcurrencyJdbcTest`（独立内存库、100/200 线程单扣）；`StampAccountServiceImplTest`（Mockito）；更新 `doc/plan/01`、`05`。
- **验证**：`mvn -pl biz -am test` 通过。
- **下一步建议**：**FP-A3-005** 举报联调验收，或 **FP-A5-002** 双用户信箱、**FP-A4-003** 名录排序。

## 2026-05-09 — FP-A4-003：名录排序（planning-with-files）

- **动作**：`AppDirectoryPageInDto.sort`（`DEFAULT`/`SAME_AGE`/`SHARED_INTEREST`）；`AppDirectoryServiceImpl.applySort`（同龄 `ABS(birth_year)`、共同标签 `bu_user_tag` 子查询计数）；Flutter `DirectoryFilter.sort`、筛选 Sheet ChoiceChip、`directory_remote`；Mock `MockDirectoryRepository.list` 同龄/共同兴趣排序。
- **验证**：`mvn -pl biz,client -am compile -DskipTests`；`dart analyze lib/features/directory` 无告警。
- **下一步建议**：**FP-A3-005** 举报验收、**FP-A3-007** 敏感词、**FP-A5-002** 双用户信箱。

## 2026-05-09 — FP-A3-005 + FP-A3-007 + FP-A5-002（planning-with-files）

- **动作**：
  - **敏感词**：`SensitiveWordService.assertPlainTextAllowed` + 60s 词表快照；`upsert`/`delByIds` 失效缓存；`AppPostcardServiceImpl` 发帖与评论、`AppMailboxServiceImpl` 发信正文前校验。
  - **信箱同步**：`loadLettersForUser` 在 `since != null` 时使用 `COALESCE(updated_at, created_at) > since`；`MailboxPage` `WidgetsBindingObserver` 在 `resumed` 时 invalidate postal/archive/letters；Postal 列表 **RefreshIndicator** 下拉刷新。
  - **举报**：Manage `report/List.tsx` 增加 **Reporter** 列、`records`/`list` 兼容（对齐统一分页字段）。
- **验证**：`mvn -pl biz -am test`、`dart analyze lib/features/mailbox/mailbox_page.dart` 通过。
- **下一步建议**：**FP-A5d-004** IM Notifier、**FP-A6-003** 赠票规则、**E2E 冒烟**、或资料 **FP-A2-002** 头像 OSS。

## 2026-05-08 — FP-A1-003：忘记密码 / 重置密码（planning-with-files + frontend-design）

- **动作**：Flyway `V8__password_reset_token.sql`；`PasswordResetService`（6 位码、胡椒哈希、频控、一次性核销）；`PasswordResetMailNotifier`（`spring-boot-starter-mail` + 未配 SMTP 时 WARN 日志）；`AppAuthApi` / `AppAuthController` / DTO；`application.yml` 白名单与 `senior-post.auth`；Flutter `forgot_password_page` 复古头图 + 步骤动画 + 6 位校验文案；`auth_repository` Mock 对齐 6 位。
- **验证**：`mvn -pl server -am compile -DskipTests` 通过；`flutter analyze lib/features/auth/forgot_password_page.dart` 无告警。（本机 Surefire 对 biz 测试显示 *Tests are skipped*，与父 POM/环境有关；新增用例已提交于 `PasswordReset*Test`。）
- **下一步建议**：生产配置 `PASSWORD_RESET_PEPPER`、`spring.mail.host` 与 `senior-post.mail.from`；按需落地 **FP-X-001** 发信 outbox。

## 2026-05-08 — FP-X-005 规划：OSS 私有读（GET 预签名，无公共桶）

- **动作**：按 planning-with-files 更新 [`task_plan.md`](task_plan.md)（子阶段 O1–O7）、[`findings.md`](findings.md) §6、[`doc/plan/05-task-tracker.md`](doc/plan/05-task-tracker.md) 与 [`doc/plan/01-feature-list.md`](doc/plan/01-feature-list.md) 登记 **FP-X-005**；`session-catchup.py` 本机路径不可用，已跳过。
- **下一步建议**：将 **FP-X-005** 标为 `DOING`，从 O1 契约 + O2 `signGet` 与 key 白名单开始实现，再接 O3 VO 或批量换签与 Flutter 403 重试。

## 2026-05-08 — Flutter：明信片发布预览、下拉刷新、注册/头像/i18n（planning-with-files）

- **后端**：`AppAuthProfilePatchInDto.avatarUrl`；`AppAuthService.updateProfile` 校验 OSS key 为 `avatar` 场景且属当前用户；`mvn -pl biz,client -am compile` 通过。
- **Flutter**：发帖页本地上传后立即 `Image.memory` 预览（私有桶 objectKey 友好）；明信片墙/名录 `RefreshIndicator` + 防并发刷新；注册页出生年份底部表格式、默认 45 岁、地区按语言自动匹配；资料页头像选图→`crop_your_image` 圆裁→OSS `avatar`→PATCH；`shared_preferences` + `appLocaleProvider` 设置页语言切换；`post_en/zh.arb` 增补一批 UI 文案；`PostalButton` ghost 浅色底防「透明看不见」；引导页底部 safe inset。
- **验证**：`flutter analyze` 无告警。

## 2026-05-08 — FP-A2-003：兴趣标签持久化 + App 写回（续）

- **后端**：`GET /api/directory/interest-tag-options?lang=` → `List<InterestTagOptionVO>`（`AppDirectoryService`/`Impl`、`AppDirectoryApi`、`AppDirectoryController`）；与既有 `PATCH profile` `interestTagIds`、`me` 载荷及 `UserTagService.replaceUserTags` 衔接。
- **Flutter**：`DirectoryRemoteRepository.listInterestTagOptions`；名录筛选非 Mock 改拉选项（`value` 仍为 `tag_name`）；`InterestsPickerPage` 非 Mock 多选 id 并 `PATCH`；`MockUser.interestTagIds` + `applyFromPublicUserVo` 解析 `interestTagIds`/`interestTagNames`；`AuthRepository.updateProfileOnServer` 支持仅提交 `interestTagIds`。
- **验证**：`mvn -pl biz,client -am compile -DskipTests`；`dart analyze`（上述变更文件）无告警。
- **文档**：`doc/plan/01-feature-list.md` A2 行、`05-task-tracker.md` 增 FP-A2-003 DONE。

## 2026-05-08 — 注册强制兴趣 + 名录 VO 带兴趣

- **后端**：`AppRegisterInDto.interestTagIds`（`@NotNull` + `@Size(min=3,max=30)`）；注册后 `replaceUserTags`；`DirectoryUserItemVO` 增加 `interestTagIds`/`interestTagNames`，`UserInterestAssembler` 供资料与名录复用；`AppBootstrapVO.interestTagOptions` + `GET /api/bootstrap/init?lang=`（匿名）拉选项。
- **Flutter**：`appBootstrapProvider(lang)`；注册页兴趣 chips；`AuthRepository.register` 提交 `interestTagIds` / Mock `seedNewMockAccount`；`directory_remote` 映射名录兴趣字段。
- **验证**：`mvn -pl biz,client -am compile -DskipTests`；`dart analyze`（相关文件）通过。
