# QA · RTDN Mock 回归（`6f571e2`）

> 2026-09-11 · `feat/billing-login-push-schedule` @ `6f571e2` · 本机 `9011` health UP  
> 相对 `d947461` 幂等读 `payload_json` String←Object 修复后回归

## 步骤
1. guest → `mock-sync` PURCHASED  
2. `mock-rtdn`：RENEW / CANCEL / EXPIRE / REFUND  
3. 同 `messageId` 连续 3 次 RENEWED（期望均 success，webhook 仅 1 行）

## 结果

| 场景 | notificationType | mock-rtdn | state | entitled | 期望 | 结果 |
|------|------------------|-----------|-------|----------|------|------|
| RENEW | SUBSCRIPTION_RENEWED | True/200 | active | True | True | PASS |
| CANCEL | SUBSCRIPTION_CANCELED | True/200 | active | True | True | PASS |
| EXPIRE | SUBSCRIPTION_EXPIRED | True/200 | expired | False | False | PASS |
| REFUND | SUBSCRIPTION_REFUND | True/200 | expired | False | False | PASS |
| 幂等 | 同 messageId ×3 | r=200/200/200 rows=1 | - | - | 均 success + 1 row | PASS |

## 结论
**通过**：`6f571e2` 回归 PASS — RENEW/CANCEL/EXPIRE/REFUND + 同 messageId ×3 幂等（webhook 仅 1 行）；缺陷 0。