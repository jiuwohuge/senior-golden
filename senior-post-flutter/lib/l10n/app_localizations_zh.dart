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
  String get authCountryCodeLabel => '国家代码（选填）';

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
}
