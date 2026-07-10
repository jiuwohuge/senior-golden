// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '时光邮局';

  @override
  String get appTagline => '可信笔友，慢慢来信。';

  @override
  String get tabPostWall => '邮局';

  @override
  String get tabDirectory => '笔友';

  @override
  String get tabMailbox => '信箱';

  @override
  String get tabProfile => '我的';

  @override
  String get a11yTabPostWall => '邮局：写信、消息与信件在途';

  @override
  String get a11yTabDirectory => '笔友：推荐、找笔友与我的笔友';

  @override
  String get a11yTabMailbox => '信箱：收到的信、发出的信与时光信';

  @override
  String get postOfficeGreeting => '早上好';

  @override
  String get postOfficeTodayHint => '写下第一封信，等待有缘人回信';

  @override
  String get postOfficeWriteLetter => '写信';

  @override
  String postOfficeFreeQuotaHint(int count) {
    return '今日还可免费寄 $count 封';
  }

  @override
  String postOfficeMessagesSummary(int count) {
    return '消息 $count 条';
  }

  @override
  String postOfficeInTransitSummary(int count) {
    return '信件在途 $count 封';
  }

  @override
  String get a11yTabProfile => '我的：个人资料、收藏信件与设置';

  @override
  String get a11yNavBar => '应用主要分区导航';

  @override
  String get placeholderWelcomeTitle => '此区域正在准备中';

  @override
  String get placeholderWelcomeBody => '我们正在完善这一页面。明信片、信件与好友将很快在此呈现。感谢您的耐心。';

  @override
  String get placeholderHint => '提示：使用下方导航在主题信箱、笔友、我的信箱与纪念册之间切换。';

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
  String get authWelcomeRegister => '注册';

  @override
  String get authWelcomeLogin => '登录';

  @override
  String get authWelcomeHaveAccount => '已有账号？';

  @override
  String get authWelcomeHighlightLetters => '以从容的节奏写信、收信';

  @override
  String get authWelcomeHighlightDirectory => '在名录结识世界各地的笔友';

  @override
  String get authWelcomeHighlightPace => '为 45 岁及以上成年人设计';

  @override
  String get authWelcomeTagline => '慢节奏书信，面向 45+ 成年人';

  @override
  String authWelcomeLegalFooter(Object privacy, Object terms) {
    return '注册即表示同意$terms与$privacy。';
  }

  @override
  String get authRegisterWizardEmailTitle => '您的邮箱是？';

  @override
  String get authRegisterWizardEmailSubtitle => '用于登录及明信片、信件相关的重要通知。';

  @override
  String get authRegisterWizardPasswordTitle => '设置密码';

  @override
  String get authRegisterWizardPasswordSubtitle => '至少 8 位，请妥善保管。';

  @override
  String get authRegisterWizardNameTitle => '怎么称呼您？';

  @override
  String get authRegisterWizardNameSubtitle => '将显示在明信片、信件与名录中。';

  @override
  String get authRegisterWizardGenderTitle => '您的性别是？';

  @override
  String get authRegisterWizardGenderSubtitle => '便于在名录中为您匹配合适的笔友。';

  @override
  String get authRegisterWizardAgeTitle => '您的年龄？';

  @override
  String get authRegisterWizardAgeSubtitle => '出生年份帮助我们为 45+ 用户优化体验。';

  @override
  String get authRegisterProfileHint => '这些信息会显示在您的资料中。';

  @override
  String authRegisterAgePreview(Object age) {
    return '我今年 $age 岁';
  }

  @override
  String get authRegisterSummaryGender => '性别';

  @override
  String get authContinueWithGoogle => '使用 Google 登录';

  @override
  String get authOrContinueWithEmail => '或使用邮箱登录';

  @override
  String get authGoogleNotConfigured => 'Google 登录尚未配置';

  @override
  String get authGenderLabel => '性别';

  @override
  String get authGenderMale => '男';

  @override
  String get authGenderFemale => '女';

  @override
  String get authRegisterAvatarOptional => '头像（可选）';

  @override
  String get authRegisterAvatarSkipHint => '可跳过，稍后在「我的邮政」中上传';

  @override
  String get authRegisterWizardAvatarTitle => '展示您的笑容';

  @override
  String get authRegisterWizardAvatarSubtitle => '添加一张亲切的照片，微笑最有感染力。';

  @override
  String get authRegisterAvatarTapToAdd => '点击添加照片';

  @override
  String get authRegisterAvatarAgreeFirst => '请先勾选下方协议，再上传头像';

  @override
  String get authRegisterAvatarUploading => '正在上传头像…';

  @override
  String get authRegisterAvatarUploaded => '已上传';

  @override
  String get authRegisterSummaryAvatarPending => '已选，待上传';

  @override
  String get authRegisterSummaryAvatar => '头像';

  @override
  String get authRegisterSummaryAvatarSet => '已选择，注册后上传';

  @override
  String get authRegisterSummaryAvatarSkipped => '未上传';

  @override
  String get authSocialCompleteTitle => '完善资料';

  @override
  String get directoryFilterGender => '性别';

  @override
  String get directoryFilterGenderHint => '可选；不选或选「全部」表示不限性别。';

  @override
  String get directoryFilterGenderAll => '全部';

  @override
  String get directoryFilterInterests => '兴趣标签';

  @override
  String get directoryFilterInterestsHint => '可选；多选可缩小名录，匹配有共同爱好的笔友。';

  @override
  String get directoryFilterInterestsEmpty => '服务器暂无兴趣标签，可尝试切换语言或由管理员维护词表。';

  @override
  String get directoryFilterApply => '应用筛选';

  @override
  String get directoryFilterClear => '清除';

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
  String get postWallFeedEveryone => '全部';

  @override
  String get postWallFeedConnections => '好友';

  @override
  String get postWallEmptyConnectionsSubtitle => '邮政好友还没有公开明信片，先通过信件建立笔友关系吧。';

  @override
  String get userCardFriendPostcardsTitle => '好友明信片';

  @override
  String get userCardFriendPostcardsSubtitle => '笔友最近发布的公开动态';

  @override
  String get userCardFriendPostcardsEmpty => '还没有公开明信片';

  @override
  String get userCardLoadMorePostcards => '加载更多';

  @override
  String get postComposeRejected => '明信片未通过审核，请修改后重新发布。';

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
  String get userCardBioSection => '个人简介';

  @override
  String get userCardBioEmpty => '暂无简介';

  @override
  String get userCardReportUser => '举报';

  @override
  String get userCardReportSheetTitle => '举报该用户';

  @override
  String get userCardErrorTitle => '无法加载资料';

  @override
  String get userCardNotFoundTitle => '找不到该会员';

  @override
  String get userCardNotFoundSubtitle => '对方可能暂不可用，或与你的关系受限。';

  @override
  String get directoryTitle => '笔友大厅';

  @override
  String get directorySubtitle => '先读资料，再写一封认真来信。这里不做快速匹配。';

  @override
  String get directoryFilterCta => '筛选笔友';

  @override
  String get directorySafetyTitle => '先通信，再私聊';

  @override
  String get directorySafetyBody => '资料只是开始。涉及金钱、投资、验证码、私下联系方式等内容，请等真正熟悉后再决定。';

  @override
  String get directoryListTitle => '愿意收信的人';

  @override
  String get directoryListSubtitle => '看故事和共同兴趣，不急着刷人。';

  @override
  String get directoryLetterFirstBadge => '先写信';

  @override
  String get directoryViewProfile => '查看资料';

  @override
  String get directoryBioFallback => '这位成员还没有写自我介绍。你可以先看看兴趣，再决定是否写信。';

  @override
  String get directoryInterestEmpty => '兴趣待补充';

  @override
  String directoryMoreInterests(Object count) {
    return '还有 $count 个';
  }

  @override
  String get directoryLoadFailed => '名录加载失败';

  @override
  String get directoryEmptyTitle => '没有符合条件的会员';

  @override
  String get directoryEmptySubtitle => '可以清空筛选，或等新的官方主题带来更多来信后再看看。';

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
  String get profileAvatarAuditPending => '审核中';

  @override
  String get profileAvatarAuditRejected => '已驳回';

  @override
  String get profileAvatarUploadPendingReview => '头像已提交，等待审核';

  @override
  String get profileAvatarRejectedHint => '头像未通过审核，请重新上传';

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
  String get settingsLanguageSubtitle => '默认跟随设备；可手动覆盖';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageChinese => '中文';

  @override
  String get settingsLanguageSystem => '跟随设备';

  @override
  String get settingsEmailVerify => '邮箱验证绑定';

  @override
  String get settingsEmailVerifyPending => '未验证 — 点击绑定';

  @override
  String get settingsEmailVerifyDone => '已验证';

  @override
  String get settingsEmailVerifyTitle => '邮箱验证';

  @override
  String settingsEmailVerifyHint(String email) {
    return '验证码将发送至 $email';
  }

  @override
  String get settingsEmailVerifyCodeLabel => '验证码';

  @override
  String get settingsEmailVerifySendCode => '发送验证码';

  @override
  String get settingsEmailVerifyConfirm => '确认绑定';

  @override
  String get settingsEmailVerifyCodeSent => '验证码已发送';

  @override
  String get settingsEmailVerifyCodeRequired => '请输入验证码';

  @override
  String get settingsEmailVerifySuccess => '邮箱已验证';

  @override
  String get authLoginChallengeTitle => '确认是你本人';

  @override
  String get authLoginChallengeHint => '检测到异常登录，请输入发到邮箱的验证码。';

  @override
  String get authLoginChallengeSend => '发送验证码';

  @override
  String get authLoginChallengeConfirm => '验证并继续';

  @override
  String get authLoginChallengeCodeSent => '验证码已发送';

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
  String get letterContentHiddenHint => '信件仍在途中，正文将在送达后展示。';

  @override
  String get letterEarlyOpenCta => '提前拆信（1 枚邮票）';

  @override
  String get letterEarlyOpenSuccess => '已提前拆信，可阅读全文。';

  @override
  String get postDetailTitle => '明信片';

  @override
  String get letterDetailTitle => '信件详情';

  @override
  String get letterModePostOffice => '邮局匹配';

  @override
  String get letterModeDirect => '指定投递';

  @override
  String get letterModeSelfTime => '时光信（SELF_TIME）';

  @override
  String letterModeLine(String mode) {
    return '模式：$mode';
  }

  @override
  String get letterStatusMatched => '已匹配';

  @override
  String get letterAuditPending => '待审核';

  @override
  String get letterAuditApproved => '已通过';

  @override
  String get letterAuditRejected => '已拒绝';

  @override
  String letterAuditLine(String status) {
    return '审核：$status';
  }

  @override
  String get letterEtaLabel => '预计送达';

  @override
  String get letterDeliveredLabel => '已送达';

  @override
  String get letterPeerPostOfficePool => '邮局匹配池';

  @override
  String get letterPeerUnknown => '未知收件人';

  @override
  String get letterAcceptContact => '添加笔友';

  @override
  String get letterAcceptContactDone => '申请已发送';

  @override
  String get letterAcceptContactSuccess => '笔友申请已发送，对方确认后可在笔友页查看。';

  @override
  String get chatFriendsOnlySnack => '仅「邮政好友 / Connections」中的笔友可使用即时聊天。';

  @override
  String get chatEmojiPickerTitle => '友好表情';

  @override
  String get chatEmojiPickerSubtitle => '点选一个表情插入到消息中。';

  @override
  String get chatComposerHint => '写点什么…';

  @override
  String get postDetailCommentRequired => '请输入评论内容。';

  @override
  String get postDetailCommentPosted => '评论已发送。';

  @override
  String get postDetailReply => '回复';

  @override
  String postDetailReplyingTo(Object name) {
    return '回复 @$name';
  }

  @override
  String get postDetailCancelReply => '取消';

  @override
  String get postDetailLike => '赞';

  @override
  String get postDetailReportComment => '举报';

  @override
  String get postDetailCommentsSection => '评论';

  @override
  String get postDetailReplyPrefix => '回复';

  @override
  String get postDetailWriteComment => '写评论…';

  @override
  String get postDetailSendComment => '发送';

  @override
  String get postDetailNoCommentsTitle => '还没有评论';

  @override
  String get postDetailNoCommentsSubtitle => '来写下第一条友善留言吧。';

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
  String get sendLetterSentSuccessTitle => '寄信成功';

  @override
  String get sendLetterSentSuccessMessage => '您的信件已寄出，对方将在邮政信箱中收到。';

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

  @override
  String get mailboxTabReceived => '收到的信';

  @override
  String get mailboxTabSent => '发出的信';

  @override
  String get mailboxTabTimeLetter => '时光信';

  @override
  String get mailboxReceivedEmptyTitle => '暂无收到的信';

  @override
  String get mailboxReceivedEmptySubtitle => '邮局或笔友寄来的信件会出现在这里。';

  @override
  String get mailboxSentEmptyTitle => '暂无发出的信';

  @override
  String get mailboxSentEmptySubtitle => '您寄出的信件会留在这里，直到对方已读。';

  @override
  String get directoryTabRecommend => '推荐笔友';

  @override
  String get directoryTabFind => '找笔友';

  @override
  String get directoryTabMyPenpals => '我的笔友';

  @override
  String get directoryRecommendEmpty => '今日暂无推荐';

  @override
  String get directoryRecommendEmptyHint => '明天再来看看，或去「找笔友」探索更多笔友。';

  @override
  String get directoryPenpalsEmpty => '还没有笔友';

  @override
  String get directoryPenpalsEmptyHint => '互通信件后可发起笔友申请，对方确认后会出现在这里。';

  @override
  String get directoryWriteLetter => '写信';

  @override
  String penpalListMeta(Object days, Object count) {
    return '笔友 $days 天 · 往来 $count 封';
  }

  @override
  String get postOfficeRelationMessagesTitle => '关系消息';

  @override
  String get postOfficeRelationMessagesEmpty => '暂无关系消息';

  @override
  String get postOfficeRelationMessagesEmptyHint => '笔友申请与可添加笔友提醒会出现在这里。';

  @override
  String penpalExchangeCount(Object count) {
    return '已往来 $count 封信';
  }

  @override
  String get penpalAccept => '同意';

  @override
  String get penpalIgnore => '忽略';

  @override
  String get penpalAcceptSuccess => '已成为笔友';

  @override
  String get penpalRequestSent => '笔友申请已发送';

  @override
  String get relationAddPenpal => '添加笔友';

  @override
  String get relationAddPenpalSuccess => '笔友申请已发送，等待对方确认';

  @override
  String get relationStateStranger => '陌生人';

  @override
  String get relationStateContacting => '通信中';

  @override
  String get relationStateCanAddPenpal => '可添加笔友';

  @override
  String get relationStatePendingOut => '申请中';

  @override
  String get relationStatePendingIn => '待确认';

  @override
  String get relationStatePenpal => '笔友';

  @override
  String get userCardWriteFirstLetter => '写第一封信';

  @override
  String get userCardContinueWriting => '继续写信';

  @override
  String get profileOverviewPenpals => '笔友';

  @override
  String get profileOverviewLetters => '通信';

  @override
  String get profileOverviewTimeLetters => '时光信';

  @override
  String get profileSectionMyContent => '我的内容';

  @override
  String get profileSectionShop => '商店与会员';

  @override
  String get profileSectionPrivacy => '隐私与安全';

  @override
  String get profileTimeLetterDrafts => '时光信';

  @override
  String get profilePrivacyRecommendPlaceholder => '屏蔽推荐（即将推出）';

  @override
  String get profilePrivacyStrangerPlaceholder => '拒收陌生信（即将推出）';

  @override
  String get commonLoadFailed => '加载失败';

  @override
  String get timeLetterComposeTitle => '时光邮局';

  @override
  String get timeLetterComposeToSelf => '写给未来的自己';

  @override
  String timeLetterComposeToFriend(Object name) {
    return '写给 $name';
  }

  @override
  String get timeLetterDeliveryDate => '送达日期';

  @override
  String timeLetterDaysUntil(Object days) {
    return '还有 $days 天送达';
  }

  @override
  String get timeLetterBodyHint => '写下想对未来自己或笔友说的话…';

  @override
  String get timeLetterBodyEmpty => '请先填写正文';

  @override
  String get timeLetterSealSlide => '滑动封缄';

  @override
  String get timeLetterSealSuccessTitle => '封缄成功';

  @override
  String get timeLetterSealSuccessMessage => '时光信已寄出，将在您选择的日期送达。';

  @override
  String get timeLetterTabOutbox => '发件箱';

  @override
  String get timeLetterTabInbox => '收件箱';

  @override
  String get timeLetterTabMemorial => '纪念册';

  @override
  String get timeLetterEmptyTitle => '还没有时光信';

  @override
  String get timeLetterEmptySubtitle => '写给未来的自己，或互关笔友。';

  @override
  String get timeLetterLoadError => '无法加载时光信';

  @override
  String get timeLetterSealedHidden => '已封缄，送达前不可查看正文';

  @override
  String get timeLetterTapToOpen => '送达后可拆信阅读';

  @override
  String get timeLetterCancelTitle => '取消这封信？';

  @override
  String get timeLetterCancelMessage => '24 小时内取消将退还邮票。';

  @override
  String get timeLetterOpenTitle => '拆阅时光信';

  @override
  String get timeLetterOpenRitual => '拆开信封';

  @override
  String timeLetterReadEstimate(Object minutes) {
    return '约 $minutes 分钟阅读';
  }

  @override
  String get timeLetterStar => '加入纪念册';

  @override
  String get timeLetterStarred => '已收藏';

  @override
  String get timeLetterSendToFriend => '寄时光信';

  @override
  String timeLetterBanner(Object inFlight, Object unread, Object today) {
    return '在途 $inFlight 封 · 待拆 $unread 封 · 今日送达 $today 封';
  }

  @override
  String get topicFriendFallback => '朋友';

  @override
  String topicTodayGreeting(Object name) {
    return '$name，今天慢慢来';
  }

  @override
  String get topicTodayIntro => '这里不催促。可以读一封来信，写一封认真回信，或从今日主题开始。';

  @override
  String get topicTodayLetters => '待处理来信';

  @override
  String topicTodayLettersCount(Object count) {
    return '$count 封';
  }

  @override
  String get topicTodayLoading => '加载中';

  @override
  String get topicTodayTime => '时光信';

  @override
  String topicTodayTimeLetters(Object inFlight, Object unread) {
    return '在途 $inFlight · 可拆 $unread';
  }

  @override
  String get topicTodayTimeLettersLoading => '检查中';

  @override
  String get topicWriteLetter => '写一封信';

  @override
  String get topicOpenMailbox => '打开信箱';

  @override
  String get topicOfficialLetterTitle => '来自时光邮局的一封信';

  @override
  String get topicOfficialIdentity => '官方来信 · 明确标注';

  @override
  String get topicOfficialLetterBody =>
      '今天可以写一段回忆、一顿饭，或一个你仍然想念的地方。官方来信永远不会伪装成真实笔友。';

  @override
  String get topicOfficialCta => '写给未来的自己';

  @override
  String get topicDailyTitle => '今日主题信箱';

  @override
  String get topicDailySubtitle => '选一个温和的话题慢慢写。好信件比长时间刷屏更重要。';

  @override
  String get topicWriteToTopic => '写进这个信箱';

  @override
  String get topicOfficialExample => '官方示例';

  @override
  String get topicTodayTopic => '今日主题';

  @override
  String get topicHometownTitle => '记忆里的故乡';

  @override
  String get topicHometownPrompt => '写一条路、一个集市，或一扇你还记得的门。';

  @override
  String get topicRetirementTitle => '退休后的安静一天';

  @override
  String get topicRetirementPrompt => '写最近一个让你觉得舒服的普通时刻。';

  @override
  String get topicOldPhotoTitle => '老照片背后的故事';

  @override
  String get topicOldPhotoPrompt => '从一张老照片里选一个人、一个地方或一个季节，写下仍留在心里的部分。';

  @override
  String get topicSafetyTitle => '更安心地认识笔友';

  @override
  String get topicSafetyBody => '涉及金钱、投资、验证码、私下联系方式等内容会被谨慎提醒。你可以慢慢写，也可以慢慢决定。';

  @override
  String get composeTitle => '写一封信';

  @override
  String get composeStepDestinationTitle => '这封信写给谁';

  @override
  String get composeStepDestinationSubtitle => '每一步只做一件事。不着急，慢慢写。';

  @override
  String get composeStepFooter => '基础写信不会被付费拦住。';

  @override
  String get composeChooseSelf => '写给自己（时光信）';

  @override
  String get composeChooseSelfSub => 'SELF_TIME — 到约定日期再开启';

  @override
  String get composeChoosePenPal => '写给笔友';

  @override
  String get composeChoosePenPalSub => 'DIRECT — 寄给认识的人';

  @override
  String get composeChooseTopic => '写给主题信箱';

  @override
  String get composeChooseTopicSub => '从今日话题开始表达';

  @override
  String get composeChoosePostOffice => '寄往邮局';

  @override
  String get composeChoosePostOfficeSub => 'POST_OFFICE — 不选收件人，等待匹配';

  @override
  String get composeBodySubtitlePostOffice => '放心写吧——邮局会帮你找到读者。';

  @override
  String get composePostOfficeSendHint => '这封信将进入邮局匹配池';

  @override
  String get composePickDestinationRequired => '请先选择写信对象';

  @override
  String get composeStepPenPalTitle => '选择一位笔友';

  @override
  String get composeStepPenPalSubtitle => '先从已建立联系的朋友里选。若还没有笔友，可以先去笔友大厅。';

  @override
  String get composePickPenPalRequired => '请选择一位笔友';

  @override
  String get composePenPalEmptyTitle => '还没有笔友';

  @override
  String get composePenPalEmptySubtitle => '可以先去笔友大厅读资料，写第一封认真来信。';

  @override
  String get composePenPalLoadFailed => '笔友列表加载失败';

  @override
  String get composeGoDirectory => '去笔友大厅';

  @override
  String get composeStepTopicTitle => '选择主题';

  @override
  String get composeStepTopicSubtitle => '选一个温和的话题慢慢写。';

  @override
  String get composePickTopicRequired => '请选择一个主题';

  @override
  String get composeStepBodyTitle => '写下正文';

  @override
  String get composeBodyLabel => '信件正文';

  @override
  String get composeBodyFooter => '认真表达比字数多少更重要。';

  @override
  String get composeBodyRequired => '请先写下正文';

  @override
  String get composeBodySubtitleSelf => '写给未来的自己。可以是一段回忆、一个愿望，或今天的心情。';

  @override
  String composeBodySubtitlePenPal(Object name) {
    return '写给 $name 的一封认真来信。';
  }

  @override
  String composeBodySubtitleTimePenPal(Object name) {
    return '写给 $name 的时光信，会在选定日期送达。';
  }

  @override
  String get composeBodySubtitleTopic => '围绕所选主题，写下你想分享的内容。';

  @override
  String get composeStepDeliveryTitle => '选择送达日期';

  @override
  String get composeStepDeliverySubtitle => '时光信会在所选日期才拆阅。';

  @override
  String get composeStepMailTitle => '选择投递方式';

  @override
  String get composeStepMailSubtitle => '平邮与挂号均按延迟公式投递；挂号信可用邮票标记（VIP 免费）。';

  @override
  String get composeStepSealTitle => '封缄寄出';

  @override
  String get composeStepSealSubtitle => '滑动封缄后，信件进入等待送达。';

  @override
  String get composeStepSendTitle => '确认寄出';

  @override
  String get composeStepSendSubtitle => '寄出后可在「我的信箱」查看状态。';

  @override
  String get composeSendNow => '立即寄出';

  @override
  String get composeStepTopicSubmitTitle => '投进主题信箱';

  @override
  String get composeStepTopicSubmitSubtitle => '确认后投稿进入审核，通过后其他用户可见。';

  @override
  String get composeTopicSubmit => '投进主题信箱';

  @override
  String get composeTopicSubmitted => '已投进主题信箱，审核通过后会展示。';

  @override
  String get shopVipSectionTitle => '会员 · VIP';

  @override
  String get shopVipOwnedSubtitle => '您已是会员，可继续查看权益说明';

  @override
  String get shopVipPromoSubtitle => '开通会员可获得更多邮政能力与装扮权益';

  @override
  String get shopVipBody => '会员权益由服务端配置（如挂号信减免等）。支付与签约流程接入后将在此完成。';

  @override
  String get shopCatalogEmptyTitle => '暂无商品';

  @override
  String get shopCatalogEmptySubtitle => '运营配置商品后将在此展示。';

  @override
  String get shopMockPurchase => '模拟购买';

  @override
  String get shopMockPurchaseSuccess => '购买成功，权益已到账';

  @override
  String get shopOwned => '已拥有';

  @override
  String get shopPriceFree => '免费';

  @override
  String shopPriceAmount(Object amount) {
    return '¥$amount';
  }

  @override
  String get shopProductTypeSkin => '信纸皮肤';

  @override
  String get shopProductTypeFont => '字体';

  @override
  String get shopProductTypeTemplate => '模板';

  @override
  String get shopProductTypeVipBundle => '会员礼包';

  @override
  String get shopProductTypeExport => '导出';

  @override
  String get shopProductTypeAttachment => '附件';

  @override
  String get commerceProductSkinDefault => '默认信纸';

  @override
  String get commerceProductSkinVintage => '复古信纸';

  @override
  String get commerceProductFontDefault => '默认字体';

  @override
  String get commerceProductFontHandwriting => '手写体';

  @override
  String get commerceProductExportPdf => 'PDF 导出';

  @override
  String get entitlementsTitle => '我的装扮';

  @override
  String get entitlementsEmptyTitle => '还没有装扮';

  @override
  String get entitlementsEmptySubtitle => '前往商店挑选信纸、字体等表达增强商品。';

  @override
  String entitlementsGrantedAt(Object date) {
    return '获得于 $date';
  }

  @override
  String get profileLetterDrafts => '信件草稿';

  @override
  String get profileLetterFavorites => '信件收藏';

  @override
  String get profileLetterExport => '信件导出';

  @override
  String get profileMyEntitlements => '我的装扮';

  @override
  String get profilePrivacyHideRecommend => '屏蔽推荐';

  @override
  String get profilePrivacyRejectStranger => '拒收陌生信';

  @override
  String get letterDraftsTitle => '信件草稿';

  @override
  String get letterDraftsEmptyTitle => '暂无草稿';

  @override
  String get letterDraftsEmptySubtitle => '写信时可保存草稿，稍后再寄出。';

  @override
  String get letterDraftsSend => '发送';

  @override
  String get letterDraftsDelete => '删除';

  @override
  String get letterDraftsDeleted => '草稿已删除';

  @override
  String get letterDraftsNoContent => '（空草稿）';

  @override
  String letterDraftsUpdated(Object time) {
    return '更新于 $time';
  }

  @override
  String get letterFavoritesTitle => '信件收藏';

  @override
  String get letterFavoritesEmptyTitle => '暂无收藏';

  @override
  String get letterFavoritesEmptySubtitle => '在读信页点击星标即可收藏。';

  @override
  String get letterExportTitle => '信件导出';

  @override
  String get letterExportFromDate => '起始日期';

  @override
  String get letterExportToDate => '结束日期';

  @override
  String get letterExportDateOptional => '可选';

  @override
  String get letterExportSubmit => '生成导出';

  @override
  String get letterExportSuccess => '导出链接已生成';

  @override
  String get letterExportPending => '导出任务已提交';

  @override
  String get letterFavorite => '收藏';

  @override
  String get letterUnfavorite => '取消收藏';

  @override
  String get ritualOpenLetter => '有一封信等待拆阅';

  @override
  String get ritualDeliverySent => '信件已寄出';

  @override
  String get composeSkinPickerTitle => '选择信纸皮肤';

  @override
  String get settingsPreferencesSaved => '偏好已保存';

  @override
  String get quotaClaimTitle => '领取今日免费额度';

  @override
  String quotaClaimMessage(int count) {
    return '每天可免费寄出 $count 封信。请先领取今日额度后再写信。';
  }

  @override
  String get quotaClaimButton => '领取今日免费额度';

  @override
  String get firstLetterGuideTitle => '写给你的第一封信';

  @override
  String get firstLetterGuideSubtitle => '把一封真诚的信投进邮局，系统会帮你匹配一位有缘人。';

  @override
  String get firstLetterGuideHintTitle => '可以这样写';

  @override
  String get firstLetterGuideHintBody =>
      '介绍一下自己最近的心情、喜欢的小事，或想认识怎样的笔友。不必很长，真诚即可。';

  @override
  String get firstLetterGuideCta => '开始写第一封信';

  @override
  String get firstLetterGuideSkip => '稍后再写';

  @override
  String get firstLetterComposeHint => '这是你的第一封邮局信。可在下一步选择免费模板与信纸。';

  @override
  String get inTransitTitle => '信件在途';

  @override
  String get inTransitLoadFailed => '在途列表加载失败';

  @override
  String get inTransitEmptyTitle => '暂无在途信件';

  @override
  String get inTransitEmptySubtitle => '寄出或收到的信件会在这里显示进度。';

  @override
  String get inTransitSectionOutbound => '发出未达';

  @override
  String get inTransitSectionInbound => '收到未达';

  @override
  String get inTransitSectionUnread => '已送达未读';

  @override
  String get inTransitSectionEmpty => '本分类暂无信件';

  @override
  String inTransitEtaHours(int hours) {
    return '约 $hours 小时后到达';
  }

  @override
  String get writeDestinationTitle => '想写给谁？';

  @override
  String get writeDestinationPostOffice => '寄给有缘人';

  @override
  String get writeDestinationPostOfficeSub => '投进邮局，等待匹配一位笔友';

  @override
  String get writeDestinationSelfTime => '寄给未来的自己';

  @override
  String get writeDestinationSelfTimeSub => '时光信，到选定日期再拆阅';

  @override
  String get composeAddParagraph => '添加段落';

  @override
  String get composeRemoveParagraph => '删除段落';

  @override
  String composeParagraphLabel(int n) {
    return '第 $n 段';
  }

  @override
  String get composeTemplatePickerTitle => '写信模板';

  @override
  String get composeTemplateEmpty => '暂无可用模板';

  @override
  String get composeTemplateApplied => '已填入正文，可继续修改';

  @override
  String get composeStepMailSubtitleSkins => '选择信纸与模板；投递速度由距离与关系决定。';

  @override
  String get commerceProductSkinLinen => '亚麻信纸';

  @override
  String get commerceProductTemplateEmotion => '情感倾诉';

  @override
  String get commerceProductTemplateNarrative => '叙事随笔';

  @override
  String get authRegisterSummaryLocation => '定位';

  @override
  String get authRegisterLocationCaptured => '已获取（可选）';
}
