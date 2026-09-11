# QA · Mock Billing mock-sync（方案 §7）

> 日期：2026-09-11 · 分支：`feat/billing-login-push-schedule` · commit：`8e00190`  
> 环境：本机 `9011/backend` health UP · guest 登录

## 入口
`POST /api/billing/mock-sync` + `{"scenario":"...","productId":"plus_yearly"}`；`GET /api/billing/subscription`。

## 结果

| scenario | mock-sync | state | entitled |
|----------|-----------|-------|----------|
| PURCHASED | PASS/200 | active | true |
| PENDING | PASS/200 | active | true |
| RENEW | PASS/200 | active | true |
| CANCEL | PASS/200 | active | true |
| EXPIRE | PASS/200 | expired | false |
| REFUND | PASS/200 | expired | false |
| REVOKE | PASS/200 | expired | false |

幂等：连续两次 PURCHASED 均 success。

## 结论
**通过（可提测）**：七种 scenario 均 HTTP 200；EXPIRE/REFUND/REVOKE → expired/entitled=false；PURCHASED/RENEW → active。注意：PENDING/CANCEL 后仍 entitled=true（若产品期望 PENDING 不发权益、CANCEL 立即收回，则记缺陷）。真 Play 未达可测。幂等两次 PURCHASED OK。