# 写信桌改版设计

日期：2026-08-20  
状态：已与用户对齐（方案 1 + 骨架 + 规则 + 数据流）  
范围：`senior-post-flutter` 写信页 + `senior-post-api` 话题字段与发信契约

## 1. 目标

把现有单页写信桌做成「书桌上的一封信」：45+ 用户一眼知道自己在写信、写完能寄出；视觉是邮局纸感，不是三个等高按钮的表单。

成功标准：

1. 打开写信页，主行动只有一颗通栏按钮（投进邮局 / 封缄寄出 / 寄出这封信）。
2. 信纸占满中间；话题是可贴可揭的邮票，不贴也能寄。
3. 键盘弹起时主按钮仍在键盘上方；邮票条收成「已贴：…」。
4. 寄出时可选 `topicTagId` 写入 `bu_letter.topic_tag_id`；不选则为空。
5. 适老化不破：正文 ≥17pt、触控 ≥48dp、图标带文字、一屏一主张。

## 2. 非目标

- 不改匹配算法（话题本轮只入库，不参与排序）。
- 不做「兴趣交流」二级领域。
- 不回到多步向导，不做「先折信封再翻开写」。
- 不把写信桌做成日记 / 笔记 App。
- 不改投递成功 overlay、封缄滑块交互本身（只改它们从哪进来）。
- 不在本轮改首页分流、信箱、设置。

## 3. 受众与一句话职责

- 受众：45+ 银发用户，慢信、纸、邮戳。
- 这一屏的唯一主张：写完这封信，寄出去。
- 签名元素（只大胆这一处）：信纸上沿的五枚齿孔邮票。其余克制，继续用现有 `PostalTokens`（邮筒绿 `#1B4D3E`、信纸米 `#F7F2E9`、邮戳红 `#C43C3C`、牛皮纸辅色）。正文衬线沿用 Charter / Georgia / serif 链，不新引入字体包。

## 4. 屏幕结构

```
[ 取消 ]              寄给 · 有缘人 ▾     （时光信：· 下周三拆 ▾）

┌─────────────────────────────────────┐
│  [心事] [生活] [兴趣] [困惑] [聊聊]   │  邮票条
│  ┃  正文                             │  左侧装订线
│  ┃  首封占位：一句话也可以            │
│  128 字 · 撤销          信纸   助手  │  纸脚，图标+字
└─────────────────────────────────────┘

        [     通栏主按钮     ]
```

### 4.1 顶栏

- 左：取消（文字按钮，≥48dp）。
- 中：收件人。未锁定时可点，弹出现有二项 sheet（顺序跟 `recommendedAction`）。指定笔友从信箱进入时抬头锁死，无下拉。
- 时光信：抬头为 `寄给 · 未来的自己 · {日期短文案} ▾`，点日期段打开日期选择；默认仍约 +7 天，最早明天。
- 预览、存草稿退出顶栏。

### 4.2 信纸

- 铺满中部，牛皮纸桌面背景（可继续用现桌面色，不要再像悬浮卡片表单）。
- 左侧装订线保留。
- 首封（`firstLetterDone != true`）占位用「一句话也可以」；其后用普通正文占位。

### 4.3 纸脚工具

- 左：字数 + 撤销（撤销须文字，不用单独 emoji 当唯一识别）。
- 右：信纸、助手。均为图标+文字，触控 ≥48dp。
- 信纸：只含纸色 / 字体 / 字号。日期不在此 sheet。
- 助手：仍只暴露润色（natural）与灵感（inspire）。

### 4.4 主按钮

- 唯一主行动，通栏，邮筒绿，最小高度 56dp。
- 文案：
  - 寄给有缘人：投进邮局
  - 写给未来的自己：封缄寄出
  - 指定笔友（抬头锁死）：寄出这封信
- 忙碌时按钮 busy，不可重复点。

### 4.5 键盘

- 邮票条收成一行「已贴：{话题}」或「未贴邮票」；点开可再选。
- 主按钮贴在键盘上方，不被遮住。
- 纸脚工具可随键盘变矮，但不准消失到用户找不到「信纸/助手」。

## 5. 邮票规则

五枚固定话题，单选，可跳过，再点同一枚即揭掉：

| code | zh | en |
|---|---|---|
| heart_talk | 心事倾诉 | What's on my mind |
| life_share | 生活分享 | Life lately |
| interest_exchange | 兴趣交流 | Shared interests |
| life_puzzle | 人生困惑 | A question about life |
| just_chat | 随便聊聊 | Just saying hello |

视觉：齿孔小票，未贴为牛皮纸描边，已贴为邮戳红描边（像盖了戳）。不要用 Material `FilterChip` 默认样式。

布局：单行；窄屏横向滑动，禁止折成两行把信纸顶矮。触控高度 ≥48dp。

不贴也能寄。错误 id（服务端 400）时揭掉该票并 Snack「请重新选一个话题」。

## 6. 寄出路径

空正文：不 Snack，聚焦信纸。

### 6.1 有缘人 / 指定笔友

1. 若本安装尚未完成过预览门闩，先全屏预览「收信人会看到的样子」，确认后再发。
2. `POST` 发信（含可选 `topicTagId`）。
3. 现有投递 overlay 与会话刷新并行。
4. 现有「寄出后引导绑定」逻辑不变。

### 6.2 时光信

1. 同样的预览门闩。
2. 弹出封缄底板：确认日期 + 现有滑块。
3. 封缄 API 带可选 `topicTagId`。
4. 同样 overlay。

预览不再放在顶栏；需要时只作为寄出前的门闩（首次）或纸脚不设第二入口，避免和主按钮抢。用户若想再看，可在预览门闩已完成后通过「信纸」sheet 不解决预览——本轮不另做常驻预览入口。首次之后直接寄。

## 7. 草稿与离开

- 首封引导（`fromFirstLetterGuide`）：不存草稿，与现在一致。
- 其它：正文非空时，停笔 8 秒静默存一次；点取消或系统返回时先存再离开。
- 成功不提示。失败：停笔存失败保持沉默（下次还会再存）；离开时存失败则 Snack「这次没有存成草稿」后仍离开。
- 草稿统一走现有 `/api/letter-drafts`（与当前写信桌一致：有缘人/时光信 `mode=POST_OFFICE`，指定笔友 `mode=DIRECT`）。
- `contentJson` 增加可选 `topicTagId`；时光信另存可选 `deliveryDate`（ISO 日期）。打开草稿时邮票与日期还原。

## 8. 定位

进入写信页后仍调用现有 `LocationAccess.ensureAsked(compose)`。允许或拒绝都继续。永久拒绝走现有「去设置」说明。不挡住寄出。

## 9. 数据与 API

### 9.1 库

- `sys_tag` 增加 `tag_kind`：`interest`（已有行默认）| `letter_topic`。
- 为 `zh` / `en` 多种子五条 `letter_topic`（上表 code 存在 `tag_code` 新列，唯一：`lang_code + tag_code`）。无 code 列则加 `tag_code`；兴趣旧行 code 可空。
- `bu_letter` 增加可空 `topic_tag_id`（FK 逻辑指向 `sys_tag.id`，不强制数据库 FK 若现网风格不建 FK）。
- 匹配服务本轮不读此列。

### 9.2 Bootstrap

`AppBootstrapVO` 增加 `letterTopicOptions`：`id`、`code`、`title`（按请求语言）。客户端只渲染下发列表，不写死数字 id。

### 9.3 发信

- `AppSendLetterInDto.topicTagId` 可选。非空时必须是 `tag_kind = letter_topic` 的 id，否则 400。
- `TimeLetterSealInDto.topicTagId` 同样。
- 写入 `bu_letter.topic_tag_id`。
- 草稿保存：`contentJson.topicTagId` 可选。

分层：Controller → BizService → IService → Mapper。校验与写库打 key-path 日志（userId、letterId、topicTagId，无正文）。

改 API 后按仓库规则：`mvn clean package`、拷 JAR 到 `senior-post-api/dist/`、`.\scripts\dev-up.ps1 -ApiOnly`。

## 10. 失败与空态

| 情况 | 行为 |
|---|---|
| 空正文点主按钮 | 聚焦信纸，不弹错误 |
| 发信/封缄失败 | 留在写信桌，按钮恢复，Snack 业务原因（额度、网络） |
| 话题 id 非法 | 揭票 + Snack，正文保留 |
| 助手无正文 | 聚焦信纸（与现在一致） |
| Bootstrap 话题列表空 | 隐藏邮票条，仍可寄 |

## 11. 测试

- 邮票：点选 / 再点揭掉 / 不选可进寄出流程（空正文仍只聚焦）。
- 主按钮文案随 `ComposeKind` 变化。
- 键盘态：有 `viewInsets` 时仍能找到主按钮。
- 话题：发信 body 在选中时带 `topicTagId`，未选中不带该键。
- 回归：指定笔友锁抬头、首封预览门闩、封缄滑块仍能寄出。
- 现有 `compose_flow_page_test` 已过时（旧「选收件人三选一」文案），本轮按新骨架重写，不再断言「To future me」三按钮页。

## 12. 前端文件（实现时）

以 `compose_flow_page.dart` 为主；抽出邮票条、纸脚工具，避免单文件继续膨胀。删除未再引用的 `compose_step_scaffold.dart`（旧向导残留）。文案进 `app_zh.arb` / `app_en.arb`。注释与关键路径日志遵循 frontend-engineering-conventions。

## 13. 架构边界

| 单元 | 做什么 | 依赖 |
|---|---|---|
| Compose desk UI | 写、贴邮票、寄 | session、location、mailbox/time-letter remote、bootstrap 话题 |
| Letter topic catalog | 五枚邮票的 id/文案 | bootstrap |
| Send / seal API | 把正文和可选 topicTagId 落库 | User、Letter、Tag |
| Match | 本轮不读 topic | — |
