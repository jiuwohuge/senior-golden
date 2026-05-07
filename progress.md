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
