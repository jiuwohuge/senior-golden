# 05 — 功能开发任务跟踪表

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
| FP-A6-004 | AI + Owner | S1 | W1D2 | W1D3 | TODO | 并发压测 100 次无负余额 | `StampAccountService` 单测 |
| FP-A5-001 | AI + Owner | S1 | W1D2 | W1D4 | TODO | 双用户各见 postal/sync 正确 | `AppMailboxApi` 扩展 + `LetterService` |
| FP-A3-001 | AI + Owner | S1 | W1D3 | W1D4 | TODO | 未审帖不在 App 列表 | `AppPostcardApi` + Mapper SQL |
| FP-A3-002 | AI + Owner | S1 | W1D4 | W1D4 | TODO | 未审详情不可见 | 同上 |
| FP-A3-003 | AI + Owner | S1 | W1D4 | W1D5 | TODO | 后台待审队列有记录 | create + 可选 OSS URL |
| FP-A3-004 | AI + Owner | S1 | W1D5 | W1D6 | TODO | 评论待审 | comment API |
| FP-A2-001 | AI + Owner | S1 | W1D5 | W1D6 | TODO | `me` 与编辑后一致 | profile update API |
| FP-A4-001 | AI + Owner | S1 | W1D6 | W1D7 | TODO | 分页 total 正确 | directory API |

---

## Sprint 2（P0 Flutter + 联调）

| FP | 负责人 | Sprint | 起 | 止 | 状态 | 验收标准 | 交付物 |
|----|--------|--------|----|----|------|----------|--------|
| 总闸 Mock | AI + Owner | S2 | W2D1 | W2D1 | TODO | `USE_MOCK=false` 主路径可演示 | `app_env` 文档 + 默认策略决策 |
| FP-A3-* UI | AI + Owner | S2 | W2D1 | W2D4 | TODO | Tab1 全真数据 | `post_wall` 等改 Repository |
| FP-A5-* UI | AI + Owner | S2 | W2D2 | W2D4 | TODO | 发信后列表刷新 | `mailbox_providers` + sheet |
| FP-A2/A4 UI | AI + Owner | S2 | W2D4 | W2D5 | TODO | 编辑保存成功 | profile/directory |
| E2E 冒烟 | AI + Owner | S2 | W2D5 | W2D5 | TODO | 脚本或录屏通过 | `doc/plan/` 或 `tests/` 记录 |

---

## Sprint 3（P1）

| FP | 负责人 | Sprint | 起 | 止 | 状态 | 验收标准 | 交付物 |
|----|--------|--------|----|----|------|----------|--------|
| FP-A5d-002 | AI + Owner | S3 | W3D1 | W3D3 | TODO | 平邮到期自动送达 | Redis + Worker + 单测 |
| FP-A5-005 | AI + Owner | S3 | W3D2 | W3D3 | TODO | 扣邮票后变已送达 | speed-up API |
| FP-A5d-004 | AI + Owner | S3 | W3D3 | W3D4 | TODO | 腾讯返回成功或可观测失败 | Notifier 实现 + 配置 |
| FP-A6-002/003 | AI + Owner | S3 | W3D4 | W3D5 | TODO | 流水页与管理配置一致 | API + Flutter 页 |
| FP-A7-* | AI + Owner | S3 | W3D4 | W3D6 | TODO | VIP 开关影响扣费 | VO + Flutter |
| FP-A3-005 | AI + Owner | S3 | W3D5 | W3D5 | TODO | 举报单进后台 | App POST + UI |
| FP-A4-002~004 | AI + Owner | S3 | W3D5 | W3D6 | TODO | 筛选排序生效 | Query + UI |

---

## Sprint 4（P2/P3）

| FP | 负责人 | Sprint | 起 | 止 | 状态 | 验收标准 | 交付物 |
|----|--------|--------|----|----|------|----------|--------|
| FP-X-001 | AI + Owner | S4 | W4D1 | W4D3 | TODO | 本地收到测试邮件 | EmailService + 表 |
| FP-A1-003 | AI + Owner | S4 | W4D2 | W4D3 | TODO | 重置后可用新密码登录 | Auth API + 邮件模板 |
| FP-A1-007 | AI + Owner | S4 | W4D3 | W4D5 | TODO | 加解密与后端互通 | Flutter 拦截器 + 配置说明 |
| FP-A8-005 | AI + Owner | S4 | W4D4 | W4D5 | TODO | 注销策略可演示 | API + Job + Flutter |
| FP-X-003 | AI + Owner | S4 | W4D5 | W4D5 | TODO | 低版本拦截 | bootstrap 或 version API |
| FP-A9-002/003 | AI + Owner | S4 | W4D5 | W4D6 | TODO | 管理端可操作 | Manage 页面 PR |
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
