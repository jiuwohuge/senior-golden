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
  String get authCountryCodeLabel => 'Country (optional)';

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

  @override
  String get authCountrySkip => 'Skip';

  @override
  String get authBootstrapLoadFailed =>
      'Could not load signup options. Check your network and try again.';

  @override
  String get authRetry => 'Retry';

  @override
  String get authBirthYearRangeError =>
      'Birth year list is empty. Check server config for minimum age.';

  @override
  String get authWelcomeBack => 'Welcome back to your global post office.';

  @override
  String get authMockTip =>
      'Mock mode is enabled. You can try all flows without backend APIs.';

  @override
  String authAgreeTpl(Object privacy, Object terms) {
    return 'I have read and agree to $terms and $privacy.';
  }

  @override
  String get authTermsTitle => 'Terms of Service';

  @override
  String get authPrivacyTitle => 'Privacy Policy';

  @override
  String get authForgotPassword => 'Forgot password';

  @override
  String get authOnboardingAgain => 'View introduction';

  @override
  String get authEmailInvalid => 'Please enter a valid email address';

  @override
  String get authRegisterSubtitle =>
      'Create your postal social account in one minute.';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authPasswordNotMatch => 'Passwords do not match';

  @override
  String get authBirthYearRequired => 'Please choose your year of birth';

  @override
  String get authForgotStepEmail => 'Email';

  @override
  String get authForgotStepCode => 'Code';

  @override
  String get authForgotStepDone => 'Done';

  @override
  String get authForgotSendCode => 'Send reset email';

  @override
  String get authForgotMailSent => 'Reset instructions have been sent.';

  @override
  String get authForgotCode => 'Verification code';

  @override
  String get authForgotNewPassword => 'New password';

  @override
  String get authForgotResetNow => 'Reset password';

  @override
  String get authForgotDoneTitle => 'Password reset complete';

  @override
  String get authForgotDoneBody =>
      'You can now return to login and sign in with your new password.';

  @override
  String get authBackToLogin => 'Back to login';

  @override
  String get onboardTitle1 => 'A global postal social network';

  @override
  String get onboardBody1 =>
      'Meet peers worldwide in a calm, respectful, non-dating environment.';

  @override
  String get onboardTitle2 => 'Slow letters, real companionship';

  @override
  String get onboardBody2 =>
      'Send postcards and letters at your own pace. No like-count pressure.';

  @override
  String get onboardTitle3 => 'Trusted and age-friendly';

  @override
  String get onboardBody3 =>
      'Designed for 45+ users with clear typography, calm colors and privacy-first defaults.';

  @override
  String get onboardSkip => 'Skip';

  @override
  String get onboardNext => 'Next';

  @override
  String get onboardDone => 'Start now';

  @override
  String get legalEffectiveDate => 'Effective date: 2026-05-01';

  @override
  String get legalTermsContent =>
      '1) This app provides interest-based social communication for adults aged 45+ only.\\n\\n2) The product does not provide dating or matchmaking services.\\n\\n3) You are responsible for the legality of your content and must not publish prohibited content.\\n\\n4) We may suspend accounts for abuse, harassment, spam, fraud, or policy violations.\\n\\n5) We provide moderation and reporting mechanisms to maintain a safe communication environment.';

  @override
  String get legalPrivacyContent =>
      '1) We collect account and device information required for security and fraud prevention.\\n\\n2) We process your data under applicable privacy laws and provide deletion/export pathways.\\n\\n3) We never sell personal data.\\n\\n4) Some data processing is required to deliver core messaging and moderation services.\\n\\n5) You can contact support to request account deletion and related data removal.';
}
