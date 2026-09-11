# 回归 · PENDING 硬清权益 `5aef74d`:

> 2026-09-11 · `feat/billing-login-push-schedule` · `5aef74d` · jar 热换 UP

| 用例 | 期望 | 实际 | 结果 |
|------|------|------|------|
| 仅 PENDING | entitled=false | state=none entitled=False | PASS |
| PURCHASED→PENDING | true→false | True→False (expired) | PASS |
| PURCHASED→CANCEL | 仍 entitled | state=active entitled=True | PASS |

结论：**通过**，缺陷 0。
