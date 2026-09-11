# QA · 模拟全链路验收（Mock E2E Full Chain）

> **日期**：2026-09-11（Asia/Shanghai）  
> **分支**：`feat/billing-login-push-schedule`  
> **对应方案**：`docs/product/支付登录推送与定时任务方案.md` §8 第 8 项（测试渠道 / 回调重放 / 多实例 / 异常恢复 / 全链路）  
> **口径**：仅 Mock；**不测**真实 Google Play / sandbox RTDN Pub/Sub / 真 FCM / Google 登录  
> **API**：`http://127.0.0.1:9011/backend`（health UP）  
> **前置**：`BILLING_MOCK_ENABLED=true`、`PUSH_MOCK_ENABLED=true`，活跃 profile **非** `prod`/`production`

## 0. 与既有文档关系

本包把下列分散报告收成 **一份清单 + 一个脚本**，避免重复手工跑：

| 既有文档 | 本包覆盖 |
|----------|----------|
| `2026-09-11-mock-billing-sync.md` | §1 mock-sync 生命周期 |
| `2026-09-11-mock-rtdn.md` + `regression-mock-rtdn-6f571e2.md` | §2 RTDN + 幂等 |
| `2026-09-11-regression-pending-5aef74d.md` | PENDING 清权益 / PENDING→PURCHASED |
| `2026-09-11-fcm-outbox-91ba968.md` | §5 信件推送 + 支付禁令 |
| `2026-09-11-manage-commerce-89ce4bd.md` + `regression-commerce-94c0600.md` | §6 只读购买 / batch-status / force-sync |
| `2026-09-11-full-acceptance.md` | 不全量重跑；本包只补支付+推送 Mock 全链路 |

**一键执行**：`docs/qa/scripts/e2e-mock-fullchain.ps1`（逐步 PASS/FAIL；失败 exit ≠ 0）。

```powershell
# 仓库根目录
$env:BASE_URL = "http://127.0.0.1:9011/backend"   # 可省略，脚本默认即此
# 可选：管理端用例（密码不入库，仅本机环境变量）
$env:ADMIN_USER = "admin"
$env:ADMIN_PASSWORD = "<本机测试密码>"
powershell -NoProfile -ExecutionPolicy Bypass -File .\docs\qa\scripts\e2e-mock-fullchain.ps1
```

---

## 1. 有序检查清单

### A. 环境

| ID | 步骤 | 端点 | 期望 | Skip 原因 |
|----|------|------|------|-----------|
| A01 | Health | `GET /actuator/health` | `status=UP` | — |
| A02 | Mock 开关探活 | 首次 `POST /api/billing/mock-sync` scenario=`PENDING` | HTTP/业务 200；非 `mockDisabled` | 真 Play 未接：本机必须开 billing mock |

### B. 购买生命周期（mock-sync）

统一：`POST /api/billing/mock-sync` + body `{"scenario","productId":"plus_yearly","purchaseToken"}`；校验 `GET /api/billing/subscription` 的 `state` / `entitled`。  
**同一 `purchaseToken` 可推进场景**（token 内嵌场景被 body.scenario 覆盖）。

| ID | scenario | 期望 state | 期望 entitled | 备注 |
|----|----------|------------|---------------|------|
| B01 | `PENDING`（新 token） | `none`（或非 active） | **false** | PENDING 不授权 |
| B02 | `PURCHASED` | `active` | **true** | 立即授权 |
| B03 | `PURCHASED`→`PENDING` | expired/none | **false** | 硬清权益（回归 `5aef74d`） |
| B04 | `RENEW` | `active` | **true** | 续期 |
| B05 | `CANCEL` | `active` | **true** | 取消自动续期，当前周期仍有权益 |
| B06 | `EXPIRE` | `expired` | **false** | 过期收回 |
| B07 | `REFUND`（先 PURCHASED） | `expired` | **false** | 退款收回 |
| B08 | `REVOKE`（可选） | `expired` | **false** | 与 REFUND 同类 |

**真 Play / sandbox 购买校验**：SKIP（本环境无 Google Play Developer API / 真机 IAP）。

### C. RTDN 回放（mock-rtdn）

> 脚本对 RENEW→CANCEL→EXPIRE 使用**同一 purchaseToken**（避免同用户残留 active 订阅掩盖 EXPIRE）；REFUND / 幂等另开 token。整段 RTDN 使用独立 guest。

前置：guest → `mock-sync` PURCHASED（记下/传入同一 `purchaseToken`）。  
`POST /api/billing/mock-rtdn`：`messageId` + `purchaseToken` + `notificationType`（+ 可选 `productId`）。

| ID | notificationType | 期望 entitled | 期望 state |
|----|------------------|---------------|------------|
| C01 | `SUBSCRIPTION_RENEWED` | true | active |
| C02 | `SUBSCRIPTION_CANCELED` | true | active |
| C03 | `SUBSCRIPTION_EXPIRED` | false | expired |
| C04 | `SUBSCRIPTION_REFUND` | false | expired |
| C05 | 同 `messageId` ×3 `SUBSCRIPTION_RENEWED` | 均 success | 幂等；webhook 仅 1 行（查库可选） |

**真 Pub/Sub RTDN**：SKIP。

### D. 异常恢复

| ID | 步骤 | 端点 / 动作 | 期望 | Skip |
|----|------|-------------|------|------|
| D01 | PENDING→PURCHASED | 同 token 连续 `mock-sync` | entitled false→**true** | — |
| D02 | force-sync | `POST /webapi/commerce/purchases/force-sync` `{"purchaseId"}` | success；`synced` 视 cipher；**不退款** | 无 `ADMIN_PASSWORD` 则 SKIP |
| D03 | webhook failed→retry | `BillingEventRetryJob` | — | **SKIP**：job 现为 no-op 占位；本地用再次 `mock-rtdn` / force-sync 恢复 |
| D04 | `@Scheduled` 单入口 | 源码扫描 | 仅 `ScheduledTaskEntrypoints.java` 含 `@Scheduled` | 脚本旁无源码则 SKIP |
| D05 | Redis 锁烟雾 | Redis `SET schedule:lock:* NX EX` | 第二次 NX 失败 | 无 docker/redis 则 SKIP |
| D06 | 真多实例 | 双 API 容器 | 同批不双跑 | **SKIP**：本机仅 1 个 `senior-post-api`；多实例靠 `DistributedJobLock`（`schedule:lock:{job}`） |

### E. FCM Outbox（信件）+ 支付禁令

| ID | 步骤 | 端点 | 期望 |
|----|------|------|------|
| E01 | 注册 Token | `POST /api/device/push-token`（header `equipmentId`） | code=200 |
| E02 | 在途推送 | `POST /api/push/mock-enqueue` `letter_matched_in_transit` `triggerJob=true` | outbox + delivery `mock_sent` / provider=`mock` |
| E03 | 到达推送 | 同上 `letter_arrived` | 同上 |
| E04 | 支付类禁入 | `eventType=purchase_success\|refund\|subscription_*\|billing_event` | **业务失败**（常见 code=`4501`，`success=false`；HTTP 可能仍 200） |

**真 FCM**：SKIP（`MockFcmSender`，且仅 mock-allowed）。

### F. Manage 只读购买 + batch-status（已合入，可选）

需 `ADMIN_PASSWORD`（测试账号 `admin`，**密码不入库**）。

| ID | 步骤 | 端点 | 期望 |
|----|------|------|------|
| F01 | 登录 | `POST /webapi/auth/login` | token |
| F02 | 购买分页 | `POST /webapi/commerce/purchases/paging` | success；token 掩码 |
| F03 | force-sync | `POST /webapi/commerce/purchases/force-sync` | success（回归 `94c0600`） |
| F04 | 商品分页 | `POST /webapi/commerce/products/paging` | success |
| F05 | batch-status | `POST /webapi/commerce/products/batch-status` 切换再还原 | success |

---

## 2. 权益速查（Mock）

| 场景 | entitled | 说明 |
|------|----------|------|
| PENDING | false | 只落库不授权 |
| PURCHASED / RENEW / CANCEL | true | CANCEL 保留当前周期 |
| EXPIRE / REFUND / REVOKE | false | 收回权益 |
| 同 messageId 重放 | 不变 | 幂等成功，不重复记流水 |

---

## 3. 明确 SKIP（真渠道）

1. Google Play 真机 IAP / Developer API 校验与 acknowledge  
2. 真 RTDN Cloud Pub/Sub  
3. 真 FCM 凭证发送  
4. Google 登录真 JWT（另有 oauth mock，不在本包）  
5. 多 API 节点并发抢锁（单容器环境）

---

## 4. @测试 一句话

@测试 模拟全链路已收口：跑 `docs/qa/scripts/e2e-mock-fullchain.ps1` 即可覆盖 mock 购买生命周期 + RTDN 幂等 + PENDING 恢复 + 推送禁支付 +（可选）manage 只读/force-sync/batch-status，无需真 Google。

