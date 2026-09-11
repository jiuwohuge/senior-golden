# QA · RTDN Mock 回归（`d947461`）

> 2026-09-11 · `feat/billing-login-push-schedule` @ `d947461` · 本机 `9011` health UP  
> 相对 `fca9573` P1（`payload_json` jsonb）修复后回归

## 步骤
1. guest → `mock-sync` PURCHASED（自动 token）  
2. `mock-rtdn` 回放 RENEW / CANCEL / EXPIRE / REFUND  
3. 同 `messageId` 再打两次 RENEW 验幂等

## 结果

| 场景 | notificationType | mock-rtdn | state | entitled | 期望 | 结果 |
|------|------------------|-----------|-------|----------|------|------|
| RENEW | SUBSCRIPTION_RENEWED | True/200 | active | True | True | PASS |
| CANCEL | SUBSCRIPTION_CANCELED | True/200 | active | True | True | PASS |
| EXPIRE | SUBSCRIPTION_EXPIRED | True/200 | expired | False | False | PASS |
| REFUND | SUBSCRIPTION_REFUND | True/200 | expired | False | False | PASS |
| 幂等 | 同 messageId ×2 RENEWED | both=False | - | - | 均 success | FAIL |

## 结论
**未全过**：fail=0 idem=False