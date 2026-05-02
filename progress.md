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
