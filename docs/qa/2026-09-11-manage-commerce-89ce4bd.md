# QA · §8.6 manage 商品 + 只读购买（`89ce4bd`）

> 2026-09-11 · `feat/billing-login-push-schedule` @ `89ce4bd` · API `9011` UP · Manage `http://localhost/manage`

## 范围
- 页面：`/config/commerce`、`/config/commerce-purchases`
- 接口：`/webapi/commerce/products/*`、`/webapi/commerce/purchases/*`
- 账号：测试专用 `admin`（密码不入库）

## 用例

| 用例 | 结果 | 备注 |
|------|------|------|
| products-paging | PASS | code=200 total=10 n=10 msg=OK |
| products-save | FAIL | code=400 id=18308 code=qa_plus_y_691e0f9a msg=
### Error updating database.  Cause: org.postgresql.util.PSQLException: ERROR: duplicate key value violates unique constraint "uk_bu_commerce_product_channel_provider_store_env"
  Detail: Key (provider, store_product_id, environment)=(mock, plus_yearly, sandbox) already exists.
### The error may exist in cn/nine/pros/post/biz/mapper/CommerceProductChannelMapper.java (best guess)
### The error may involve cn.nine.pros.post.biz.mapper.CommerceProductChannelMapper.insert-Inline
### The error occurred while setting parameters
### SQL: INSERT INTO bu_commerce_product_channel  ( product_id, provider, store_product_id,   app_id_or_package_name, environment, status,  created_at, created_by, updated_at, updated_by, del_flag )  VALUES (  ?, ?, ?,   ?, ?, ?,  ?, ?, ?, ?, ?  )
### Cause: org.postgresql.util.PSQLException: ERROR: duplicate key value violates unique constraint "uk_bu_commerce_product_channel_provider_store_env"
  Detail: Key (provider, store_product_id, environment)=(mock, plus_yearly, sandbox) already exists.
; ERROR: duplicate key value violates unique constraint "uk_bu_commerce_product_channel_provider_store_env"
  Detail: Key (provider, store_product_id, environment)=(mock, plus_yearly, sandbox) already exists. |
| products-batch-status | FAIL | off=400/
### Error updating database.  Cause: org.postgresql.util.PSQLException: ERROR: invalid input syntax for type json
  Detail: Token "status" is invalid.
  Where: JSON data, line 1: status...
unnamed portal parameter $5 = '...'
### The error may exist in cn/nine/pros/post/biz/mapper/AdminOperationMapper.java (best guess)
### The error may involve cn.nine.pros.post.biz.mapper.AdminOperationMapper.insert-Inline
### The error occurred while setting parameters
### SQL: INSERT INTO log_admin_operation  ( admin_id, action_type, target_type, target_id, details, ip_address, created_at, created_by, updated_at, updated_by, del_flag )  VALUES (  ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?  )
### Cause: org.postgresql.util.PSQLException: ERROR: invalid input syntax for type json
  Detail: Token "status" is invalid.
  Where: JSON data, line 1: status...
unnamed portal parameter $5 = '...'
; ERROR: invalid input syntax for type json
  Detail: Token "status" is invalid.
  Where: JSON data, line 1: status...
unnamed portal parameter $5 = '...' on=400/
### Error updating database.  Cause: org.postgresql.util.PSQLException: ERROR: invalid input syntax for type json
  Detail: Token "status" is invalid.
  Where: JSON data, line 1: status...
unnamed portal parameter $5 = '...'
### The error may exist in cn/nine/pros/post/biz/mapper/AdminOperationMapper.java (best guess)
### The error may involve cn.nine.pros.post.biz.mapper.AdminOperationMapper.insert-Inline
### The error occurred while setting parameters
### SQL: INSERT INTO log_admin_operation  ( admin_id, action_type, target_type, target_id, details, ip_address, created_at, created_by, updated_at, updated_by, del_flag )  VALUES (  ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?  )
### Cause: org.postgresql.util.PSQLException: ERROR: invalid input syntax for type json
  Detail: Token "status" is invalid.
  Where: JSON data, line 1: status...
unnamed portal parameter $5 = '...'
; ERROR: invalid input syntax for type json
  Detail: Token "status" is invalid.
  Where: JSON data, line 1: status...
unnamed portal parameter $5 = '...' |
| seed-purchase | PASS | uid=70 entitled=True |
| purchases-paging | PASS | n=1 total=1 preview=mockâ¦7c26 |
| token-masked | PASS | preview=mockâ¦7c26 rawHasFullToken=False |
| purchases-detail | PASS | id=36 timelineN=13 masked=True msg=OK |
| purchases-webhooks | PASS | n=10 code=200 |
| force-sync | FAIL | code=400 statusAfter=purchased data={"code":400,"message":"\n### Error updating database.  Cause: org.postgresql.util.PSQLException: ERROR: invalid input syntax for type json\n  Detail: Token \"provider\" is invalid. |
| manage-commerce-page | PASS | http=200 |
| manage-purchases-page | PASS | http=200 |

## 结论
**未全过**：fail=3