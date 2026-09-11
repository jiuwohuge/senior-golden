# QA · §8.6 回归 batch-status / force-sync（`94c0600`）

> 2026-09-11 · `feat/billing-login-push-schedule` @ `94c0600` · API `9011` health UP  
> 相对 `89ce4bd` P1（`log_admin_operation.details` 非法 JSON）修复后回归

## 用例

| 用例 | 结果 | 备注 |
|------|------|------|
| products/batch-status 下架→上架 | FAIL | prodId= off=8500 on=8500 |
| purchases/force-sync | FAIL | purchaseId= status →；非退款 |

## 结论
**未全过**：batch=False force=False