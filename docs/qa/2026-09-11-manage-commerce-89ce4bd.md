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
| products/paging | PASS | total=10 |
| products/save（渠道已存在 mock/plus_yearly/sandbox） | FAIL* | 撞 `uk_bu_commerce_product_channel_provider_store_env`（约束预期，非阻塞） |
| products/batch-status | FAIL | code=400；`log_admin_operation.details` 非法 JSON（Token `status`） |
| purchases/paging + token 掩码 | PASS | preview 有值；响应无完整 purchaseToken |
| purchases/detail + timeline | PASS | timelineN=13；token 掩码 |
| purchases/webhook-events | PASS | n=10 |
| purchases/force-sync | FAIL | code=400；`log_admin_operation.details` 非法 JSON（Token `provider`）；购买未变 refund |

\* 同 provider+storeProductId+environment 唯一约束符合设计；应用层宜返回业务码而非 DB 原文。

## 缺陷

### BUG-CM-1 · P1 · `log_admin_operation.details` 写入非 JSON 文本
- **触发**：`POST /webapi/commerce/products/batch-status`、`POST /webapi/commerce/purchases/force-sync`
- **现象**：业务 code=400；Postgres `invalid input syntax for type json`
- **位置**：`AdminOperationMapper.insert` → `details`（jsonb）
- **影响**：商品上下架审计失败；force-sync 失败（只读购买主路径可读，写操作闭环阻断）

## 结论
**未全过**：只读购买（分页/掩码/详情时间线/webhook）PASS；**P1×1** batch-status + force-sync 写 `log_admin_operation.details` 非法 JSON。需开发修复后回归写路径。