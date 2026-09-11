# 本机验收报告 · ae52411

> **日期**：2026-09-11 · **环境**：DESKTOP-1PS37OS 本机 Docker  
> **分支**：`feat/play-billing-v1` · **commit**：`ae52411e948a9ecec2e13e7db5073589658a4ed8`  
> **API**：`http://127.0.0.1:9011/backend`（health UP，Flyway V19）  
> **Web**：`http://127.0.0.1:8088`（200，已指上述 API）  
> **口径**：大管家最终验收（真 Play / 推送 / Google 登录 / 真实邮件 **本轮不测**，标未达可测）

## 1. 结论

**本轮可汇总：P0 必测项通过；无阻塞。**  
真链路四项未测。慢信/时光信「送达」使用本机 SQL harness（等价后台 force-deliver），非生产调度器自然到达。

## 2. 用例表

| 编号 | 用例 | 结果 | 备注 |
|------|------|------|------|
| E01 | API health / Web 探活 | 通过 | UP / 200 |
| E02 | Guest 静默进 + /me | 通过 | |
| E03 | 邮局 home + 日额度领取 | 通过 | |
| E04 | 未订可写信（POST_OFFICE/DIRECT） | 通过 | 主路径不锁 |
| E05 | 在途列表可读；在途正文隐藏 | 通过 | contentHidden=true |
| E06 | 强制送达后拆封可读 + 回信 | 通过 | SQL status=2 DELIVERED |
| E07 | 信箱 sent / received / postal | 通过 | |
| E08 | 订阅 test-override none/trial/active/expired + restore | 通过 | 前期矩阵 |
| E09 | AI 周免费 3 次，第 4 次 400303 | 通过 | 订后配额 100 |
| E10 | 在途撤回/改信：未订/过期 400302；订后窗口内可 | 通过 | |
| E11 | 过期后仍可写信 | 通过 | |
| E12 | 时光信封缄（deliveryDate≥明天） | 通过 | 当天日期拒绝 4501（预期） |
| E13 | 时光信拆封（送达后 open→READ） | 通过 | SQL status=3 DELIVERED |
| E14 | 时光信 24h 内取消 | 通过 | |
| E15 | 拉黑 / 列表 / 取消拉黑 | 通过 | /api/social/blocks |
| E16 | 举报 targetType=user | 通过 | /api/reports |
| E17 | 举报 postcard/comment | 跳过 | 无对应业务对象数据 |
| E18 | 信件草稿保存 | 通过 | /api/letter-drafts/save |
| E19 | 资料 PATCH | 通过 | |
| E20 | 真 Play IAP | 跳过 | 未达可测 |
| E21 | 消息推送 | 跳过 | 未达可测 |
| E22 | Google 登录 | 跳过 | 未达可测 |
| E23 | 真实邮件发送 | 跳过 | 未达可测 |

## 3. 缺陷列表

| 级别 | 标题 | 说明 |
|------|------|------|
| P2 | 敏感词偶发误伤 | 前期用例触发 4501；换正常英文正文后通过。记回归词库 |
| 备注 | 管理后台登录 | 已作废：见 §7 补测通过 |
| 备注 | recallWindowMinutes | 未订时 VO 仍回 20；闸门以 canRecallEdit / 400302 为准，行为正确 |

## 4. 未测项（口径内四项真链路）

1. 真实 Google Play 支付闭环  
2. 消息推送  
3. Google 登录  
4. 真实邮件发送  

## 5. 对齐验收矩阵

- 核心慢信端到端：通过（送达 harness）  
- 时光信封缄/拆封：通过（送达 harness）  
- 举报/拉黑：拉黑完整通过；举报 user 通过  
- 订阅/AI/在途撤回：通过  
- 真 Play 等：未测（未达可测）

## 6. 签署

- 测试执行：测试（本机 API harness + Web 探活）  
- 待 @产品 扫报告对齐后群内认可  
## 7. 补测 · 管理后台（2026-09-11 续 · 待合入）

| 编号 | 用例 | 结果 | 备注 |
|------|------|------|------|
| E24 | 管理后台登录 `http://localhost/manage/login` + `/webapi/auth/login` | 通过 | 使用测试账号 `admin`（密码不入库） |
| E25 | `/webapi/letter-audit/{id}/force-deliver` | 通过 | 送达后收件方可读；可替代 SQL harness |

> 凭据不入库。上一版「admin 登录失败」备注作废。本段因阶段闭环，**本地已改、尚未 push**（等大管家/九爷允推）。