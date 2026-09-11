# 全量可测验收报告（重开）

> **日期**：2026-09-11 · **触发**：九爷驳回「可交付」简陋口径后重开  
> **环境**：DESKTOP-1PS37OS · API `http://127.0.0.1:9011/backend` · Web `http://127.0.0.1:8088` · Manage `http://localhost/manage/login`  
> **分支**：`feat/play-billing-v1` · **基线 commit（开测时）**：`64642885f44ad26766190ebd521b7c23ebd2c10d`  
> **证据目录**：`docs/qa/evidence-2026-09-11-full/`（cases.json / 截图 / dashboard-summary.json）  
> **管理后台账号**：使用测试账号 `admin`（**密码不入库**）

## 1. 结论

**本轮全量可测项：主路径通过；发现 2 个缺陷（见 §3）。**  
慢信已用**实质正文** + **管理后台 `force-deliver`** 完成真实拆封/回信（非裸 SQL 假装）。时光信拆封在无后台 force 接口时曾 SQL 辅助送达（已标明）。  
仍按口径跳过：真 Play 支付 / 真推送 / Google 登录 / 真邮件。

汇总：PASS 为主；WARN/缺陷见下。待 @产品 认可后由大管家报九爷。

## 2. 用例表（细）

| ID | 模块 | 步骤 | 期望 | 实际 | 结果 | 证据 |
|----|------|------|------|------|------|------|
| ENV01 | 环境 | GET `/actuator/health` | UP | UP | PASS | cases.json |
| ENV02 | 环境 | GET Web `:8088` | 200 | 200 | PASS | |
| ENV03 | 环境 | GET manage login | 200 | 200 | PASS | `manage-login.png` / `ui-01.png` |
| ADM01 | 管理后台 | webapi 登录（测试账号 admin） | 成功+token | 成功 | PASS | 凭据不入库 |
| ADM02 | 后台-公告 | `/webapi/announcement/paging` | success | success | PASS | API |
| ADM03 | 后台-反馈 | `/webapi/feedback/paging` | success | success | PASS | API |
| ADM04 | 后台-敏感词 | `/webapi/sensitive-word/paging` | success | PASS | PASS | API |
| ADM05 | 后台-用户 | `/webapi/user/paging` | success | success | PASS | API |
| ADM06 | 后台-信件 | `/webapi/letter-audit/paging` | success | success | PASS | API |
| ADM07 | 后台-版本 | `/webapi/version/paging` | success | success | PASS | API |
| ADM08 | 后台-看板 | `/webapi/dashboard/summary` | success | success | PASS | `dashboard-summary.json` |
| ADM09 | 后台-公告 | 保存公告 | success | success | PASS | title=QA Full Announcement |
| ADM10 | 后台-敏感词 | 保存测试词 `qabadwordxyz` | success | success | PASS | |
| APP01 | 认证 | Guest 创建 A/B | 成功 | 成功 | PASS | |
| APP02 | 启动 | `/api/bootstrap/init` | success | success | PASS | |
| APP03 | 更新公告 | `/api/bootstrap/release-note` | success | success+有 data | PASS | |
| APP04 | 日额度 | home 查看 dailyLetterQuota | 有额度 | quota=5 | PASS | fix-log |
| MAIL01 | 慢信 | A→B 实质长信 DIRECT | success | letterId 有 | PASS | 正文 >200 字 |
| MAIL02 | 慢信 | B 在途读信 | 正文隐藏 | contentHidden=true | PASS | |
| MAIL03 | 慢信/后台 | admin force-deliver | success | success | PASS | webapi |
| MAIL04 | 慢信 | B 拆封 | 可读实质正文 | len=277 status=DELIVERED | PASS | |
| MAIL05 | 慢信 | B 实质回信 | success | replyId 有 | PASS | |
| REL01 | 关系 | relation snapshot | success | success | PASS | |
| REL02 | 关系 | 多轮通信后发起笔友申请 | success | success requestId=1 | PASS | 少信时会 4501（产品规则） |
| REL03 | 关系 | B 同意笔友 + friends | success | friends count=1 | PASS | fix-log |
| MOD01 | 敏感词 | 发送含 `qabadwordxyz` | 拦截 | 400 not allowed | PASS | |
| QUO01 | 日额度 | 发满日额度后再发 | 拒绝 | `Daily letter quota exhausted.` | PASS | 发 5 封后第 6 封 |
| FB01 | 反馈 | App 提交反馈 | success | success | PASS | |
| FB02 | 反馈/后台 | 后台 paging 可见记录 | records 含刚提交 | records 可见；total 字段异常为 0 | WARN | 见缺陷 D2 |
| SOC01 | 拉黑 | block/list/unblock | success | success | PASS | |
| SOC02 | 举报 | report user | success | success | PASS | |
| TL01 | 时光信 | 封缄实质正文（明天） | success | id 有 | PASS | |
| TL02 | 时光信 | 送达 | 可拆封 | 无 admin force，SQL status=3 辅助 | WARN | 见缺陷 D3 |
| TL03 | 时光信 | open 拆封 | success+正文 | status=READ | PASS | |
| SUB01 | 订阅 | test-override active | entitled | true | PASS | harness |
| SKIP* | 真链路 | Play/推送/Google/邮件 | 跳过 | 跳过 | SKIP | 口径 |

### 管理后台 UI 说明
无登录态的 headless 访问 SPA 子路由会落在登录页（截图 `ui-01`～`ui-08` 同貌）。**菜单能力以 webapi 点测为准**；登录页截图见 `manage-login.png`。

## 3. 缺陷列表

| ID | 级别 | 模块 | 描述 | 建议 |
|----|------|------|------|------|
| D1 | P1 | 管理后台-用户额度 | `POST /webapi/user/{id}/quota/adjust` 失败：`log_admin_operation.details` jsonb 与 varchar 类型不匹配 | @开发 修 MyBatis/SQL cast |
| D2 | P3 | 管理后台-反馈分页 | paging 返回 `records` 有数据但 `total=0` | @开发 核对分页 total 赋值 |
| D3 | P3 | 时光信 | 无管理端 force-deliver；本轮拆封依赖 SQL 置 `status=3` | @开发 补后台调试接口或文档化调度入口；@产品 是否要求必须后台可达 |

## 4. 未测（口径）

真 Play 支付、真推送、Google 登录、真邮件发送。

## 5. 签署

- 测试：全量可测重跑完成  
- 待 @产品 对齐认可  
- 大管家汇总九爷「可交付」前需产品一句认可  