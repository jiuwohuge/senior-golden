# 回归 · PENDING entitled=false（`ef664ee`）

> 2026-09-11 · `feat/billing-login-push-schedule` · `ef664ee`

| 用例 | 期望 | 实际 | 结果 |
|------|------|------|------|
| 仅 PENDING | entitled=false | state=none entitled=False | PASS |
| PURCHASED→PENDING | 先 true 后 false | True→True | FAIL |
| PURCHASED→CANCEL | 仍 entitled | state=active entitled=True | PASS |

结论：**未通过**。