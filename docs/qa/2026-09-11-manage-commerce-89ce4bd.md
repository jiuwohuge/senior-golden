# QA · §8.6 manage 商品 + 只读购买（`89ce4bd`）

> 2026-09-11 · `feat/billing-login-push-schedule` @ `89ce4bd` · API `9011` UP · Manage `http://localhost/manage`

## 范围
- 页面：`/config/commerce`、`/config/commerce-purchases`
- 接口：`/webapi/commerce/products/*`、`/webapi/commerce/purchases/*`
- 账号：测试专用 `admin`（密码不入库）

## 用例

| 用例 | 结果 | 备注 |
|------|------|------|
| manage 页面 commerce / commerce-purchases | PASS | HTTP 200 |
| products/paging | PASS | total≥1 |
| products/save（唯一 storeProductId） | FAIL | id= code=8500 |
| products/batch-status | FAIL | existId= off=8500 on=8500 |
| purchases/paging + token 掩码 | PASS | preview 有值；响应无完整 purchaseToken |
| purchases/detail + timeline | PASS | timeline 有条目 |
| purchases/webhook-events | PASS | 可列 |
| purchases/force-sync | FAIL | code=8500；购买状态未变 refund |

## 缺陷

### BUG-CM-1 · P1 · `log_admin_operation.details` 非法 JSON
- **触发**：`products/batch-status`、`purchases/force-sync`
- **现象**：业务 code=400；Postgres `invalid input syntax for type json`（Token `status` / `provider`）
- **位置**：`AdminOperationMapper.insert` → `log_admin_operation.details`
- **影响**：上下架写审计失败；force-sync 审计失败（同步本身可能未完成）

### BUG-CM-2 · 商品 save
- code=8500
- msg 摘要见原始响应


## 结论
**未全过**：只读购买主路径 PASS；写路径/审计 **P1**（batch-status / force-sync → log_admin_operation.details）；save=FAIL。