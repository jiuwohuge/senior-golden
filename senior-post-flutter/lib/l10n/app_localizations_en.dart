// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Senior Post';

  @override
  String get appTagline => 'Slow, kind letters — across the world.';

  @override
  String get tabPostWall => 'Post Wall';

  @override
  String get tabDirectory => 'Directory';

  @override
  String get tabMailbox => 'Post Box';

  @override
  String get tabProfile => 'My Post';

  @override
  String get a11yTabPostWall =>
      'Post Wall: browse postcards from members worldwide';

  @override
  String get a11yTabDirectory =>
      'Directory: find members by country and interests';

  @override
  String get a11yTabMailbox => 'Post Box: your letters and conversations';

  @override
  String get a11yTabProfile => 'My Post: your profile and account';

  @override
  String get a11yNavBar => 'Main sections of the app';

  @override
  String get placeholderWelcomeTitle => 'This area is being prepared';

  @override
  String get placeholderWelcomeBody =>
      'We are finishing this screen. Your postcards, letters, and friends will appear here soon. Thank you for your patience.';

  @override
  String get placeholderHint =>
      'Tip: use the bar below to switch between Post Wall, Directory, Post Box, and My Post.';

  @override
  String get postalMotifContentDescription =>
      'Decorative postmark in the header';

  @override
  String get authLoginTitle => 'Sign in';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authLoginSubmit => 'Sign in';

  @override
  String get authGoRegister => 'Create an account';

  @override
  String get authRegisterTitle => 'Create account';

  @override
  String get authNicknameLabel => 'Nickname';

  @override
  String get authBirthYearLabel => 'Year of birth';

  @override
  String get authCountryCodeLabel => 'Country code (optional)';

  @override
  String get authAgreeTerms => 'I agree to the Terms and Privacy Policy';

  @override
  String get authRegisterSubmit => 'Register';

  @override
  String get authGoLogin => 'Already have an account? Sign in';

  @override
  String get authFieldRequired => 'Please fill in this field';

  @override
  String get authPasswordTooShort => 'Password must be at least 8 characters';

  @override
  String get authAgreeRequired => 'Please accept the terms to continue';

  @override
  String get authBusy => 'Please wait…';
}
