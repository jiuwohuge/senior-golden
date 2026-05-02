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
  String get authMockTip => '当前为 Mock 模式，未接后端也可完整体验流程。';

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
  String get authOnboardingAgain => '查看功能引导';

  @override
  String get authEmailInvalid => '请输入有效邮箱地址';

  @override
  String get authRegisterSubtitle => '一分钟创建你的邮政社交账号。';

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
  String get legalEffectiveDate => '生效日期：2026-05-01';

  @override
  String get legalTermsContent =>
      '1）本应用面向 45+ 成年用户提供兴趣陪伴社交服务。\\n\\n2）本产品不提供婚恋与匹配服务。\\n\\n3）你需对发布内容负责，不得发布违法违规内容。\\n\\n4）对于骚扰、刷屏、欺诈等行为，平台可限制或封禁账号。\\n\\n5）平台提供举报和审核机制以维护安全交流环境。';

  @override
  String get legalPrivacyContent =>
      '1）我们会收集账号与设备信息用于安全风控与服务提供。\\n\\n2）我们依据适用隐私法规处理数据，并提供删除/导出路径。\\n\\n3）我们不会出售你的个人数据。\\n\\n4）部分数据处理用于实现核心消息与内容审核能力。\\n\\n5）你可联系支持申请账号删除与相关数据清理。';
}
