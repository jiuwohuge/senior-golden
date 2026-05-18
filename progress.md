# 会话进度日志

## 2026-05-18 — 排查 `auth/me` 高频调用淹没业务接口日志（planning-with-files）

- **现象**：运行日志中出现大量 `GET /backend/api/auth/me`，用户怀疑明信片墙/通信名录未调用正确接口。
- **定位**：`MainShell` 底部导航点击时调用 `context.go` 切换 `/`、`/directory`、`/mailbox`、`/profile`，导致 `MainShell` 反复重建；`ProfilePage.initState` 每次都会触发 `refreshSessionFromServer()`。
- **修复**：`main_shell.dart` `_goBranch` 改为仅更新 `_index`（壳内 `IndexedStack` 切页），不再每次 `go` 重建。
- **验证**：`flutter analyze` 通过。

## 2026-05-12 — Sprint 4 五项 FP 代码闭环（A1-006 / X-001 / A1-007 / X-003 / A10-001）

- **后端**：`AppAuthService` 设备头体校验；`V17` 邮件 Outbox + `MailOutboxDispatchScheduler`；忘记密码改入队 + `LocaleContextHolder` locale；`PasswordResetMailNotifier` 使用 `MessageSource`（`app.mail.passwordReset.*`）；`V18` 公告列 + `AppReleaseNoteService` + `GET /api/bootstrap/release-note`；`AnnouncementServiceImpl` 禁止 `<` 与版本区间校验；`jh.security` 收窄明文 URI 并设 `android-version`/`ios-version`；`application.yml` outbox 配置。
- **Flutter**：`encrypt` + `jh_api_crypto` + `dio_provider` 请求/响应加解密；`API_VERSION_CODE`；`ReleaseNoteLayer` + `release_note_fetch`；`SeniorPostApp` Stack 挂载。
- **Manage**：公告页三字段 + 预览 + 编辑。
- **文档**：`01` / `05` / `06` 回写；`mvn -pl biz -am compile`；`dart analyze lib`；`PasswordResetServiceTest` 迁至 `biz.support` 包避免与生产类同包冲突。

## 2026-05-09 — 产品裁剪：backlog 删除 + 下一波次（A1-006 / X-001 / A1-007）（planning-with-files）

- **Owner 输入**：真订阅不做；B14/B15 不作为任务；平邮仅用 PG 定时；删 A7-002、A3-008、A9-004、E2E、UAT、A1-004、A8 增强、X-004、A8-004、OSS 批量迁移等；**FP-X-003** 改为可关闭公告 + Manage 富文本；**A10** 仅保留邮件模板 i18n（**FP-A10-001**）。
- **文档**：`01` v1.8、`05` v1.4、`07` v1.5、`03` v1.3、`04` v1.3、`02` v1.3、`PLAN` 2.3、`feature-overview` 1.6、`task_plan` 1.6、`findings` §17～§18。
- **澄清写入**：`findings.md` **§17**（原 A5d-003 事务含义）、**§18**（X-003 公告非强更）。
- **session-catchup.py**：9009，跳过。

## 2026-05-09 — 文档：功能完成度再对齐（注销 MVP / 回信 / 优先级摘要）

- **动作**：对照 `08-mock-removal-gaps.md` 与代码，回写 **`doc/plan/01-feature-list.md`**（`FP-A8-005` 由「缺」→ **部分 MVP**；`FP-A5-001` 注明 **`parentLetterId` 回信**）；**`doc/plan/07-gap-analysis-and-roadmap.md`** §2.0 增 **注销 MVP**、**回信已交付** 行并修正 §2.0 后「下一步」措辞；**`PLAN.md`** A5/A8 功能清单表述；**`findings.md`** §5.3 信箱行去掉过时「回信仍待」；**`task_plan.md`** P3 与 `08` 一致。
- **结论**：真源仍为 **`01` + `05`**；路线图读 **`07` §2.0**。

## 2026-05-09 — Locale：与 commons-web LocaleAutoConfiguration 对齐

- **移除** `biz` 内 `AppI18nConfig`（避免与框架 `LocaleAutoConfiguration` 双注册 `LocaleResolver` / `@Primary` 顺序问题）。
- **`application.yml`**：`spring.web.locale-resolver: accept_header`、`spring.web.locale: zh_CN`；与 `底层框架能力.md` §14.2 补充的框架对齐说明一致。
- **验证**：`mvn -pl biz,server -am compile -DskipTests`。

## 2026-05-09 — 用户端国际化基线（planning-with-files）

- **后端**：`biz` 增加 `AppMessages`、`AppI18nConfig`（`Accept-Language` + 默认 `zh_CN`）、`messages/app.properties` / `app_zh_CN.properties`；`application.yml` 配置 `spring.messages.basename`；App 侧 Controller/Service 业务错误改为 `app.error.*` 键；`OssReadableKeyValidator` 等传入 `AppMessages`；**未改** `controller/admin` 与 `UserServiceImpl` 管理向提示。
- **Flutter**：`locale_resolution.dart`、`effectiveAppLocaleProvider`、`dio` 注入 `Accept-Language`；扩展 ARB 并替换聊天/举报/筛选/信箱/商城/发信等硬编码；`flutter analyze lib` 无告警。
- **验证**：`mvn -pl biz -am compile -DskipTests`；`mvn -pl biz -am test -Dtest=OssReadableKeyValidatorTest`；`flutter gen-l10n` + `flutter analyze lib`。

## 2026-05-09 — IM UserSig 缓存 + 聊天消息实时展示（planning-with-files）

- **Flutter `tim_facade`**：在 `expireInSeconds` 有效期内且 `getLoginUser` 与缓存一致时 **跳过** `GET /api/im/usersig`；临近过期再拉签并 `logout`+`login` 应用新 UserSig；**登录 / 注册 / 登出** 均 `invalidate(seniorPostTimFacadeProvider)` 避免账号切换复用 TIM 状态。
- **Flutter `chat_page`**：历史列表按时间排序；`V2TimAdvancedMsgListener.onRecvNewMessage` 合并当前 C2C 会话；发送成功用 `sendMessage` 返回值经 `ValueNotifier` 回灌列表；`msgID` 去重；新消息后滚动到底。
- **验证**：`dart analyze`（`tim_facade.dart`、`chat_page.dart`、`auth_repository.dart`）无告警。

## 2026-05-09 — 注销解除好友 + Connections 进聊天空白排查（planning-with-files）

- **后端**：冷静期结束正式注销前 `FriendshipService.deactivateAllFriendshipsForUser`；`TencentImRestApiClient.friendDeleteBoth`（`/v4/sns/friend_delete`，`Delete_Type_Both`）；`TencentImFriendshipNotifier.afterFriendshipRemoved`；`AppAuthService.finalizeAccountDeletionIfCooldownElapsed` 调用上述逻辑。
- **Flutter**：`mailbox_remote` 宽松解析 `peerUserId` / `peer_user_id`；Connections 点击校验非 `0`；`go_router` `/chat/:userId` 支持 `extra` 昵称；`findings.md` §15 记录根因分析。
- **验证**：`mvn -pl biz -am test -Dtest=TencentImFriendshipNotifierTest`；`mvn -pl biz,server -am compile -DskipTests`；`dart analyze`（变更文件）无告警。

## 2026-05-09 — Postal inbox 与 Connections 解耦 + 统一过滤

- **需求**：邮政收件箱不得依赖好友/笔友关系；Postal = 收件未读（`recipient_read_at` 空）∪ 发件运输中；Archive 全量；已读仅 `getLetter`（已送达收件人）与 `earlyOpenLetter`。
- **后端**：删除 `listPostalInbox` / `sync` 内 `areActiveFriends` 分支；新增 `includeInPostalInbox`；`listPostalInbox` 与 `sync` 共用同一规则；`getLetter` / `earlyOpenLetter` 行为保持与需求一致。
- **文档**：`findings.md` §10、§14 与实现对齐。
- **Flutter**：Postal 空态文案去掉「接受已送达信后才出现在 Connections」的耦合表述。
- **验证**：`mvn -pl biz -am compile -DskipTests`；`dart analyze lib/features/mailbox`。

## 2026-05-09 — 邮政收件箱：笔友已送达未读仍展示 + recipient_read_at

- **梳理**：见 `findings.md` §14（Postal=待办/未读入口，Archive=全量时间线；「最近几条」不能替代未读语义）。
- **后端**：`V16__letter_recipient_read_at.sql`；`LetterDomain.recipientReadAt`；`listPostalInbox` 笔友分支增加「收件+已送达+未读」；`getLetter` 收件人已送达首次打标已读；`earlyOpenLetter` 同步写入 `recipient_read_at`。
- **Flutter**：`letter_detail_page` `dispose` 时 `invalidate(postalInboxLettersProvider)` 以便返回列表刷新。
- **验证**：`mvn -pl biz -am compile -DskipTests`；`flutter analyze lib/features/mailbox/letter_detail_page.dart`。

## 2026-05-09 — 提前拆信：列表 status 与已读一致

- **根因**：`earlyOpenLetter` 只写 `recipient_early_open_at`，`status` 仍为运输中，App 列表仍映射为 Delivering。
- **修复**：`AppMailboxServiceImpl.earlyOpenLetter` 同步 `status=2`、`actual_arrival_time`；Flyway **`V15__letter_early_open_status_backfill.sql`** 回填历史数据。
- **验证**：`mvn -pl biz -am compile -DskipTests`。

## 2026-05-09 — SendLetterSheet：SnackBar 挂到 sheet 内 Messenger

- **问题**：`State.context` 在嵌套 `ScaffoldMessenger` 之上，`PostalSnack` 命中父页 Messenger，bottom sheet 打开时看不到「请填写正文」等提示。
- **修复**：`ScaffoldMessenger` 下包 `Builder`，`_send(sheetContext)` / 加速 sheet 的 `_confirm(sheetContext)` 全部用子树 context；异步后使用 `sheetContext.mounted`。
- **顺带**：`postal_snack.dart` 补充 `show` 的 context 使用说明。
- **验证**：`flutter analyze`（上述文件）无告警。

## 2026-05-09 — App 明信片评论：待审可见、仅驳回隐藏

- **需求**：评论正文默认展示，仅审核不通过（`review_status=2`）不展示。
- **后端**：`AppPostcardServiceImpl` 中 `commentsPage` 与评论数统计由「仅已通过」改为「非驳回 + status=正常」；`countApprovedComments` 重命名为 `countVisibleComments`。
- **验证**：`mvn -pl biz -am compile -DskipTests`。

## 2026-05-09 — Flyway V14：可审计表补齐 created_by/updated_at/updated_by

- **问题**：`bu_user_blacklist` 等 V1 表缺审计列，与 `AbstractAuditableDomain` 不一致，黑名单列表 SQL 报错。
- **迁移**：`V14__auditable_columns_bu_and_log.sql` 对 `bu_user_blacklist`、`bu_im_message`、`bu_im_conversation`、`bu_visitor_record`、`bu_daily_publish_record`、`log_admin_operation` 执行 `ADD COLUMN IF NOT EXISTS`。
- **验证**：`mvn -pl server -am compile -DskipTests`（执行后需对已部署库跑一次 Flyway migrate）。

## 2026-05-09 — 邮政收件箱在途信 + 邮票与个人中心同步

- **根因**：`AppMailboxServiceImpl.listPostalInbox` 对已建联笔友跳过全部信件，运输中平邮不出现在 `GET /api/mailbox/postal`；Flutter 邮箱邮票走独立 balance 接口与 `appSession` 分裂。
- **后端**：`listPostalInbox` 在已是笔友时仍纳入 **status=运输中** 的信件。
- **Flutter**：邮箱顶栏 / `SendLetterSheet` / `SpeedUpSheet` 使用 `appSessionProvider`；发信与加速成功后 `refreshSessionFromServer()`；移除 `mailboxStampHeaderProvider`；`MailboxPage` 回到前台时刷新 session。
- **验证**：`flutter analyze`（上述路径）无问题；`mvn -pl biz -am compile -DskipTests`。

## 2026-05-09 — 文档：PLAN A7 与 bootstrap `vipProduct` 对齐

- **动作**：`PLAN.md` [功能清单] A7 由「全链仍待」改为 **已交付 bootstrap `vipProduct` + VIP 中心读 bootstrap**；缺口指向 **FP-A7-002/003**。同步 **`07` §2.0/§3.2/§3.4**、**`05`** Sprint3 拆分 A7 行、**`02` A7-001 技术列**、**`feature-overview` §8**、**`task_plan` 决策**、**`04-dev-plan`**。
- **真源**：`doc/plan/01-feature-list.md` A7 表未改语义（A7-001 仍为「部分」——订阅侧待办）。

## 2026-05-09 — FP-A9-003：设备封禁 UI + 用户设备列表 API（planning-with-files）

- **后端**：`AdminUserApi` / `AdminUserController` 增加 `GET /webapi/user/{userId}/devices`（`UserDeviceDTO` 列表，`delFlag=false`，按 `updatedAt` 倒序）；`blockDevice` 仍为 `POST /webapi/user/device/block`。
- **Manage**：`api.userDevices`；`api.blockDevice` 改为 JSON body；`UserList` 行内「设备拉黑」Modal（设备表逐行拉黑 + 手动填 UUID）。
- **验证**：`mvn -pl biz,client -am compile -DskipTests`；`senior-post-manage` `npm run build` 成功。

## 2026-05-09 — FP-A9-002：管理端邮票流水 API + Manage 页（planning-with-files）

- **后端**：`AdminStampsApi` / `AdminStampsController`；`POST /webapi/stamps/ledger/paging`；入参 `AdminStampLedgerPageInDto`（`page`、`userId?`、`reasonKeyword?`）；分页 `log_stamp_transaction`。
- **Manage**：`api.stampLedgerPaging`、`pages/stamps/StampLedgerList.tsx`；侧栏「用户管理 → 邮票流水」；表格分页与筛选。
- **顺带修复**：`FriendshipService`/`Impl` 补 `java.util.List` import；`AppMailboxServiceImpl` 补 `LetterSyncResultVO` import（原编译失败）。
- **验证**：`mvn -pl biz,client -am compile -DskipTests`；`npm run build`（`senior-post-manage`）成功。

## 2026-05-09 — FP-A7-001：bootstrap 返回 VIP 产品配置 + Flutter VIP 中心（planning-with-files）

- **后端**：`AppVipProductConfigVO`；`AppBootstrapVO.vipProduct`；`AppBootstrapService` 批量读 `sys_config` vip 键（与 V9 seed / Manage VipConfig 一致）。
- **Flutter**：`AppVipProductConfig` + `AppBootstrapData.vipProduct`；`vip_center_page` 非 Mock 读 `appBootstrapProvider` 展示文案，`productEnabled=false` 时提示关闭；Mock 仍保留切换按钮。
- **文档**：`doc/plan/01-feature-list.md` FP-A7-001 状态更新。
- **验证**：`mvn -pl biz,client -am compile -DskipTests`；`dart analyze`（上述两文件）无告警。

## 2026-05-09 — 文档与进度一致性治理（planning-with-files）

- **动作**：对照 `client`/`biz`/Flutter/Manage 实现，勘误并统一 **`PLAN.md`**（功能清单、S9、S11）、**`findings.md`** §1/§2.3、**`doc/plan/01-feature-list.md`**（A4-004、A5d-001、A10-002）、**`doc/plan/07-gap-analysis-and-roadmap.md`**（§2.0 对齐表 + 历史 §2 注脚）、**`doc/feature-overview.md`**（资料/赠票/IM/语言/速览）；新增 **`doc/plan/00-documentation-governance.md`**、**`doc/README.md`**；**`task_plan.md`** 增补元信息与导航；**`02`/`03`/`04`/`05`/`06`** 增补元信息；**`doc/1、需求文档.md`** 增加归档定位说明；**`senior-post-api/底层框架能力.md`** 增补元信息。
- **session-catchup.py**：本机路径不可用则跳过（与历史一致）。
- **结论**：功能完成度 **真源** = **`doc/plan/01-feature-list.md` + `05-task-tracker.md`**；路线图读 **`07` §2.0** 再读 §3 波次。

## 2026-05-09 — 功能进度全面梳理 + 持续开发计划（planning-with-files）

- **动作**：对照 `PLAN.md` A1–A10、`doc/plan/01-feature-list.md`、`05-task-tracker.md`、`07-gap-analysis-and-roadmap.md`、`findings.md` 与 `progress.md` 近期交付，产出**未闭环模块清单**与**波次计划**（优先级/时间表/技术方案/资源/验收）；勘误 `01` 中 **FP-A2-002**、**FP-A8-006** 与代码现状不一致处；更新 `task_plan.md` Phase 勾选。
- **结论摘要**：M2 主链路与 M3 信箱/邮票/IM 同步主体已可用；缺口集中在 **VIP 全链**、**合规横切**（邮件 outbox、AES、注销、强更）、**运营工具**（Manage 流水/设备封禁 UI）、**质量与体验债**（Mock 总闸、E2E、B14/B15、A10）。
- **下一步**：按本文用户回复中的「波次 1–4」在 `05` 将下一批 FP 标 `DOING`；`07` §2 中已交付项建议在后续修订中标注「已完成」避免执行歧义。

## 2026-05-09 — Connections 文档口径 + 规划文件扫尾（planning-with-files）

- **动作**：全库文档将 **Connections** 统一为 **IM「好友列表」**（`GET /api/mailbox/friends` / `bu_friendship`），与 TIM **`getConversationList` 会话列表** 解耦；更新 `PLAN.md`、`doc/plan/01-feature-list.md`、`02-requirements.md`、`doc/feature-overview.md`、`findings.md` §4、`e2e-smoke.http`、Mock 仓库注释；`task_plan.md` 决策表已含 2026-05-09 行。
- **验证**：`flutter analyze`：**Analyzing senior-post-flutter... No issues found!**
- **session-catchup.py**：与历史一致，本机路径常不可用则跳过，以 `git diff` + 规划文件为准。

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

## 2026-05-08 — FP-X-005 收口：Flutter 私有图过期自愈（planning-with-files）

- **背景**：后端已有出站换签与 `POST /api/oss/get-sign`；客户端长时间停留后预签名过期会导致 `Image.network` 失败。
- **动作**：新增 `oss_object_key_hint`（从 URL 路径解析 key）、`oss_get_sign_service`、`PostalOssNetworkImage`（首帧失败时单次换签）；`PostalAvatar` 改为 `ConsumerWidget` 以使用 Riverpod；明信片墙/详情配图改用该组件；`AppEnv.ossKeyPrefix`（`--dart-define=OSS_KEY_PREFIX`，默认 `app/uploads`）；`test/oss_object_key_hint_test.dart`。
- **文档**：`task_plan.md` OSS 子阶段 O1–O7 勾选、`05-task-tracker.md` FP-X-005 DONE、`findings.md` §6 更新。
- **验证**：`flutter test test/oss_object_key_hint_test.dart`；`flutter analyze` 全工程无告警。
- **已知**：若后端 `keyPrefix` 非默认，须同步 Flutter `OSS_KEY_PREFIX`；换签仍受 `OssReadAuthorizationService` 约束，越权 key 不会自愈。

## 2026-05-08 — FP-A5d-004 / FP-A6-003 / E2E 冒烟交付（planning-with-files）

- **FP-A5d-004**：`TencentImRestApiClient`（Java 11+ HttpClient）调用腾讯 IM REST：`im_open_login_svc/account_import`、`sns/friend_add`（双向）；`TencentImFriendshipNotifier` 在建联成功后执行；`TencentImProperties` 增加 `friendship-sync-enabled`、`rest-api-host`、`rest-api-identifier`、`rest-api-max-retries` 等；`application.yml` 与环境变量对齐。
- **FP-A6-003**：Flyway **`V10__stamp_daily_grant.sql`**；`StampGrantService` 在 **注册/登录**（`afterLogin`）与 **发帖创建**（`afterPostcardCreated`）触发；`StampAccountService.addBalance`；配置 **`senior-post.stamps-grant.*`**（UTC 日切、发帖日累计邮票上限）。
- **测试**：`TencentImFriendshipNotifierTest`、`StampGrantServiceImplTest`；`biz/pom.xml` 显式 `surefire.skipTests=false` 以便父 POM 跳过测试时仍能跑 biz 单测。
- **E2E**：`senior-post-api/doc/e2e-smoke.http`（注册→发帖→墙分页→管理端审核路径占位→流水）。
- **验证**：`mvn -pl biz -am test "-Dtest=TencentImFriendshipNotifierTest,StampGrantServiceImplTest"` **Tests run: 7, Failures: 0**；`mvn -pl biz,server -am compile -DskipTests` **SUCCESS**。
