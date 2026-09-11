# QA · §8.6 回归 batch-status / force-sync（`94c0600`）

> 2026-09-11 · `feat/billing-login-push-schedule` @ `94c0600` · API `9011` health UP  
> 相对 `89ce4bd` P1（`log_admin_operation.details` 非法 JSON）修复后回归

## 用例

| 用例 | 结果 | 备注 |
|------|------|------|
| products/batch-status 下架→上架 | PASS | prodId=5 off=200 on=200 |
| purchases/force-sync | PASS | purchaseId=38 status purchased→purchased；非退款 |

## 结论
**通过**：`94c0600` 回归 PASS — `batch-status` + `force-sync`；缺陷 0。