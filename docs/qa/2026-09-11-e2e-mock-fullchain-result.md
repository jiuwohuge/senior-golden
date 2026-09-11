# QA · §8.8 模拟全链路验收（`d5c0f2d`）

> 2026-09-11 · `feat/billing-login-push-schedule` @ `d5c0f2d` · API `9011` health UP  
> 跑手：`docs/qa/scripts/e2e-mock-fullchain.ps1`（清单 `docs/qa/2026-09-11-e2e-mock-fullchain.md`）  
> 真 Google / Play IAP / Pub/Sub RTDN / 真 FCM：**SKIP**

## 结果摘要

| 指标 | 值 |
|------|----|
| PASS | **50** |
| FAIL | **0** |
| SKIP | **5**（webhook retry 占位；多实例仅单容器；真 Play/RTDN/FCM） |
| Exit | 0 · `RESULT: PASS` |

## 覆盖块
- A 环境 / mock 门禁
- B mock-sync 生命周期（PENDING/PURCHASED/RENEW/CANCEL/EXPIRE/REFUND + PENDING 清权益）
- C mock-rtdn（RENEW/CANCEL/EXPIRE/REFUND + messageId×3 幂等）
- D 异常恢复 PENDING→PURCHASED；Scheduled 单入口；Redis NX 锁冒烟
- E FCM mock enqueue + 支付类拒推
- F manage 只读购买 / force-sync / products batch-status

## 脚本修补
- `e2e-mock-fullchain.ps1`：`24020` → ``（PowerShell 只读自动变量，避免误用进程 ID）

## 结论
**通过**：§8.8 Mock 全链路验收 PASS=50 FAIL=0；缺陷 0（业务）。真商店/真推送/真登录按方案 SKIP。