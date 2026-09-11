# QA · RTDN Mock 回归（`d947461`）

> 2026-09-11 · `feat/billing-login-push-schedule` @ `d947461` · 本机 `9011` health UP  
> 相对 `fca9573` P1（`payload_json` jsonb）修复后回归

## 步骤
1. guest → `mock-sync` PURCHASED（自动 token）  
2. `mock-rtdn` 回放 RENEW / CANCEL / EXPIRE / REFUND  
3. 同 `messageId` 连续 3 次 RENEWED 验幂等

## 结果

| 场景 | notificationType | mock-rtdn | state | entitled | 期望 | 结果 |
|------|------------------|-----------|-------|----------|------|------|
| RENEW | SUBSCRIPTION_RENEWED | True/200 | active | True | True | PASS |
| CANCEL | SUBSCRIPTION_CANCELED | True/200 | active | True | True | PASS |
| EXPIRE | SUBSCRIPTION_EXPIRED | True/200 | expired | False | False | PASS |
| REFUND | SUBSCRIPTION_REFUND | True/200 | expired | False | False | PASS |
| 幂等 | 同 messageId ×3 RENEWED | False (c=200/400/400) | - | - | 均 success | FAIL |

## 结论
**部分通过**：四场景 PASS；幂等 FAIL（r1=200 r2=400 r3=400 msg=
### Error querying database.  Cause: org.apache.ibatis.executor.result.ResultMapException: Error attempting to get column 'payload_json' from result set.  Cause: java.lang.RuntimeException: com.fasterxml.jackson.databind.exc.MismatchedInputException: Cannot deserialize value of type `java.lang.String` from Object value (token `JsonToken.START_OBJECT`)
 at [Source: (String)"{"messageId": "msg-idem-only-729491fc0c8e4fee907f229f1804ff32", "productId": "plus_yearly", "purchaseToken": "mock:plus_yearly:PURCHASED:b71dd7a2ab1c40e39f423505ae080f5d", "notificationType": "SUBSCRIPTION_RENEWED"}"; line: 1, column: 1]
### The error may exist in cn/nine/pros/post/biz/mapper/PaymentWebhookEventMapper.java (best guess)
### The error may involve cn.nine.pros.post.biz.mapper.PaymentWebhookEventMapper.selectList
### The error occurred while handling results
### SQL: SELECT  id,provider,event_id_or_message_id,event_type,payload_json,process_status,retry_count,error_message,received_at,processed_at,created_at,created_by,updated_at,updated_by,del_flag  FROM bu_payment_webhook_event  WHERE del_flag=false     AND (provider = ? AND event_id_or_message_id = ? AND del_flag = ?) LIMIT 1
### Cause: org.apache.ibatis.executor.result.ResultMapException: Error attempting to get column 'payload_json' from result set.  Cause: java.lang.RuntimeException: com.fasterxml.jackson.databind.exc.MismatchedInputException: Cannot deserialize value of type `java.lang.String` from Object value (token `JsonToken.START_OBJECT`)
 at [Source: (String)"{"messageId": "msg-idem-only-729491fc0c8e4fee907f229f1804ff32", "productId": "plus_yearly", "purchaseToken": "mock:plus_yearly:PURCHASED:b71dd7a2ab1c40e39f423505ae080f5d", "notificationType": "SUBSCRIPTION_RENEWED"}"; line: 1, column: 1]）。