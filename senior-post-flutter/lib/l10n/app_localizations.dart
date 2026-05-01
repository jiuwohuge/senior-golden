import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// Application name shown in task switcher and about screens.
  ///
  /// In en, this message translates to:
  /// **'Senior Post'**
  String get appTitle;

  /// Short brand line under the app name; postal / pen-pal tone.
  ///
  /// In en, this message translates to:
  /// **'Slow, kind letters — across the world.'**
  String get appTagline;

  /// Bottom navigation: global postcard feed.
  ///
  /// In en, this message translates to:
  /// **'Post Wall'**
  String get tabPostWall;

  /// Bottom navigation: directory of members.
  ///
  /// In en, this message translates to:
  /// **'Directory'**
  String get tabDirectory;

  /// Bottom navigation: messages and letters.
  ///
  /// In en, this message translates to:
  /// **'Post Box'**
  String get tabMailbox;

  /// Bottom navigation: profile and settings.
  ///
  /// In en, this message translates to:
  /// **'My Post'**
  String get tabProfile;

  /// No description provided for @a11yTabPostWall.
  ///
  /// In en, this message translates to:
  /// **'Post Wall: browse postcards from members worldwide'**
  String get a11yTabPostWall;

  /// No description provided for @a11yTabDirectory.
  ///
  /// In en, this message translates to:
  /// **'Directory: find members by country and interests'**
  String get a11yTabDirectory;

  /// No description provided for @a11yTabMailbox.
  ///
  /// In en, this message translates to:
  /// **'Post Box: your letters and conversations'**
  String get a11yTabMailbox;

  /// No description provided for @a11yTabProfile.
  ///
  /// In en, this message translates to:
  /// **'My Post: your profile and account'**
  String get a11yTabProfile;

  /// No description provided for @a11yNavBar.
  ///
  /// In en, this message translates to:
  /// **'Main sections of the app'**
  String get a11yNavBar;

  /// No description provided for @placeholderWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'This area is being prepared'**
  String get placeholderWelcomeTitle;

  /// No description provided for @placeholderWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'We are finishing this screen. Your postcards, letters, and friends will appear here soon. Thank you for your patience.'**
  String get placeholderWelcomeBody;

  /// No description provided for @placeholderHint.
  ///
  /// In en, this message translates to:
  /// **'Tip: use the bar below to switch between Post Wall, Directory, Post Box, and My Post.'**
  String get placeholderHint;

  /// No description provided for @postalMotifContentDescription.
  ///
  /// In en, this message translates to:
  /// **'Decorative postmark in the header'**
  String get postalMotifContentDescription;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLoginTitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authLoginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLoginSubmit;

  /// No description provided for @authGoRegister.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get authGoRegister;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authRegisterTitle;

  /// No description provided for @authNicknameLabel.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get authNicknameLabel;

  /// No description provided for @authBirthYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Year of birth'**
  String get authBirthYearLabel;

  /// No description provided for @authCountryCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Country (optional)'**
  String get authCountryCodeLabel;

  /// No description provided for @authAgreeTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms and Privacy Policy'**
  String get authAgreeTerms;

  /// No description provided for @authRegisterSubmit.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegisterSubmit;

  /// No description provided for @authGoLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get authGoLogin;

  /// No description provided for @authFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill in this field'**
  String get authFieldRequired;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get authPasswordTooShort;

  /// No description provided for @authAgreeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms to continue'**
  String get authAgreeRequired;

  /// No description provided for @authBusy.
  ///
  /// In en, this message translates to:
  /// **'Please wait…'**
  String get authBusy;

  /// No description provided for @authCountrySkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get authCountrySkip;

  /// No description provided for @authBootstrapLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load signup options. Check your network and try again.'**
  String get authBootstrapLoadFailed;

  /// No description provided for @authRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get authRetry;

  /// No description provided for @authBirthYearRangeError.
  ///
  /// In en, this message translates to:
  /// **'Birth year list is empty. Check server config for minimum age.'**
  String get authBirthYearRangeError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
