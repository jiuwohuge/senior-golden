// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '邮政社交';

  @override
  String get appTagline => '慢慢写信，温柔相连。';

  @override
  String get tabPostWall => '明信片墙';

  @override
  String get tabDirectory => '通信名录';

  @override
  String get tabMailbox => '邮政信箱';

  @override
  String get tabProfile => '我的邮政';

  @override
  String get a11yTabPostWall => '明信片墙：浏览全球会员公开的明信片';

  @override
  String get a11yTabDirectory => '通信名录：按国家与兴趣寻找笔友';

  @override
  String get a11yTabMailbox => '邮政信箱：您的信件与对话';

  @override
  String get a11yTabProfile => '我的邮政：个人资料与账户';

  @override
  String get a11yNavBar => '应用主要分区导航';

  @override
  String get placeholderWelcomeTitle => '此区域正在准备中';

  @override
  String get placeholderWelcomeBody => '我们正在完善这一页面。明信片、信件与好友将很快在此呈现。感谢您的耐心。';

  @override
  String get placeholderHint => '提示：使用下方导航在明信片墙、通信名录、邮政信箱与我的邮政之间切换。';

  @override
  String get postalMotifContentDescription => '顶部的装饰性邮戳图案';

  @override
  String get authLoginTitle => '登录';

  @override
  String get authEmailLabel => '邮箱';

  @override
  String get authPasswordLabel => '密码';

  @override
  String get authLoginSubmit => '登录';

  @override
  String get authGoRegister => '注册新账号';

  @override
  String get authRegisterTitle => '注册账号';

  @override
  String get authNicknameLabel => '昵称';

  @override
  String get authBirthYearLabel => '出生年份';

  @override
  String get authCountryCodeLabel => '国家（选填）';

  @override
  String get authAgreeTerms => '我已阅读并同意用户协议与隐私政策';

  @override
  String get authRegisterSubmit => '注册';

  @override
  String get authGoLogin => '已有账号？去登录';

  @override
  String get authFieldRequired => '请填写此项';

  @override
  String get authPasswordTooShort => '密码至少 8 位';

  @override
  String get authAgreeRequired => '请勾选同意条款后继续';

  @override
  String get authBusy => '请稍候…';

  @override
  String get authCountrySkip => '暂不选择';

  @override
  String get authBootstrapLoadFailed => '无法加载注册选项，请检查网络后重试。';

  @override
  String get authRetry => '重试';

  @override
  String get authBirthYearRangeError => '出生年份列表为空，请检查服务端注册最小年龄配置。';

  @override
  String get authWelcomeBack => '欢迎回到你的全球邮政社交空间。';

  @override
  String get authMockTip => '请使用已注册邮箱登录以使用全部功能。';

  @override
  String authAgreeTpl(Object privacy, Object terms) {
    return '我已阅读并同意 $terms 与 $privacy。';
  }

  @override
  String get authTermsTitle => '用户协议';

  @override
  String get authPrivacyTitle => '隐私政策';

  @override
  String get authForgotPassword => '忘记密码';

  @override
  String get authForgotIntro => '我们将向您的注册邮箱发送 6 位数字验证码，请在邮箱或（开发环境）服务端日志中查看。';

  @override
  String get authForgotCodeHint => '6 位数字';

  @override
  String get authForgotResetSuccess => '密码已更新，请返回登录。';

  @override
  String get authForgotCodeInvalid => '请输入 6 位数字验证码';

  @override
  String get authOnboardingAgain => '查看功能引导';

  @override
  String get authEmailInvalid => '请输入有效邮箱地址';

  @override
  String get authRegisterSubtitle => '一分钟创建你的邮政社交账号。';

  @override
  String get authRegisterWizardHint => '点击下方任一步骤可跳转；已填内容在提交前会一直保留。';

  @override
  String get authRegisterTabAccount => '账号';

  @override
  String get authRegisterTabProfile => '资料';

  @override
  String get authRegisterTabInterests => '兴趣';

  @override
  String get authRegisterTabReview => '确认';

  @override
  String authRegisterStepProgress(Object current, Object total) {
    return '第 $current 步，共 $total 步';
  }

  @override
  String get authRegisterStepAccountTitle => '登录信息';

  @override
  String get authRegisterStepAccountSubtitle => '邮箱用于安全提醒与重要通知。';

  @override
  String get authRegisterStepProfileTitle => '个人资料';

  @override
  String get authRegisterStepProfileSubtitle => '将显示在明信片、信件与名录中。';

  @override
  String get authRegisterStepInterestsTitle => '兴趣标签';

  @override
  String get authRegisterStepInterestsSubtitle => '至少选择三个，便于匹配笔友。';

  @override
  String get authRegisterStepReviewTitle => '确认与条款';

  @override
  String get authRegisterStepReviewSubtitle => '核对信息并同意条款后即可完成注册。';

  @override
  String get authRegisterNext => '继续';

  @override
  String get authRegisterBack => '上一步';

  @override
  String get authRegisterSummaryEmail => '邮箱';

  @override
  String get authRegisterSummaryNickname => '昵称';

  @override
  String get authRegisterSummaryBirth => '出生年份';

  @override
  String get authRegisterSummaryCountry => '国家 / 地区';

  @override
  String get authRegisterSummaryInterests => '兴趣标签';

  @override
  String get authRegisterInterestsMin => '请至少选择三个兴趣标签。';

  @override
  String get authRegisterInterestsServerEmpty => '服务器暂无兴趣标签，可尝试切换语言或由管理员维护词表。';

  @override
  String get authConfirmPasswordLabel => '确认密码';

  @override
  String get authPasswordNotMatch => '两次输入的密码不一致';

  @override
  String get authBirthYearRequired => '请选择出生年份';

  @override
  String get authForgotStepEmail => '邮箱';

  @override
  String get authForgotStepCode => '验证码';

  @override
  String get authForgotStepDone => '完成';

  @override
  String get authForgotSendCode => '发送重置邮件';

  @override
  String get authForgotMailSent => '已发送重置说明，请检查邮箱。';

  @override
  String get authForgotCode => '验证码';

  @override
  String get authForgotNewPassword => '新密码';

  @override
  String get authForgotResetNow => '立即重置';

  @override
  String get authForgotDoneTitle => '密码重置完成';

  @override
  String get authForgotDoneBody => '现在你可以返回登录，使用新密码进入应用。';

  @override
  String get authBackToLogin => '返回登录';

  @override
  String get onboardTitle1 => '全球邮政体系社交';

  @override
  String get onboardBody1 => '在慢节奏、非婚恋的环境里，认识世界各地 45+ 朋友。';

  @override
  String get onboardTitle2 => '慢慢写信，真实陪伴';

  @override
  String get onboardBody2 => '用明信片与信件交流，不以点赞和颜值驱动关系。';

  @override
  String get onboardTitle3 => '可信赖、适老化';

  @override
  String get onboardBody3 => '更大字号、更清晰交互、更重视隐私与内容安全。';

  @override
  String get onboardSkip => '跳过';

  @override
  String get onboardNext => '下一步';

  @override
  String get onboardDone => '开始使用';

  @override
  String get commonRetry => '重试';

  @override
  String get postWallUnavailable => '明信片墙暂时不可用';

  @override
  String get postWallEmptyTitle => '还没有明信片';

  @override
  String get postWallEmptySubtitle => '今天由你来发第一张明信片吧。';

  @override
  String get postWallWriteAction => '写明信片';

  @override
  String get postWallFAB => '去写';

  @override
  String postWallPhotosLabel(Object count) {
    return '$count 张配图';
  }

  @override
  String get postWallSendLetterTooltip => '写信';

  @override
  String postWallCommentsCount(Object count) {
    return '评论 $count';
  }

  @override
  String get postComposeTitle => '写明信片';

  @override
  String get postComposeSectionTitle => '撰写';

  @override
  String get postComposeSectionSubtitle => '写下今日的一张明信片';

  @override
  String get postComposeContentLabel => '明信片正文';

  @override
  String get postComposeContentHint => '记录今天的心情、想法或问候…';

  @override
  String postComposeMaxImages(Object max) {
    return '最多 $max 张配图';
  }

  @override
  String get postComposeUploadNeedRealApi => '图片上传需要服务端签发地址，请检查网络后重试。';

  @override
  String get postComposePickerChannelError =>
      '相册插件未连接。请完全停止应用后重新运行；仍失败请执行 flutter clean。';

  @override
  String get postComposeImageUploaded => '图片已上传';

  @override
  String get postComposeNeedContent => '请先写一些内容。';

  @override
  String get postComposePublishedMock => '明信片已提交。';

  @override
  String get postComposePublishedReal => '已提交审核，通过后将出现在明信片墙';

  @override
  String get postComposeUploading => '上传中…';

  @override
  String get postComposeAddImage => '添加配图（OSS）';

  @override
  String postComposeAddAnother(Object n, Object max) {
    return '继续添加（$n/$max）';
  }

  @override
  String get postComposePublish => '立即发布';

  @override
  String get postcardImageCropTitle => '裁剪配图（4:3）';

  @override
  String get postcardImageCropHelp => '拖动与缩放选区，确认后以 4:3 比例裁剪并上传。';

  @override
  String get profileBlacklist => '黑名单';

  @override
  String get settingsFeedback => '意见反馈';

  @override
  String get dialogConfirm => '确定';

  @override
  String get socialBlockUser => '拉黑';

  @override
  String get socialBlockConfirmTitle => '加入黑名单？';

  @override
  String get socialBlockConfirmMessage => '对方将无法向你寄信，公开墙与名录中也不会互相看到。';

  @override
  String get socialBlockSuccess => '已拉黑';

  @override
  String get socialUnblock => '取消拉黑';

  @override
  String socialUnblockConfirm(Object name) {
    return '确定取消对「$name」的拉黑？';
  }

  @override
  String get socialUnblockSuccess => '已取消拉黑';

  @override
  String get socialBlacklistTitle => '黑名单';

  @override
  String get socialBlacklistSubtitle => '已屏蔽的用户不会出现在墙与名录，且无法寄信。';

  @override
  String get socialBlacklistEmpty => '暂无拉黑用户';

  @override
  String socialBlockedAt(Object time) {
    return '拉黑时间：$time';
  }

  @override
  String get feedbackTitle => '意见反馈';

  @override
  String get feedbackBodyLabel => '问题或建议（必填）';

  @override
  String get feedbackBodyHint => '请描述操作步骤、期望与实际表现，便于我们排查。';

  @override
  String get feedbackSubmit => '提交';

  @override
  String get feedbackSubmitting => '提交中…';

  @override
  String get feedbackSuccess => '感谢反馈，我们会尽快查阅。';

  @override
  String get feedbackNeedContent => '请填写反馈正文。';

  @override
  String get userCardTitle => '会员资料';

  @override
  String get userCardSendLetter => '寄信';

  @override
  String get userCardBack => '返回';

  @override
  String get userCardErrorTitle => '无法加载资料';

  @override
  String get userCardNotFoundTitle => '找不到该会员';

  @override
  String get userCardNotFoundSubtitle => '对方可能暂不可用，或与你的关系受限。';

  @override
  String get directoryTitle => '通信名录';

  @override
  String get directorySubtitle => '按国家与兴趣寻找笔友';

  @override
  String get directoryLoadFailed => '名录加载失败';

  @override
  String get directoryEmptyTitle => '没有符合条件的会员';

  @override
  String get directoryEmptySubtitle => '尝试清空筛选或调整年龄范围。';

  @override
  String directoryAgeYears(Object age) {
    return '$age 岁';
  }

  @override
  String get authBirthYearSheetTitle => '出生年份';

  @override
  String authBirthYearFormat(Object year, Object age) {
    return '$year（$age 岁）';
  }

  @override
  String get authCountryAutoLabel => '地区（随界面语言）';

  @override
  String get authEmailHint => 'name@example.com';

  @override
  String get profileEditTitle => '编辑资料';

  @override
  String get profileNickname => '昵称';

  @override
  String get profileCountry => '国家/地区';

  @override
  String get profileBio => '个人简介';

  @override
  String get profileSave => '保存';

  @override
  String get profileMockUpdated => '资料已更新';

  @override
  String get profileSaved => '资料已保存';

  @override
  String get profileAvatarChange => '更换头像';

  @override
  String get profileAvatarCropTitle => '裁剪头像';

  @override
  String get profileAvatarCropDone => '完成';

  @override
  String get profileAvatarCropCancel => '取消';

  @override
  String get profileAvatarCropConfirm => '确认裁剪';

  @override
  String get profileAvatarCropHelp => '拖动、缩放，将头像对准圆内。取消则不保存。';

  @override
  String get profileAvatarPreviewHint =>
      '拖动缩放选区后点「确认裁剪」。回到本页后点「确认上传」保存头像，或点「放弃」取消。';

  @override
  String get profileAvatarConfirmUpload => '确认上传';

  @override
  String get profileAvatarDiscardUpload => '放弃';

  @override
  String get profileAvatarUploadSuccess => '头像已更新';

  @override
  String get profileAvatarUploadFailed => '头像上传失败';

  @override
  String get profileAvatarUploading => '正在上传头像…';

  @override
  String get profileEditCancel => '关闭';

  @override
  String get profileEditProfile => '编辑资料';

  @override
  String get profileInterestTags => '兴趣标签';

  @override
  String get profileStampsLedger => '邮票流水';

  @override
  String get profileVipCenter => 'VIP 中心';

  @override
  String get profileSettings => '设置';

  @override
  String get profileAbout => '关于';

  @override
  String get profileUserAgreement => '用户协议';

  @override
  String get profilePrivacyPolicy => '隐私政策';

  @override
  String get profileLogout => '退出登录';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsPushNotifications => '推送通知';

  @override
  String get settingsUnreadBadges => '显示未读角标';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsLanguageSubtitle => 'English / 中文 / 跟随系统';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageChinese => '中文';

  @override
  String get settingsLanguageSystem => '跟随系统';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsDeleteAccount => '注销账号';

  @override
  String get legalEffectiveDate => '生效日期：2026-05-01';

  @override
  String get legalTermsContent =>
      '1）本应用面向 45+ 成年用户提供兴趣陪伴社交服务。\\n\\n2）本产品不提供婚恋与匹配服务。\\n\\n3）你需对发布内容负责，不得发布违法违规内容。\\n\\n4）对于骚扰、刷屏、欺诈等行为，平台可限制或封禁账号。\\n\\n5）平台提供举报和审核机制以维护安全交流环境。';

  @override
  String get legalPrivacyContent =>
      '1）我们会收集账号与设备信息用于安全风控与服务提供。\\n\\n2）我们依据适用隐私法规处理数据，并提供删除/导出路径。\\n\\n3）我们不会出售你的个人数据。\\n\\n4）部分数据处理用于实现核心消息与内容审核能力。\\n\\n5）你可联系支持申请账号删除与相关数据清理。';

  @override
  String get vipCenterUnlimitedRegisteredMail => '会员可无限寄送挂号信（以服务端规则为准）。';

  @override
  String vipCenterStandardPriorityHours(Object hours) {
    return '普通邮件优先：约 $hours 小时（配置值）。';
  }

  @override
  String get vipCenterFreeSpeedUpStandard => '会员普通邮件可免费加速（以服务端规则为准）。';

  @override
  String get vipCenterPurchaseDisabled => 'VIP 暂不可购买。';

  @override
  String get vipCenterCheckoutNotWired => '订阅结账尚未接入；权益以账号 VIP 状态为准。';

  @override
  String vipCenterLoadFailed(Object error) {
    return '加载 VIP 信息失败：$error';
  }

  @override
  String get profileMyPostcards => '我的明信片';

  @override
  String get myPostcardsEmptyTitle => '还没有明信片';

  @override
  String get myPostcardsEmptySubtitle => '在「明信片墙」发布内容后，将在此显示审核进度。';

  @override
  String get myPostcardsLoadFailedTitle => '明信片列表加载失败';

  @override
  String get postcardReviewPendingBadge => '待审核';

  @override
  String get postcardReviewApprovedBadge => '审核通过';

  @override
  String get postcardReviewRejectedBadge => '审核拒绝';

  @override
  String get postcardPostHiddenBadge => '已隐藏';

  @override
  String get postcardPostRemovedBadge => '已删除';

  @override
  String get postcardReviewPendingBanner => '明信片待审核，仅本人可见。';

  @override
  String get postcardReviewRejectedBanner => '明信片未通过公开审核，仍可在列表中查看。';

  @override
  String get letterMailboxSealedPreview => '信件密封递送中';

  @override
  String get letterContentHiddenHint =>
      '平邮运输中，正文已密封。自然送达后将自动展示，或使用 1 枚邮票提前拆信（VIP 免扣）。';

  @override
  String get letterEarlyOpenCta => '提前拆信（1 枚邮票）';

  @override
  String get letterEarlyOpenSuccess => '已提前拆信，可阅读全文。';

  @override
  String get postDetailTitle => '明信片';

  @override
  String get letterDetailTitle => '信件详情';

  @override
  String get chatFriendsOnlySnack => '仅「邮政好友 / Connections」中的笔友可使用即时聊天。';

  @override
  String get chatEmojiPickerTitle => '友好表情';

  @override
  String get chatEmojiPickerSubtitle => '点选一个表情插入到消息中。';

  @override
  String get postDetailCommentRequired => '请输入评论内容。';

  @override
  String get postDetailCommentPosted => '评论已发送。';

  @override
  String get errorInvalidContentId => '无效的内容编号。';

  @override
  String get errorInvalidResponse => '服务器响应格式无效。';

  @override
  String get directoryFilterSectionTitle => '筛选名录';

  @override
  String get directoryFilterSectionSubtitle => '国家、年龄、兴趣与排序';

  @override
  String get directoryFilterCountryLabel => '国家';

  @override
  String get directoryFilterSort => '排序';

  @override
  String get directoryFilterNewest => '最新';

  @override
  String get directoryFilterClosestAge => '年龄最接近';

  @override
  String get directoryFilterSharedInterests => '共同兴趣';

  @override
  String get directoryFilterAllCountries => '全部国家';

  @override
  String directoryFilterMinAge(Object age) {
    return '最小年龄：$age';
  }

  @override
  String directoryFilterMaxAge(Object age) {
    return '最大年龄：$age';
  }

  @override
  String get mailboxArchiveTitle => '信件归档';

  @override
  String get mailboxOpenArchive => '归档';

  @override
  String get mailboxPostOnTheWay => '有明信片正在路上';

  @override
  String get shopTitleStampsVip => '邮票与会员';

  @override
  String get shopPlaceholderOrders => '订单与记录（占位）';

  @override
  String get shopPlaceholderBuy => '购买（占位）';

  @override
  String get shopOrdersSnackbar => '订单与支付记录将在商品系统接入后开放。';

  @override
  String get shopPricePlaceholder => '价格：—';

  @override
  String get shopCheckoutSnackbar => '收银台将在商品与支付网关接入后开放。';

  @override
  String shopSkuStampLine(Object count) {
    return '×$count 枚邮票';
  }

  @override
  String get interestsPickerSaved => '兴趣已保存。';

  @override
  String get reportReasonRequired => '请填写举报原因';

  @override
  String get reportSubmitted => '举报已提交';

  @override
  String get accountDeleteTitle => '注销账号';

  @override
  String get stampsLedgerTitle => '邮票流水';

  @override
  String get interestsPickerTitle => '兴趣标签';

  @override
  String get sendLetterRegisteredMail => '挂号信';

  @override
  String get sendLetterStandardPost => '平邮';

  @override
  String get sendLetterBodyRequired => '请填写信件正文。';

  @override
  String get sendLetterRegisteredStampShort => '挂号信需要邮票，当前余额不足。';

  @override
  String get sendLetterSentSuccess => '信件已寄出。';

  @override
  String sendLetterSheetTitle(Object name) {
    return '寄信给 $name';
  }

  @override
  String get sendLetterRegisteredSubVip => '会员免费';

  @override
  String get sendLetterRegisteredSubPaid => '消耗 1 枚邮票';

  @override
  String get sendLetterStandardSub => '免费，延迟送达';

  @override
  String get sendLetterContentLabel => '信件正文';
}
