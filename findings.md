# 发现记录

## 4.0 工程现状（已核对代码）

- 分支：`feature_5.0`（产品讨论），代码仍为 4.0 已交付形态。
- 底部导航：四 Tab（邮局 / 笔友 / 信箱 / 我的），`main_shell.dart`。
- 鉴权：强制欢迎页 + 注册/登录墙；注册 8 步，要求至少 3 个兴趣标签、性别、出生年。
- 首封信引导：强制领取每日额度后进入 `FirstLetterGuidePage`，默认写 POST_OFFICE。
- 首页：`PostOfficeHomePage` 有“写信”主 CTA + 额度提示 + 关系消息/在途摘要；写信分流为“寄给有缘人 / 寄给未来的自己”，目前有缘人在前。
- 写信桌：单页写信桌 `ComposeFlowPage`，收件人 sheet 仅两个选项；有信纸/字体/AI 助手/预览；AI 助手五模式（warmer/natural/continue/shorten/inspire）。
- 信箱：三 Tab（收到 / 发出 / 时光信），已有“在途”横幅和未配对占位头像。
- 笔友页：三 Tab（推荐 / 找笔友 / 我的笔友），偏社交平台。
- 我的：个人资料 + 兴趣标签 + 商店/VIP + 导出/收藏 + 设置。
- 后端已有：`sys_tag`（tag_name/lang_code/sort_order）、`bu_user_tag`（user↔tag）、`PostOfficeMatchService`、`LetterDomain`（letter_type/send_mode/status/content 等）。
- 尚未有：静默设备身份主路径、系统欢迎信、写信话题 chips、动态首页、长图分享、AI 次数付费。

## 讨论已定（供落地稿引用）

- 产品本体 = 用户间写信；时光信 = 冷启动补位 + 偏好分支。
- 冷启动首页动态主推；系统欢迎信可接受（明确标注）。
- 匹配轻量：语言 + 可回信能力 + 国家/时区 + 写信话题 chips。
- 话题 chips（信维度）与兴趣标签（人维度）两套语义，底层可加 `sys_tag.tag_type` 区分。
- chips 定义为“写信动机”，建议 5 个：心事倾诉 / 生活分享 / 兴趣交流 / 人生困惑 / 随便聊聊；兴趣交流可选二级。

## 2026-08-17 全盘可行性审计要点

- 账号模型：后端无静默 guest 登录；注册强校验 `MIN_AGE`、性别、≥3 兴趣标签；绑定不合并访客。需新增 guest 发 token + 绑定升级合并。
- 系统欢迎信：`LetterDomain` 无系统来源标记；需定义 `from_user_id=0` 或 `source_type`，避免伪装真人。
- 匹配：`PostOfficeMatchService` 已是 v2，含语言/回信率/入站上限；应扩展而非重写，补 `willing_to_receive_new` + `topic_tag_id`。
- 话题 chips：`sys_tag` 无 `tag_type`，`bu_letter` 无 `topic_tag_id`，需 Flyway 增量。
- 首页动态主推：`post-office/home` 无池子状态；建议后端返回 `recommendedAction`，前端只渲染。
- 每日额度：强制领取 + 服务端拦截；应改静默发放，保留上限防刷。
- 商店/信纸：`commerceCatalogProvider` 与写信纸耦合；先深藏入口，保留默认信纸 fallback，避免物理删除返工。
- 三 Tab：`/penpals`、`DirectoryPage` 三 Tab、`MainShell` 四 Tab 需统一改三 Tab 并迁笔友列表到信箱。
- 推送：`AppDeviceController` 要求登录，guest 需允许注册 push token，否则系统信/到达推送不可达。
- 首封信引导：`FirstLetterGuidePage` 强制 POST_OFFICE，需改为动态引导。
