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
  /// **'A calm post office for trusted pen pals.'**
  String get appTagline;

  /// Bottom navigation: post office home.
  ///
  /// In en, this message translates to:
  /// **'Post Office'**
  String get tabPostWall;

  /// Bottom navigation: discover and manage pen pals.
  ///
  /// In en, this message translates to:
  /// **'Pen Pals'**
  String get tabDirectory;

  /// Bottom navigation: letter history.
  ///
  /// In en, this message translates to:
  /// **'Mailbox'**
  String get tabMailbox;

  /// Bottom navigation: personal profile and settings
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get tabProfile;

  /// No description provided for @a11yTabPostWall.
  ///
  /// In en, this message translates to:
  /// **'Post Office: write letters, messages and in-transit mail'**
  String get a11yTabPostWall;

  /// No description provided for @a11yTabDirectory.
  ///
  /// In en, this message translates to:
  /// **'Pen Pals: recommendations, search and my pen pals'**
  String get a11yTabDirectory;

  /// No description provided for @a11yTabMailbox.
  ///
  /// In en, this message translates to:
  /// **'Mailbox: received, sent and time letters'**
  String get a11yTabMailbox;

  /// No description provided for @postOfficeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get postOfficeGreeting;

  /// No description provided for @postOfficeTodayHint.
  ///
  /// In en, this message translates to:
  /// **'Write your first letter and wait for a reply'**
  String get postOfficeTodayHint;

  /// No description provided for @postOfficeWritePostOfficeWaitHint.
  ///
  /// In en, this message translates to:
  /// **'To a kindred spirit (waiting required)'**
  String get postOfficeWritePostOfficeWaitHint;

  /// No description provided for @mailboxMyPenpals.
  ///
  /// In en, this message translates to:
  /// **'My pen pals'**
  String get mailboxMyPenpals;

  /// No description provided for @bindAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Bind account'**
  String get bindAccountTitle;

  /// No description provided for @bindAccountHint.
  ///
  /// In en, this message translates to:
  /// **'Bind an email or Google account so you can keep your letters if you change phones.'**
  String get bindAccountHint;

  /// No description provided for @bindAccountSubmit.
  ///
  /// In en, this message translates to:
  /// **'Bind'**
  String get bindAccountSubmit;

  /// No description provided for @bindChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change binding'**
  String get bindChangeTitle;

  /// No description provided for @bindChangeHint.
  ///
  /// In en, this message translates to:
  /// **'Your letters stay on this account. After you change, sign in with the new email or Google next time.'**
  String get bindChangeHint;

  /// No description provided for @bindChangeCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current return address'**
  String get bindChangeCurrentLabel;

  /// No description provided for @bindAccountSubmitChange.
  ///
  /// In en, this message translates to:
  /// **'Change binding'**
  String get bindAccountSubmitChange;

  /// No description provided for @bindMethodEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get bindMethodEmail;

  /// No description provided for @bindMethodGoogle.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get bindMethodGoogle;

  /// No description provided for @bindGoogleSubmit.
  ///
  /// In en, this message translates to:
  /// **'Bind with Google'**
  String get bindGoogleSubmit;

  /// No description provided for @bindGoogleSubmitChange.
  ///
  /// In en, this message translates to:
  /// **'Switch to Google'**
  String get bindGoogleSubmitChange;

  /// No description provided for @bindGoogleHint.
  ///
  /// In en, this message translates to:
  /// **'Use your Google account. You can sign in on a new phone with the same Google ID.'**
  String get bindGoogleHint;

  /// No description provided for @bindCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get bindCodeLabel;

  /// No description provided for @bindCodeHint.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get bindCodeHint;

  /// No description provided for @bindSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get bindSendCode;

  /// No description provided for @bindCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Code sent. Please check your inbox.'**
  String get bindCodeSent;

  /// No description provided for @bindSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set'**
  String get bindSuccessTitle;

  /// No description provided for @bindSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Your account is saved. On a new phone, sign in with the same email or Google account to keep your letters.'**
  String get bindSuccessBody;

  /// No description provided for @bindSuccessChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Binding updated'**
  String get bindSuccessChangeTitle;

  /// No description provided for @bindSuccessChangeBody.
  ///
  /// In en, this message translates to:
  /// **'Next time, sign in with the new email or Google. Your letters stay on this account.'**
  String get bindSuccessChangeBody;

  /// No description provided for @bindSuccessOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get bindSuccessOk;

  /// No description provided for @bindPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Your letter is on its way'**
  String get bindPromptTitle;

  /// No description provided for @bindPromptBody.
  ///
  /// In en, this message translates to:
  /// **'Bind an account so you don’t lose letters if you switch phones. You can skip for now.'**
  String get bindPromptBody;

  /// No description provided for @bindPromptLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get bindPromptLater;

  /// No description provided for @bindPromptNow.
  ///
  /// In en, this message translates to:
  /// **'Bind now'**
  String get bindPromptNow;

  /// No description provided for @composeOneSentenceHint.
  ///
  /// In en, this message translates to:
  /// **'Even one sentence is enough'**
  String get composeOneSentenceHint;

  /// No description provided for @profileBindAccount.
  ///
  /// In en, this message translates to:
  /// **'Bind account'**
  String get profileBindAccount;

  /// No description provided for @profileReturnAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Return address'**
  String get profileReturnAddressLabel;

  /// No description provided for @profileReturnAddressBind.
  ///
  /// In en, this message translates to:
  /// **'Bind'**
  String get profileReturnAddressBind;

  /// No description provided for @profileReturnAddressChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get profileReturnAddressChange;

  /// No description provided for @profileReturnAddressEmpty.
  ///
  /// In en, this message translates to:
  /// **'Not set yet'**
  String get profileReturnAddressEmpty;

  /// No description provided for @bindRegisteredReadonlyHint.
  ///
  /// In en, this message translates to:
  /// **'This is your sign-in email. It cannot be changed here. Use Forgot password to reset the password.'**
  String get bindRegisteredReadonlyHint;

  /// No description provided for @profileBindAccountUnboundHint.
  ///
  /// In en, this message translates to:
  /// **'Bind so you can keep letters on a new phone'**
  String get profileBindAccountUnboundHint;

  /// No description provided for @profileBindAccountBoundHint.
  ///
  /// In en, this message translates to:
  /// **'Bound. Tap to change'**
  String get profileBindAccountBoundHint;

  /// No description provided for @profileBindAccountBoundEmail.
  ///
  /// In en, this message translates to:
  /// **'Bound to {email}. Tap to change'**
  String profileBindAccountBoundEmail(String email);

  /// No description provided for @profileBindAccountBoundGoogle.
  ///
  /// In en, this message translates to:
  /// **'Bound to Google. Tap to change'**
  String get profileBindAccountBoundGoogle;

  /// No description provided for @profileBindAccountBoundGoogleEmail.
  ///
  /// In en, this message translates to:
  /// **'Bound to Google ({email}). Tap to change'**
  String profileBindAccountBoundGoogleEmail(String email);

  /// No description provided for @profileBindStampPosted.
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get profileBindStampPosted;

  /// No description provided for @authContinueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue without signing in'**
  String get authContinueAsGuest;

  /// No description provided for @postOfficeWriteLetter.
  ///
  /// In en, this message translates to:
  /// **'Write a letter'**
  String get postOfficeWriteLetter;

  /// No description provided for @postOfficeFreeQuotaHint.
  ///
  /// In en, this message translates to:
  /// **'{count} free letters left today'**
  String postOfficeFreeQuotaHint(int count);

  /// No description provided for @postOfficeMessagesSummary.
  ///
  /// In en, this message translates to:
  /// **'Messages · {count}'**
  String postOfficeMessagesSummary(int count);

  /// No description provided for @postOfficeInTransitSummary.
  ///
  /// In en, this message translates to:
  /// **'In transit · {count}'**
  String postOfficeInTransitSummary(int count);

  /// No description provided for @a11yTabProfile.
  ///
  /// In en, this message translates to:
  /// **'Me: profile, saved letters and settings'**
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
  /// **'Tip: use the bar below to switch between Topics, Pen Pals, My Mailbox, and Memorial.'**
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

  /// No description provided for @authWelcomeRegister.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authWelcomeRegister;

  /// No description provided for @authWelcomeLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authWelcomeLogin;

  /// No description provided for @authWelcomeHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authWelcomeHaveAccount;

  /// No description provided for @authWelcomeHighlightLetters.
  ///
  /// In en, this message translates to:
  /// **'Write and receive real letters at a calm pace'**
  String get authWelcomeHighlightLetters;

  /// No description provided for @authWelcomeHighlightDirectory.
  ///
  /// In en, this message translates to:
  /// **'Meet pen pals worldwide in the hall'**
  String get authWelcomeHighlightDirectory;

  /// No description provided for @authWelcomeHighlightPace.
  ///
  /// In en, this message translates to:
  /// **'Designed for adults 45 and over'**
  String get authWelcomeHighlightPace;

  /// No description provided for @authWelcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Letters at your pace — for adults 45+'**
  String get authWelcomeTagline;

  /// No description provided for @authWelcomeLegalFooter.
  ///
  /// In en, this message translates to:
  /// **'By signing up, you accept our {terms} and {privacy}.'**
  String authWelcomeLegalFooter(Object privacy, Object terms);

  /// No description provided for @authRegisterWizardEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your email?'**
  String get authRegisterWizardEmailTitle;

  /// No description provided for @authRegisterWizardEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll use it for sign-in and important notices about your letters.'**
  String get authRegisterWizardEmailSubtitle;

  /// No description provided for @authRegisterWizardPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a password'**
  String get authRegisterWizardPasswordTitle;

  /// No description provided for @authRegisterWizardPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters. Keep it somewhere safe.'**
  String get authRegisterWizardPasswordSubtitle;

  /// No description provided for @authRegisterWizardNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get authRegisterWizardNameTitle;

  /// No description provided for @authRegisterWizardNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This name appears on letters and your pen-pal profile.'**
  String get authRegisterWizardNameSubtitle;

  /// No description provided for @authRegisterWizardGenderTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you identify?'**
  String get authRegisterWizardGenderTitle;

  /// No description provided for @authRegisterWizardGenderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Helps us show you the right pen pals.'**
  String get authRegisterWizardGenderSubtitle;

  /// No description provided for @authRegisterWizardAgeTitle.
  ///
  /// In en, this message translates to:
  /// **'How old are you?'**
  String get authRegisterWizardAgeTitle;

  /// No description provided for @authRegisterWizardAgeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your birth year helps us tailor the community for 45+.'**
  String get authRegisterWizardAgeSubtitle;

  /// No description provided for @authRegisterProfileHint.
  ///
  /// In en, this message translates to:
  /// **'This info shows on your profile.'**
  String get authRegisterProfileHint;

  /// No description provided for @authRegisterAgePreview.
  ///
  /// In en, this message translates to:
  /// **'I\'m {age}'**
  String authRegisterAgePreview(Object age);

  /// No description provided for @authRegisterSummaryGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get authRegisterSummaryGender;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authOrContinueWithEmail.
  ///
  /// In en, this message translates to:
  /// **'or sign in with email'**
  String get authOrContinueWithEmail;

  /// No description provided for @authGoogleNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in is not configured yet'**
  String get authGoogleNotConfigured;

  /// No description provided for @authGenderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get authGenderLabel;

  /// No description provided for @authGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get authGenderMale;

  /// No description provided for @authGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get authGenderFemale;

  /// No description provided for @authRegisterAvatarOptional.
  ///
  /// In en, this message translates to:
  /// **'Profile photo (optional)'**
  String get authRegisterAvatarOptional;

  /// No description provided for @authRegisterAvatarSkipHint.
  ///
  /// In en, this message translates to:
  /// **'You can skip and add a photo later in My Post.'**
  String get authRegisterAvatarSkipHint;

  /// No description provided for @authRegisterWizardAvatarTitle.
  ///
  /// In en, this message translates to:
  /// **'Show us your smile'**
  String get authRegisterWizardAvatarTitle;

  /// No description provided for @authRegisterWizardAvatarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a friendly photo of yourself — a smile goes a long way.'**
  String get authRegisterWizardAvatarSubtitle;

  /// No description provided for @authRegisterAvatarTapToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap to add a photo'**
  String get authRegisterAvatarTapToAdd;

  /// No description provided for @authRegisterAvatarAgreeFirst.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms below before uploading a photo'**
  String get authRegisterAvatarAgreeFirst;

  /// No description provided for @authRegisterAvatarUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading photo…'**
  String get authRegisterAvatarUploading;

  /// No description provided for @authRegisterAvatarUploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get authRegisterAvatarUploaded;

  /// No description provided for @authRegisterSummaryAvatarPending.
  ///
  /// In en, this message translates to:
  /// **'Selected, pending upload'**
  String get authRegisterSummaryAvatarPending;

  /// No description provided for @authRegisterSummaryAvatar.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get authRegisterSummaryAvatar;

  /// No description provided for @authRegisterSummaryAvatarSet.
  ///
  /// In en, this message translates to:
  /// **'Selected — uploads after sign-up'**
  String get authRegisterSummaryAvatarSet;

  /// No description provided for @authRegisterSummaryAvatarSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get authRegisterSummaryAvatarSkipped;

  /// No description provided for @authSocialCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get authSocialCompleteTitle;

  /// No description provided for @directoryFilterGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get directoryFilterGender;

  /// No description provided for @directoryFilterGenderHint.
  ///
  /// In en, this message translates to:
  /// **'Optional — leave all selected to show everyone.'**
  String get directoryFilterGenderHint;

  /// No description provided for @directoryFilterGenderAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get directoryFilterGenderAll;

  /// No description provided for @directoryFilterInterests.
  ///
  /// In en, this message translates to:
  /// **'Interest tags'**
  String get directoryFilterInterests;

  /// No description provided for @directoryFilterInterestsHint.
  ///
  /// In en, this message translates to:
  /// **'Optional — pick one or more to narrow pen pals by shared hobbies.'**
  String get directoryFilterInterestsHint;

  /// No description provided for @directoryFilterInterestsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No interest tags from the server. Try another language or ask an admin to add tags.'**
  String get directoryFilterInterestsEmpty;

  /// No description provided for @directoryFilterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get directoryFilterApply;

  /// No description provided for @directoryFilterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get directoryFilterClear;

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

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back to your global post office.'**
  String get authWelcomeBack;

  /// No description provided for @authMockTip.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your registered email to use all features.'**
  String get authMockTip;

  /// No description provided for @authAgreeTpl.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to {terms} and {privacy}.'**
  String authAgreeTpl(Object privacy, Object terms);

  /// No description provided for @authTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get authTermsTitle;

  /// No description provided for @authPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get authPrivacyTitle;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get authForgotPassword;

  /// No description provided for @authForgotIntro.
  ///
  /// In en, this message translates to:
  /// **'We\'ll email a 6-digit code to your registered address. In local dev, check server logs if SMTP is not configured.'**
  String get authForgotIntro;

  /// No description provided for @authForgotCodeHint.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get authForgotCodeHint;

  /// No description provided for @authForgotResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated. You can sign in now.'**
  String get authForgotResetSuccess;

  /// No description provided for @authForgotCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get authForgotCodeInvalid;

  /// No description provided for @authOnboardingAgain.
  ///
  /// In en, this message translates to:
  /// **'View introduction'**
  String get authOnboardingAgain;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get authEmailInvalid;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your postal social account in one minute.'**
  String get authRegisterSubtitle;

  /// No description provided for @authRegisterWizardHint.
  ///
  /// In en, this message translates to:
  /// **'Tap any step below to jump — your entries stay until you submit.'**
  String get authRegisterWizardHint;

  /// No description provided for @authRegisterTabAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get authRegisterTabAccount;

  /// No description provided for @authRegisterTabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get authRegisterTabProfile;

  /// No description provided for @authRegisterTabInterests.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get authRegisterTabInterests;

  /// No description provided for @authRegisterTabReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get authRegisterTabReview;

  /// No description provided for @authRegisterStepProgress.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String authRegisterStepProgress(Object current, Object total);

  /// No description provided for @authRegisterStepAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign-in details'**
  String get authRegisterStepAccountTitle;

  /// No description provided for @authRegisterStepAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We’ll use your email to reach you about letters and security.'**
  String get authRegisterStepAccountSubtitle;

  /// No description provided for @authRegisterStepProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get authRegisterStepProfileTitle;

  /// No description provided for @authRegisterStepProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This is how you appear on letters and your pen-pal profile.'**
  String get authRegisterStepProfileSubtitle;

  /// No description provided for @authRegisterStepInterestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get authRegisterStepInterestsTitle;

  /// No description provided for @authRegisterStepInterestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose at least three tags — they power better pen-pal matches.'**
  String get authRegisterStepInterestsSubtitle;

  /// No description provided for @authRegisterStepReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review & terms'**
  String get authRegisterStepReviewTitle;

  /// No description provided for @authRegisterStepReviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your details, then accept the policies to open your account.'**
  String get authRegisterStepReviewSubtitle;

  /// No description provided for @authRegisterNext.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authRegisterNext;

  /// No description provided for @authRegisterBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get authRegisterBack;

  /// No description provided for @authRegisterSummaryEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authRegisterSummaryEmail;

  /// No description provided for @authRegisterSummaryNickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get authRegisterSummaryNickname;

  /// No description provided for @authRegisterSummaryBirth.
  ///
  /// In en, this message translates to:
  /// **'Year of birth'**
  String get authRegisterSummaryBirth;

  /// No description provided for @authRegisterSummaryCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get authRegisterSummaryCountry;

  /// No description provided for @authRegisterCountrySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search countries'**
  String get authRegisterCountrySearchHint;

  /// No description provided for @authRegisterSummaryInterests.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get authRegisterSummaryInterests;

  /// No description provided for @authRegisterInterestsMin.
  ///
  /// In en, this message translates to:
  /// **'Please select at least three interests.'**
  String get authRegisterInterestsMin;

  /// No description provided for @authRegisterInterestsServerEmpty.
  ///
  /// In en, this message translates to:
  /// **'No interest tags from the server. Try another language or ask an admin to add tags.'**
  String get authRegisterInterestsServerEmpty;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authPasswordNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authPasswordNotMatch;

  /// No description provided for @authBirthYearRequired.
  ///
  /// In en, this message translates to:
  /// **'Please choose your year of birth'**
  String get authBirthYearRequired;

  /// No description provided for @authForgotStepEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authForgotStepEmail;

  /// No description provided for @authForgotStepCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get authForgotStepCode;

  /// No description provided for @authForgotStepDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get authForgotStepDone;

  /// No description provided for @authForgotSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send reset email'**
  String get authForgotSendCode;

  /// No description provided for @authForgotMailSent.
  ///
  /// In en, this message translates to:
  /// **'Reset instructions have been sent.'**
  String get authForgotMailSent;

  /// No description provided for @authForgotCode.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get authForgotCode;

  /// No description provided for @authForgotNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authForgotNewPassword;

  /// No description provided for @authForgotResetNow.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get authForgotResetNow;

  /// No description provided for @authForgotDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Password reset complete'**
  String get authForgotDoneTitle;

  /// No description provided for @authForgotDoneBody.
  ///
  /// In en, this message translates to:
  /// **'You can now return to login and sign in with your new password.'**
  String get authForgotDoneBody;

  /// No description provided for @authBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get authBackToLogin;

  /// No description provided for @onboardTitle1.
  ///
  /// In en, this message translates to:
  /// **'A global postal social network'**
  String get onboardTitle1;

  /// No description provided for @onboardBody1.
  ///
  /// In en, this message translates to:
  /// **'Meet peers worldwide in a calm, respectful, non-dating environment.'**
  String get onboardBody1;

  /// No description provided for @onboardTitle2.
  ///
  /// In en, this message translates to:
  /// **'Slow letters, real companionship'**
  String get onboardTitle2;

  /// No description provided for @onboardBody2.
  ///
  /// In en, this message translates to:
  /// **'Exchange slow-mail letters at your own pace. No like-count pressure.'**
  String get onboardBody2;

  /// No description provided for @onboardTitle3.
  ///
  /// In en, this message translates to:
  /// **'Trusted and age-friendly'**
  String get onboardTitle3;

  /// No description provided for @onboardBody3.
  ///
  /// In en, this message translates to:
  /// **'Designed for 45+ users with clear typography, calm colors and privacy-first defaults.'**
  String get onboardBody3;

  /// No description provided for @onboardSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardSkip;

  /// No description provided for @onboardNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardNext;

  /// No description provided for @onboardDone.
  ///
  /// In en, this message translates to:
  /// **'Start now'**
  String get onboardDone;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @postWallUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Post wall is temporarily unavailable'**
  String get postWallUnavailable;

  /// No description provided for @postWallEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No postcards yet'**
  String get postWallEmptyTitle;

  /// No description provided for @postWallEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Be the first to share a postcard today.'**
  String get postWallEmptySubtitle;

  /// No description provided for @postWallWriteAction.
  ///
  /// In en, this message translates to:
  /// **'Write postcard'**
  String get postWallWriteAction;

  /// No description provided for @postWallFAB.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get postWallFAB;

  /// No description provided for @postWallFeedEveryone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get postWallFeedEveryone;

  /// No description provided for @postWallFeedConnections.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get postWallFeedConnections;

  /// No description provided for @postWallEmptyConnectionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No postcards from your postal friends yet. Connect through letters first.'**
  String get postWallEmptyConnectionsSubtitle;

  /// No description provided for @userCardFriendPostcardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Their postcards'**
  String get userCardFriendPostcardsTitle;

  /// No description provided for @userCardFriendPostcardsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recent posts from your postal friend'**
  String get userCardFriendPostcardsSubtitle;

  /// No description provided for @userCardFriendPostcardsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No public postcards yet'**
  String get userCardFriendPostcardsEmpty;

  /// No description provided for @userCardLoadMorePostcards.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get userCardLoadMorePostcards;

  /// No description provided for @postComposeRejected.
  ///
  /// In en, this message translates to:
  /// **'Your postcard was not approved. Please revise and try again.'**
  String get postComposeRejected;

  /// No description provided for @postWallPhotosLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} photos'**
  String postWallPhotosLabel(Object count);

  /// No description provided for @postWallSendLetterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Send letter'**
  String get postWallSendLetterTooltip;

  /// No description provided for @postWallCommentsCount.
  ///
  /// In en, this message translates to:
  /// **'Comments {count}'**
  String postWallCommentsCount(Object count);

  /// No description provided for @postComposeTitle.
  ///
  /// In en, this message translates to:
  /// **'Write postcard'**
  String get postComposeTitle;

  /// No description provided for @postComposeSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Compose'**
  String get postComposeSectionTitle;

  /// No description provided for @postComposeSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Write one postcard for today'**
  String get postComposeSectionSubtitle;

  /// No description provided for @postComposeContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Postcard content'**
  String get postComposeContentLabel;

  /// No description provided for @postComposeContentHint.
  ///
  /// In en, this message translates to:
  /// **'Write your day, thoughts, or greetings…'**
  String get postComposeContentHint;

  /// No description provided for @postComposeMaxImages.
  ///
  /// In en, this message translates to:
  /// **'At most {max} images'**
  String postComposeMaxImages(Object max);

  /// No description provided for @postComposeUploadNeedRealApi.
  ///
  /// In en, this message translates to:
  /// **'Image upload needs a server-issued URL. Check your network and try again.'**
  String get postComposeUploadNeedRealApi;

  /// No description provided for @postComposePickerChannelError.
  ///
  /// In en, this message translates to:
  /// **'Gallery channel not connected. Fully stop the app and run again; if it persists run flutter clean.'**
  String get postComposePickerChannelError;

  /// No description provided for @postComposeImageUploaded.
  ///
  /// In en, this message translates to:
  /// **'Image uploaded'**
  String get postComposeImageUploaded;

  /// No description provided for @postComposeNeedContent.
  ///
  /// In en, this message translates to:
  /// **'Please write something first.'**
  String get postComposeNeedContent;

  /// No description provided for @postComposePublishedMock.
  ///
  /// In en, this message translates to:
  /// **'Postcard submitted.'**
  String get postComposePublishedMock;

  /// No description provided for @postComposePublishedReal.
  ///
  /// In en, this message translates to:
  /// **'Submitted for review. It will appear after approval.'**
  String get postComposePublishedReal;

  /// No description provided for @postComposeUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get postComposeUploading;

  /// No description provided for @postComposeAddImage.
  ///
  /// In en, this message translates to:
  /// **'Add image (OSS)'**
  String get postComposeAddImage;

  /// No description provided for @postComposeAddAnother.
  ///
  /// In en, this message translates to:
  /// **'Add another ({n}/{max})'**
  String postComposeAddAnother(Object n, Object max);

  /// No description provided for @postComposePublish.
  ///
  /// In en, this message translates to:
  /// **'Publish now'**
  String get postComposePublish;

  /// No description provided for @postcardImageCropTitle.
  ///
  /// In en, this message translates to:
  /// **'Crop image (4:3)'**
  String get postcardImageCropTitle;

  /// No description provided for @postcardImageCropHelp.
  ///
  /// In en, this message translates to:
  /// **'Pan and zoom, then confirm to crop to 4:3 and upload.'**
  String get postcardImageCropHelp;

  /// No description provided for @profileBlacklist.
  ///
  /// In en, this message translates to:
  /// **'Blocked users'**
  String get profileBlacklist;

  /// No description provided for @settingsFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get settingsFeedback;

  /// No description provided for @dialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get dialogConfirm;

  /// No description provided for @socialBlockUser.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get socialBlockUser;

  /// No description provided for @socialBlockConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Block this user?'**
  String get socialBlockConfirmTitle;

  /// No description provided for @socialBlockConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'They won\'t be able to send you letters, and you won\'t see each other on the wall or directory.'**
  String get socialBlockConfirmMessage;

  /// No description provided for @socialBlockSuccess.
  ///
  /// In en, this message translates to:
  /// **'User blocked'**
  String get socialBlockSuccess;

  /// No description provided for @socialUnblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get socialUnblock;

  /// No description provided for @socialUnblockConfirm.
  ///
  /// In en, this message translates to:
  /// **'Unblock {name}?'**
  String socialUnblockConfirm(Object name);

  /// No description provided for @socialUnblockSuccess.
  ///
  /// In en, this message translates to:
  /// **'Unblocked'**
  String get socialUnblockSuccess;

  /// No description provided for @socialBlacklistTitle.
  ///
  /// In en, this message translates to:
  /// **'Blocked users'**
  String get socialBlacklistTitle;

  /// No description provided for @socialBlacklistSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Blocked users won\'t appear on the wall or directory and can\'t send you letters.'**
  String get socialBlacklistSubtitle;

  /// No description provided for @socialBlacklistEmpty.
  ///
  /// In en, this message translates to:
  /// **'No blocked users'**
  String get socialBlacklistEmpty;

  /// No description provided for @socialBlockedAt.
  ///
  /// In en, this message translates to:
  /// **'Blocked at: {time}'**
  String socialBlockedAt(Object time);

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackTitle;

  /// No description provided for @feedbackBodyLabel.
  ///
  /// In en, this message translates to:
  /// **'Your message (required)'**
  String get feedbackBodyLabel;

  /// No description provided for @feedbackBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Describe steps, what you expected, and what happened.'**
  String get feedbackBodyHint;

  /// No description provided for @feedbackSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get feedbackSubmit;

  /// No description provided for @feedbackSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting…'**
  String get feedbackSubmitting;

  /// No description provided for @feedbackSuccess.
  ///
  /// In en, this message translates to:
  /// **'Thanks — we\'ll review it soon.'**
  String get feedbackSuccess;

  /// No description provided for @feedbackNeedContent.
  ///
  /// In en, this message translates to:
  /// **'Please enter your feedback.'**
  String get feedbackNeedContent;

  /// No description provided for @userCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Member profile'**
  String get userCardTitle;

  /// No description provided for @userCardSendLetter.
  ///
  /// In en, this message translates to:
  /// **'Send letter'**
  String get userCardSendLetter;

  /// No description provided for @userCardBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get userCardBack;

  /// No description provided for @userCardBioSection.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get userCardBioSection;

  /// No description provided for @userCardBioEmpty.
  ///
  /// In en, this message translates to:
  /// **'No introduction yet.'**
  String get userCardBioEmpty;

  /// No description provided for @userCardReportUser.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get userCardReportUser;

  /// No description provided for @userCardReportSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Report this member'**
  String get userCardReportSheetTitle;

  /// No description provided for @userCardErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile'**
  String get userCardErrorTitle;

  /// No description provided for @userCardNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile not found'**
  String get userCardNotFoundTitle;

  /// No description provided for @userCardNotFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This member may be unavailable or restricted for you.'**
  String get userCardNotFoundSubtitle;

  /// No description provided for @directoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Pen Pal Hall'**
  String get directoryTitle;

  /// No description provided for @directorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read a profile first, then write one thoughtful letter. This is not fast matching.'**
  String get directorySubtitle;

  /// No description provided for @directoryFilterCta.
  ///
  /// In en, this message translates to:
  /// **'Filter pen pals'**
  String get directoryFilterCta;

  /// No description provided for @directorySafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Letters before anything else'**
  String get directorySafetyTitle;

  /// No description provided for @directorySafetyBody.
  ///
  /// In en, this message translates to:
  /// **'Profiles are only a beginning. Avoid money, investment, verification codes, and private contact requests until trust is real.'**
  String get directorySafetyBody;

  /// No description provided for @directoryListTitle.
  ///
  /// In en, this message translates to:
  /// **'People open to letters'**
  String get directoryListTitle;

  /// No description provided for @directoryListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose by story and shared interests, not by speed.'**
  String get directoryListSubtitle;

  /// No description provided for @directoryLetterFirstBadge.
  ///
  /// In en, this message translates to:
  /// **'Letter first'**
  String get directoryLetterFirstBadge;

  /// No description provided for @directoryViewProfile.
  ///
  /// In en, this message translates to:
  /// **'Read profile'**
  String get directoryViewProfile;

  /// No description provided for @directoryBioFallback.
  ///
  /// In en, this message translates to:
  /// **'This member has not written a self-introduction yet. You can read their interests before deciding whether to write.'**
  String get directoryBioFallback;

  /// No description provided for @directoryInterestEmpty.
  ///
  /// In en, this message translates to:
  /// **'Interests to be added'**
  String get directoryInterestEmpty;

  /// No description provided for @directoryMoreInterests.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String directoryMoreInterests(Object count);

  /// No description provided for @directoryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load directory'**
  String get directoryLoadFailed;

  /// No description provided for @directoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching members'**
  String get directoryEmptyTitle;

  /// No description provided for @directoryEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try clearing filters, or come back after new official topics bring more letters.'**
  String get directoryEmptySubtitle;

  /// No description provided for @directoryAgeYears.
  ///
  /// In en, this message translates to:
  /// **'{age} years old'**
  String directoryAgeYears(Object age);

  /// No description provided for @authBirthYearSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Year of birth'**
  String get authBirthYearSheetTitle;

  /// No description provided for @authBirthYearFormat.
  ///
  /// In en, this message translates to:
  /// **'{year} ({age})'**
  String authBirthYearFormat(Object year, Object age);

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get authEmailHint;

  /// No description provided for @profileEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditTitle;

  /// No description provided for @profileNickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get profileNickname;

  /// No description provided for @profileCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get profileCountry;

  /// No description provided for @profileBio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get profileBio;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSave;

  /// No description provided for @profileMockUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileMockUpdated;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @profileAvatarChange.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get profileAvatarChange;

  /// No description provided for @profileAvatarCropTitle.
  ///
  /// In en, this message translates to:
  /// **'Crop photo'**
  String get profileAvatarCropTitle;

  /// No description provided for @profileAvatarCropDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get profileAvatarCropDone;

  /// No description provided for @profileAvatarCropCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileAvatarCropCancel;

  /// No description provided for @profileAvatarCropConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm crop'**
  String get profileAvatarCropConfirm;

  /// No description provided for @profileAvatarCropHelp.
  ///
  /// In en, this message translates to:
  /// **'Drag and pinch to fit your face in the circle. Cancel returns without saving.'**
  String get profileAvatarCropHelp;

  /// No description provided for @profileAvatarPreviewHint.
  ///
  /// In en, this message translates to:
  /// **'Adjust the circle, then confirm crop. On the previous screen, tap Upload photo to save, or Discard to cancel.'**
  String get profileAvatarPreviewHint;

  /// No description provided for @profileAvatarConfirmUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload photo'**
  String get profileAvatarConfirmUpload;

  /// No description provided for @profileAvatarDiscardUpload.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get profileAvatarDiscardUpload;

  /// No description provided for @profileAvatarUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated'**
  String get profileAvatarUploadSuccess;

  /// No description provided for @profileAvatarUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not upload photo'**
  String get profileAvatarUploadFailed;

  /// No description provided for @profileAvatarUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading photo…'**
  String get profileAvatarUploading;

  /// No description provided for @profileAvatarAuditPending.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get profileAvatarAuditPending;

  /// No description provided for @profileAvatarAuditRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get profileAvatarAuditRejected;

  /// No description provided for @profileAvatarUploadPendingReview.
  ///
  /// In en, this message translates to:
  /// **'Photo submitted for review'**
  String get profileAvatarUploadPendingReview;

  /// No description provided for @profileAvatarRejectedHint.
  ///
  /// In en, this message translates to:
  /// **'Photo was not approved. Please upload again.'**
  String get profileAvatarRejectedHint;

  /// No description provided for @profileEditCancel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get profileEditCancel;

  /// No description provided for @profileEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditProfile;

  /// No description provided for @profileInterestTags.
  ///
  /// In en, this message translates to:
  /// **'Interest tags'**
  String get profileInterestTags;

  /// No description provided for @profileVipCenter.
  ///
  /// In en, this message translates to:
  /// **'VIP center'**
  String get profileVipCenter;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileAbout;

  /// No description provided for @profileUserAgreement.
  ///
  /// In en, this message translates to:
  /// **'User Agreement'**
  String get profileUserAgreement;

  /// No description provided for @profilePrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get profilePrivacyPolicy;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileLogout;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsPushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get settingsPushNotifications;

  /// No description provided for @settingsUnreadBadges.
  ///
  /// In en, this message translates to:
  /// **'Show unread badges'**
  String get settingsUnreadBadges;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow device by default; override for testing'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageChinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get settingsLanguageChinese;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow device'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsEmailVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify email'**
  String get settingsEmailVerify;

  /// No description provided for @settingsEmailVerifyPending.
  ///
  /// In en, this message translates to:
  /// **'Not verified — tap to bind'**
  String get settingsEmailVerifyPending;

  /// No description provided for @settingsEmailVerifyDone.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get settingsEmailVerifyDone;

  /// No description provided for @settingsEmailVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Email verification'**
  String get settingsEmailVerifyTitle;

  /// No description provided for @settingsEmailVerifyHint.
  ///
  /// In en, this message translates to:
  /// **'We will send a code to {email}'**
  String settingsEmailVerifyHint(String email);

  /// No description provided for @settingsEmailVerifyCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get settingsEmailVerifyCodeLabel;

  /// No description provided for @settingsEmailVerifySendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get settingsEmailVerifySendCode;

  /// No description provided for @settingsEmailVerifyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get settingsEmailVerifyConfirm;

  /// No description provided for @settingsEmailVerifyCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent'**
  String get settingsEmailVerifyCodeSent;

  /// No description provided for @settingsEmailVerifyCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the code'**
  String get settingsEmailVerifyCodeRequired;

  /// No description provided for @settingsEmailVerifySuccess.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get settingsEmailVerifySuccess;

  /// No description provided for @authLoginChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm it\'s you'**
  String get authLoginChallengeTitle;

  /// No description provided for @authLoginChallengeHint.
  ///
  /// In en, this message translates to:
  /// **'Unusual sign-in detected. Enter the code sent to your email.'**
  String get authLoginChallengeHint;

  /// No description provided for @authLoginChallengeSend.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get authLoginChallengeSend;

  /// No description provided for @authLoginChallengeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Verify and continue'**
  String get authLoginChallengeConfirm;

  /// No description provided for @authLoginChallengeCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Code sent'**
  String get authLoginChallengeCodeSent;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccount;

  /// No description provided for @legalEffectiveDate.
  ///
  /// In en, this message translates to:
  /// **'Effective date: 2026-05-01'**
  String get legalEffectiveDate;

  /// No description provided for @legalTermsContent.
  ///
  /// In en, this message translates to:
  /// **'1) This app provides interest-based social communication for adults aged 45+ only.\\n\\n2) The product does not provide dating or matchmaking services.\\n\\n3) You are responsible for the legality of your content and must not publish prohibited content.\\n\\n4) We may suspend accounts for abuse, harassment, spam, fraud, or policy violations.\\n\\n5) We provide moderation and reporting mechanisms to maintain a safe communication environment.'**
  String get legalTermsContent;

  /// No description provided for @legalPrivacyContent.
  ///
  /// In en, this message translates to:
  /// **'1) We collect account and device information required for security and fraud prevention.\\n\\n2) We process your data under applicable privacy laws and provide deletion/export pathways.\\n\\n3) We never sell personal data.\\n\\n4) Some data processing is required to deliver core messaging and moderation services.\\n\\n5) You can contact support to request account deletion and related data removal.'**
  String get legalPrivacyContent;

  /// No description provided for @vipCenterPurchaseDisabled.
  ///
  /// In en, this message translates to:
  /// **'VIP purchase is currently disabled.'**
  String get vipCenterPurchaseDisabled;

  /// No description provided for @vipCenterCheckoutNotWired.
  ///
  /// In en, this message translates to:
  /// **'Subscription checkout is not wired yet; benefits follow your account VIP flag.'**
  String get vipCenterCheckoutNotWired;

  /// No description provided for @vipCenterLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load VIP info: {error}'**
  String vipCenterLoadFailed(Object error);

  /// No description provided for @profileMyPostcards.
  ///
  /// In en, this message translates to:
  /// **'My postcards'**
  String get profileMyPostcards;

  /// No description provided for @myPostcardsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No postcards yet'**
  String get myPostcardsEmptyTitle;

  /// No description provided for @myPostcardsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Write one from the Post Wall tab — it will appear here with review status.'**
  String get myPostcardsEmptySubtitle;

  /// No description provided for @myPostcardsLoadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load postcards'**
  String get myPostcardsLoadFailedTitle;

  /// No description provided for @postcardReviewPendingBadge.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get postcardReviewPendingBadge;

  /// No description provided for @postcardReviewApprovedBadge.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get postcardReviewApprovedBadge;

  /// No description provided for @postcardReviewRejectedBadge.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get postcardReviewRejectedBadge;

  /// No description provided for @postcardPostHiddenBadge.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get postcardPostHiddenBadge;

  /// No description provided for @postcardPostRemovedBadge.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get postcardPostRemovedBadge;

  /// No description provided for @postcardReviewPendingBanner.
  ///
  /// In en, this message translates to:
  /// **'This postcard is pending review. Only you can see it here.'**
  String get postcardReviewPendingBanner;

  /// No description provided for @postcardReviewRejectedBanner.
  ///
  /// In en, this message translates to:
  /// **'This postcard was not approved for the public wall. You can still view it from your list.'**
  String get postcardReviewRejectedBanner;

  /// No description provided for @letterMailboxSealedPreview.
  ///
  /// In en, this message translates to:
  /// **'Letter sealed until arrival'**
  String get letterMailboxSealedPreview;

  /// No description provided for @letterContentHiddenHint.
  ///
  /// In en, this message translates to:
  /// **'This letter is still on its way. The message stays sealed until it arrives.'**
  String get letterContentHiddenHint;

  /// No description provided for @postDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Postcard'**
  String get postDetailTitle;

  /// No description provided for @letterDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Letter'**
  String get letterDetailTitle;

  /// No description provided for @letterModePostOffice.
  ///
  /// In en, this message translates to:
  /// **'Kindred delivery'**
  String get letterModePostOffice;

  /// No description provided for @letterModeDirect.
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get letterModeDirect;

  /// No description provided for @letterModeSelfTime.
  ///
  /// In en, this message translates to:
  /// **'Time letter (SELF_TIME)'**
  String get letterModeSelfTime;

  /// No description provided for @letterModeLine.
  ///
  /// In en, this message translates to:
  /// **'Mode: {mode}'**
  String letterModeLine(String mode);

  /// No description provided for @letterStatusMatched.
  ///
  /// In en, this message translates to:
  /// **'Matched'**
  String get letterStatusMatched;

  /// No description provided for @letterAuditPending.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get letterAuditPending;

  /// No description provided for @letterAuditApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get letterAuditApproved;

  /// No description provided for @letterAuditRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get letterAuditRejected;

  /// No description provided for @letterAuditLine.
  ///
  /// In en, this message translates to:
  /// **'Audit: {status}'**
  String letterAuditLine(String status);

  /// No description provided for @letterEtaLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated arrival'**
  String get letterEtaLabel;

  /// No description provided for @letterDeliveredLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get letterDeliveredLabel;

  /// No description provided for @letterPeerPostOfficePool.
  ///
  /// In en, this message translates to:
  /// **'Finding a friend'**
  String get letterPeerPostOfficePool;

  /// No description provided for @letterPeerUnknown.
  ///
  /// In en, this message translates to:
  /// **'Finding a friend'**
  String get letterPeerUnknown;

  /// No description provided for @letterPeerRecommending.
  ///
  /// In en, this message translates to:
  /// **'Finding a friend'**
  String get letterPeerRecommending;

  /// No description provided for @letterAcceptContact.
  ///
  /// In en, this message translates to:
  /// **'Add pen pal'**
  String get letterAcceptContact;

  /// No description provided for @letterAcceptContactDone.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get letterAcceptContactDone;

  /// No description provided for @letterReplyCta.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get letterReplyCta;

  /// No description provided for @letterReplyHint.
  ///
  /// In en, this message translates to:
  /// **'Write your reply on the letter desk — it travels by slow mail too.'**
  String get letterReplyHint;

  /// No description provided for @letterAcceptContactSuccess.
  ///
  /// In en, this message translates to:
  /// **'Pen pal request sent. After they accept, find them under My pen pals.'**
  String get letterAcceptContactSuccess;

  /// No description provided for @postDetailCommentRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a comment.'**
  String get postDetailCommentRequired;

  /// No description provided for @postDetailCommentPosted.
  ///
  /// In en, this message translates to:
  /// **'Comment posted.'**
  String get postDetailCommentPosted;

  /// No description provided for @postDetailReply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get postDetailReply;

  /// No description provided for @postDetailReplyingTo.
  ///
  /// In en, this message translates to:
  /// **'Replying to @{name}'**
  String postDetailReplyingTo(Object name);

  /// No description provided for @postDetailCancelReply.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get postDetailCancelReply;

  /// No description provided for @postDetailLike.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get postDetailLike;

  /// No description provided for @postDetailReportComment.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get postDetailReportComment;

  /// No description provided for @postDetailCommentsSection.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get postDetailCommentsSection;

  /// No description provided for @postDetailReplyPrefix.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get postDetailReplyPrefix;

  /// No description provided for @postDetailWriteComment.
  ///
  /// In en, this message translates to:
  /// **'Write a comment'**
  String get postDetailWriteComment;

  /// No description provided for @postDetailSendComment.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get postDetailSendComment;

  /// No description provided for @postDetailNoCommentsTitle.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get postDetailNoCommentsTitle;

  /// No description provided for @postDetailNoCommentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start the first kind reply.'**
  String get postDetailNoCommentsSubtitle;

  /// No description provided for @errorInvalidContentId.
  ///
  /// In en, this message translates to:
  /// **'Invalid content id.'**
  String get errorInvalidContentId;

  /// No description provided for @errorInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid response from server.'**
  String get errorInvalidResponse;

  /// No description provided for @directoryFilterSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter directory'**
  String get directoryFilterSectionTitle;

  /// No description provided for @directoryFilterSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Country, age range, interests, and sort'**
  String get directoryFilterSectionSubtitle;

  /// No description provided for @directoryFilterCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get directoryFilterCountryLabel;

  /// No description provided for @directoryFilterSort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get directoryFilterSort;

  /// No description provided for @directoryFilterNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get directoryFilterNewest;

  /// No description provided for @directoryFilterClosestAge.
  ///
  /// In en, this message translates to:
  /// **'Closest age'**
  String get directoryFilterClosestAge;

  /// No description provided for @directoryFilterSharedInterests.
  ///
  /// In en, this message translates to:
  /// **'Shared interests'**
  String get directoryFilterSharedInterests;

  /// No description provided for @directoryFilterAllCountries.
  ///
  /// In en, this message translates to:
  /// **'All countries'**
  String get directoryFilterAllCountries;

  /// No description provided for @directoryFilterMinAge.
  ///
  /// In en, this message translates to:
  /// **'Min age: {age}'**
  String directoryFilterMinAge(Object age);

  /// No description provided for @directoryFilterMaxAge.
  ///
  /// In en, this message translates to:
  /// **'Max age: {age}'**
  String directoryFilterMaxAge(Object age);

  /// No description provided for @mailboxArchiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Letter archive'**
  String get mailboxArchiveTitle;

  /// No description provided for @mailboxOpenArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get mailboxOpenArchive;

  /// No description provided for @mailboxPostOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'A post is on the way'**
  String get mailboxPostOnTheWay;

  /// No description provided for @shopTitleStampsVip.
  ///
  /// In en, this message translates to:
  /// **'Stamps & membership'**
  String get shopTitleStampsVip;

  /// No description provided for @shopPlaceholderOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders & history (placeholder)'**
  String get shopPlaceholderOrders;

  /// No description provided for @shopPlaceholderBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy (placeholder)'**
  String get shopPlaceholderBuy;

  /// No description provided for @shopOrdersSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Orders and payment history will open once the catalog is connected.'**
  String get shopOrdersSnackbar;

  /// No description provided for @shopPricePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Price: —'**
  String get shopPricePlaceholder;

  /// No description provided for @shopCheckoutSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Checkout opens when payments are connected.'**
  String get shopCheckoutSnackbar;

  /// No description provided for @shopSkuStampLine.
  ///
  /// In en, this message translates to:
  /// **'×{count} stamps'**
  String shopSkuStampLine(Object count);

  /// No description provided for @interestsPickerSaved.
  ///
  /// In en, this message translates to:
  /// **'Interests saved.'**
  String get interestsPickerSaved;

  /// No description provided for @reportReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a report reason.'**
  String get reportReasonRequired;

  /// No description provided for @reportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Report submitted.'**
  String get reportSubmitted;

  /// No description provided for @accountDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountDeleteTitle;

  /// No description provided for @interestsPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Interest tags'**
  String get interestsPickerTitle;

  /// No description provided for @sendLetterBodyRequired.
  ///
  /// In en, this message translates to:
  /// **'Please write the letter content.'**
  String get sendLetterBodyRequired;

  /// No description provided for @sendLetterSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Letter sent.'**
  String get sendLetterSentSuccess;

  /// No description provided for @sendLetterSentSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Letter sent'**
  String get sendLetterSentSuccessTitle;

  /// No description provided for @sendLetterSentSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your letter is on its way. They will find it in their Post Box.'**
  String get sendLetterSentSuccessMessage;

  /// No description provided for @sendLetterSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Send letter to {name}'**
  String sendLetterSheetTitle(Object name);

  /// No description provided for @sendLetterContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Letter content'**
  String get sendLetterContentLabel;

  /// No description provided for @mailboxTabReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get mailboxTabReceived;

  /// No description provided for @mailboxTabSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get mailboxTabSent;

  /// No description provided for @mailboxTabTimeLetter.
  ///
  /// In en, this message translates to:
  /// **'Time letter'**
  String get mailboxTabTimeLetter;

  /// No description provided for @mailboxReceivedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No received letters'**
  String get mailboxReceivedEmptyTitle;

  /// No description provided for @mailboxReceivedEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Letters from the post office or pen pals appear here.'**
  String get mailboxReceivedEmptySubtitle;

  /// No description provided for @mailboxSentEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No sent letters'**
  String get mailboxSentEmptyTitle;

  /// No description provided for @mailboxSentEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Letters you send stay here until the recipient has read them.'**
  String get mailboxSentEmptySubtitle;

  /// No description provided for @directoryTabRecommend.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get directoryTabRecommend;

  /// No description provided for @directoryTabFind.
  ///
  /// In en, this message translates to:
  /// **'Find pen pals'**
  String get directoryTabFind;

  /// No description provided for @directoryTabMyPenpals.
  ///
  /// In en, this message translates to:
  /// **'My pen pals'**
  String get directoryTabMyPenpals;

  /// No description provided for @directoryRecommendEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recommendations today'**
  String get directoryRecommendEmpty;

  /// No description provided for @directoryRecommendEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Check back tomorrow, or browse Find pen pals.'**
  String get directoryRecommendEmptyHint;

  /// No description provided for @directoryPenpalsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No pen pals yet'**
  String get directoryPenpalsEmpty;

  /// No description provided for @directoryPenpalsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'After enough letters, send a pen pal request. Confirmed pals appear here.'**
  String get directoryPenpalsEmptyHint;

  /// No description provided for @directoryWriteLetter.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get directoryWriteLetter;

  /// No description provided for @penpalListMeta.
  ///
  /// In en, this message translates to:
  /// **'Pen pal {days}d · {count} letters'**
  String penpalListMeta(Object days, Object count);

  /// No description provided for @postOfficeRelationMessagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Relation messages'**
  String get postOfficeRelationMessagesTitle;

  /// No description provided for @postOfficeRelationMessagesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No relation messages'**
  String get postOfficeRelationMessagesEmpty;

  /// No description provided for @postOfficeRelationMessagesEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Pen pal requests and add-pen-pal reminders show up here.'**
  String get postOfficeRelationMessagesEmptyHint;

  /// No description provided for @penpalExchangeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} letters exchanged'**
  String penpalExchangeCount(Object count);

  /// No description provided for @penpalAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get penpalAccept;

  /// No description provided for @penpalIgnore.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get penpalIgnore;

  /// No description provided for @penpalAcceptSuccess.
  ///
  /// In en, this message translates to:
  /// **'You are now pen pals'**
  String get penpalAcceptSuccess;

  /// No description provided for @penpalRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Pen pal request sent'**
  String get penpalRequestSent;

  /// No description provided for @relationAddPenpal.
  ///
  /// In en, this message translates to:
  /// **'Add pen pal'**
  String get relationAddPenpal;

  /// No description provided for @relationAddPenpalSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request sent — waiting for confirmation'**
  String get relationAddPenpalSuccess;

  /// No description provided for @relationStateStranger.
  ///
  /// In en, this message translates to:
  /// **'Stranger'**
  String get relationStateStranger;

  /// No description provided for @relationStateContacting.
  ///
  /// In en, this message translates to:
  /// **'In correspondence'**
  String get relationStateContacting;

  /// No description provided for @relationStateCanAddPenpal.
  ///
  /// In en, this message translates to:
  /// **'Can add pen pal'**
  String get relationStateCanAddPenpal;

  /// No description provided for @relationStatePendingOut.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get relationStatePendingOut;

  /// No description provided for @relationStatePendingIn.
  ///
  /// In en, this message translates to:
  /// **'Awaiting you'**
  String get relationStatePendingIn;

  /// No description provided for @relationStatePenpal.
  ///
  /// In en, this message translates to:
  /// **'Pen pal'**
  String get relationStatePenpal;

  /// No description provided for @userCardWriteFirstLetter.
  ///
  /// In en, this message translates to:
  /// **'Write first letter'**
  String get userCardWriteFirstLetter;

  /// No description provided for @userCardContinueWriting.
  ///
  /// In en, this message translates to:
  /// **'Keep writing'**
  String get userCardContinueWriting;

  /// No description provided for @profileOverviewPenpals.
  ///
  /// In en, this message translates to:
  /// **'Pen pals'**
  String get profileOverviewPenpals;

  /// No description provided for @profileOverviewLetters.
  ///
  /// In en, this message translates to:
  /// **'Letters'**
  String get profileOverviewLetters;

  /// No description provided for @profileOverviewTimeLetters.
  ///
  /// In en, this message translates to:
  /// **'Time letters'**
  String get profileOverviewTimeLetters;

  /// No description provided for @profileSectionMyContent.
  ///
  /// In en, this message translates to:
  /// **'My content'**
  String get profileSectionMyContent;

  /// No description provided for @profileSectionShop.
  ///
  /// In en, this message translates to:
  /// **'Shop & membership'**
  String get profileSectionShop;

  /// No description provided for @profileSectionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & safety'**
  String get profileSectionPrivacy;

  /// No description provided for @profileTimeLetterDrafts.
  ///
  /// In en, this message translates to:
  /// **'Time letters'**
  String get profileTimeLetterDrafts;

  /// No description provided for @profilePrivacyRecommendPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Hide recommendations (coming soon)'**
  String get profilePrivacyRecommendPlaceholder;

  /// No description provided for @profilePrivacyStrangerPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Decline stranger mail (coming soon)'**
  String get profilePrivacyStrangerPlaceholder;

  /// No description provided for @commonLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load'**
  String get commonLoadFailed;

  /// No description provided for @timeLetterComposeTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Post Office'**
  String get timeLetterComposeTitle;

  /// No description provided for @timeLetterComposeToSelf.
  ///
  /// In en, this message translates to:
  /// **'Letter to future me'**
  String get timeLetterComposeToSelf;

  /// No description provided for @timeLetterComposeToFriend.
  ///
  /// In en, this message translates to:
  /// **'To {name}'**
  String timeLetterComposeToFriend(Object name);

  /// No description provided for @timeLetterDeliveryDate.
  ///
  /// In en, this message translates to:
  /// **'Delivery date'**
  String get timeLetterDeliveryDate;

  /// No description provided for @timeLetterDaysUntil.
  ///
  /// In en, this message translates to:
  /// **'{days} days until delivery'**
  String timeLetterDaysUntil(Object days);

  /// No description provided for @timeLetterBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Write what you want your future self or friend to read…'**
  String get timeLetterBodyHint;

  /// No description provided for @timeLetterBodyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please write your letter.'**
  String get timeLetterBodyEmpty;

  /// No description provided for @timeLetterSealSlide.
  ///
  /// In en, this message translates to:
  /// **'Slide to seal'**
  String get timeLetterSealSlide;

  /// No description provided for @timeLetterSealSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Sealed'**
  String get timeLetterSealSuccessTitle;

  /// No description provided for @timeLetterSealSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your time letter is on its way. It will arrive on the date you chose.'**
  String get timeLetterSealSuccessMessage;

  /// No description provided for @timeLetterTabOutbox.
  ///
  /// In en, this message translates to:
  /// **'Outbox'**
  String get timeLetterTabOutbox;

  /// No description provided for @timeLetterTabInbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get timeLetterTabInbox;

  /// No description provided for @timeLetterTabMemorial.
  ///
  /// In en, this message translates to:
  /// **'Memorial'**
  String get timeLetterTabMemorial;

  /// No description provided for @timeLetterEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No time letters yet'**
  String get timeLetterEmptyTitle;

  /// No description provided for @timeLetterEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Write a time letter from the post office home.'**
  String get timeLetterEmptySubtitle;

  /// No description provided for @timeLetterLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load time letters'**
  String get timeLetterLoadError;

  /// No description provided for @timeLetterSealedHidden.
  ///
  /// In en, this message translates to:
  /// **'Sealed — content hidden until delivery'**
  String get timeLetterSealedHidden;

  /// No description provided for @timeLetterTapToOpen.
  ///
  /// In en, this message translates to:
  /// **'Tap to open when delivered'**
  String get timeLetterTapToOpen;

  /// No description provided for @timeLetterCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this letter?'**
  String get timeLetterCancelTitle;

  /// No description provided for @timeLetterCancelMessage.
  ///
  /// In en, this message translates to:
  /// **'Stamps will be refunded if you cancel within 24 hours.'**
  String get timeLetterCancelMessage;

  /// No description provided for @timeLetterOpenTitle.
  ///
  /// In en, this message translates to:
  /// **'Open time letter'**
  String get timeLetterOpenTitle;

  /// No description provided for @timeLetterOpenRitual.
  ///
  /// In en, this message translates to:
  /// **'Open the envelope'**
  String get timeLetterOpenRitual;

  /// No description provided for @timeLetterReadEstimate.
  ///
  /// In en, this message translates to:
  /// **'About {minutes} min read'**
  String timeLetterReadEstimate(Object minutes);

  /// No description provided for @timeLetterStar.
  ///
  /// In en, this message translates to:
  /// **'Add to memorial'**
  String get timeLetterStar;

  /// No description provided for @timeLetterStarred.
  ///
  /// In en, this message translates to:
  /// **'In memorial'**
  String get timeLetterStarred;

  /// No description provided for @timeLetterSendToFriend.
  ///
  /// In en, this message translates to:
  /// **'Time letter'**
  String get timeLetterSendToFriend;

  /// No description provided for @timeLetterBanner.
  ///
  /// In en, this message translates to:
  /// **'{inFlight} in transit · {unread} to open · {today} arrived today'**
  String timeLetterBanner(Object inFlight, Object unread, Object today);

  /// No description provided for @topicFriendFallback.
  ///
  /// In en, this message translates to:
  /// **'friend'**
  String get topicFriendFallback;

  /// No description provided for @topicTodayGreeting.
  ///
  /// In en, this message translates to:
  /// **'Good to see you, {name}'**
  String topicTodayGreeting(Object name);

  /// No description provided for @topicTodayIntro.
  ///
  /// In en, this message translates to:
  /// **'There is no rush here. Read what has arrived, write one thoughtful letter, or pick a topic for today.'**
  String get topicTodayIntro;

  /// No description provided for @topicTodayLetters.
  ///
  /// In en, this message translates to:
  /// **'Letters needing attention'**
  String get topicTodayLetters;

  /// No description provided for @topicTodayLettersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} letters'**
  String topicTodayLettersCount(Object count);

  /// No description provided for @topicTodayLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get topicTodayLoading;

  /// No description provided for @topicTodayTime.
  ///
  /// In en, this message translates to:
  /// **'Time letters'**
  String get topicTodayTime;

  /// No description provided for @topicTodayTimeLetters.
  ///
  /// In en, this message translates to:
  /// **'{inFlight} waiting · {unread} ready'**
  String topicTodayTimeLetters(Object inFlight, Object unread);

  /// No description provided for @topicTodayTimeLettersLoading.
  ///
  /// In en, this message translates to:
  /// **'Checking'**
  String get topicTodayTimeLettersLoading;

  /// No description provided for @topicWriteLetter.
  ///
  /// In en, this message translates to:
  /// **'Write a letter'**
  String get topicWriteLetter;

  /// No description provided for @topicOpenMailbox.
  ///
  /// In en, this message translates to:
  /// **'Open mailbox'**
  String get topicOpenMailbox;

  /// No description provided for @topicOfficialLetterTitle.
  ///
  /// In en, this message translates to:
  /// **'A note from the Post Office'**
  String get topicOfficialLetterTitle;

  /// No description provided for @topicOfficialIdentity.
  ///
  /// In en, this message translates to:
  /// **'Official letter · clearly marked'**
  String get topicOfficialIdentity;

  /// No description provided for @topicOfficialLetterBody.
  ///
  /// In en, this message translates to:
  /// **'Today you can write about a memory, a meal, or a place you miss. We will never pretend an official note is a real pen pal.'**
  String get topicOfficialLetterBody;

  /// No description provided for @topicOfficialCta.
  ///
  /// In en, this message translates to:
  /// **'Write to future me'**
  String get topicOfficialCta;

  /// No description provided for @topicDailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s topic mailboxes'**
  String get topicDailyTitle;

  /// No description provided for @topicDailySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose one gentle prompt. A good letter is better than a long scroll.'**
  String get topicDailySubtitle;

  /// No description provided for @topicWriteToTopic.
  ///
  /// In en, this message translates to:
  /// **'Write here'**
  String get topicWriteToTopic;

  /// No description provided for @topicOfficialExample.
  ///
  /// In en, this message translates to:
  /// **'Official example'**
  String get topicOfficialExample;

  /// No description provided for @topicTodayTopic.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get topicTodayTopic;

  /// No description provided for @topicHometownTitle.
  ///
  /// In en, this message translates to:
  /// **'Hometown memories'**
  String get topicHometownTitle;

  /// No description provided for @topicHometownPrompt.
  ///
  /// In en, this message translates to:
  /// **'Describe a road, a market, or a familiar doorway from the place you still remember.'**
  String get topicHometownPrompt;

  /// No description provided for @topicRetirementTitle.
  ///
  /// In en, this message translates to:
  /// **'A quiet day after retirement'**
  String get topicRetirementTitle;

  /// No description provided for @topicRetirementPrompt.
  ///
  /// In en, this message translates to:
  /// **'Write about one ordinary moment that made you feel comfortable recently.'**
  String get topicRetirementPrompt;

  /// No description provided for @topicOldPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'The story behind an old photo'**
  String get topicOldPhotoTitle;

  /// No description provided for @topicOldPhotoPrompt.
  ///
  /// In en, this message translates to:
  /// **'Pick a person, place, or season from an old photo and write what still stays with you.'**
  String get topicOldPhotoPrompt;

  /// No description provided for @topicSafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'A calmer way to meet pen pals'**
  String get topicSafetyTitle;

  /// No description provided for @topicSafetyBody.
  ///
  /// In en, this message translates to:
  /// **'Money, investment, verification codes and private contact requests will be treated carefully. You can write slowly and decide slowly.'**
  String get topicSafetyBody;

  /// No description provided for @composeTitle.
  ///
  /// In en, this message translates to:
  /// **'Write a letter'**
  String get composeTitle;

  /// No description provided for @composeStepDestinationTitle.
  ///
  /// In en, this message translates to:
  /// **'Who is this letter for?'**
  String get composeStepDestinationTitle;

  /// No description provided for @composeStepDestinationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One step at a time. There is no rush.'**
  String get composeStepDestinationSubtitle;

  /// No description provided for @composeStepFooter.
  ///
  /// In en, this message translates to:
  /// **'Basic letter writing is never blocked by payment.'**
  String get composeStepFooter;

  /// No description provided for @composeChooseSelf.
  ///
  /// In en, this message translates to:
  /// **'To myself (time letter)'**
  String get composeChooseSelf;

  /// No description provided for @composeChooseSelfSub.
  ///
  /// In en, this message translates to:
  /// **'SELF_TIME — open on a future date'**
  String get composeChooseSelfSub;

  /// No description provided for @composeChoosePenPal.
  ///
  /// In en, this message translates to:
  /// **'To a pen pal'**
  String get composeChoosePenPal;

  /// No description provided for @composeChoosePenPalSub.
  ///
  /// In en, this message translates to:
  /// **'DIRECT — send to someone you know'**
  String get composeChoosePenPalSub;

  /// No description provided for @composeChooseTopic.
  ///
  /// In en, this message translates to:
  /// **'To a topic mailbox'**
  String get composeChooseTopic;

  /// No description provided for @composeChooseTopicSub.
  ///
  /// In en, this message translates to:
  /// **'Start from today\'s gentle prompt'**
  String get composeChooseTopicSub;

  /// No description provided for @composeChoosePostOffice.
  ///
  /// In en, this message translates to:
  /// **'To the post office'**
  String get composeChoosePostOffice;

  /// No description provided for @composeChoosePostOfficeSub.
  ///
  /// In en, this message translates to:
  /// **'POST_OFFICE — no recipient; wait for a match'**
  String get composeChoosePostOfficeSub;

  /// No description provided for @composeBodySubtitlePostOffice.
  ///
  /// In en, this message translates to:
  /// **'Write freely — the post office will find a reader.'**
  String get composeBodySubtitlePostOffice;

  /// No description provided for @composePostOfficeSendHint.
  ///
  /// In en, this message translates to:
  /// **'This letter goes into the post office pool'**
  String get composePostOfficeSendHint;

  /// No description provided for @composePickDestinationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please choose who you are writing to'**
  String get composePickDestinationRequired;

  /// No description provided for @composeStepPenPalTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a pen pal'**
  String get composeStepPenPalTitle;

  /// No description provided for @composeStepPenPalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start with someone you already connected with. If you have none yet, visit the pen pal hall first.'**
  String get composeStepPenPalSubtitle;

  /// No description provided for @composePickPenPalRequired.
  ///
  /// In en, this message translates to:
  /// **'Please choose a pen pal'**
  String get composePickPenPalRequired;

  /// No description provided for @composePenPalEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No pen pals yet'**
  String get composePenPalEmptyTitle;

  /// No description provided for @composePenPalEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Visit the pen pal hall, read profiles, and send your first thoughtful letter.'**
  String get composePenPalEmptySubtitle;

  /// No description provided for @composePenPalLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load pen pals'**
  String get composePenPalLoadFailed;

  /// No description provided for @composeGoDirectory.
  ///
  /// In en, this message translates to:
  /// **'Go to pen pals'**
  String get composeGoDirectory;

  /// No description provided for @composeStepTopicTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a topic'**
  String get composeStepTopicTitle;

  /// No description provided for @composeStepTopicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick one gentle prompt for today.'**
  String get composeStepTopicSubtitle;

  /// No description provided for @composePickTopicRequired.
  ///
  /// In en, this message translates to:
  /// **'Please choose a topic'**
  String get composePickTopicRequired;

  /// No description provided for @composeStepBodyTitle.
  ///
  /// In en, this message translates to:
  /// **'Write the letter'**
  String get composeStepBodyTitle;

  /// No description provided for @composeBodyLabel.
  ///
  /// In en, this message translates to:
  /// **'Letter body'**
  String get composeBodyLabel;

  /// No description provided for @composeBodyFooter.
  ///
  /// In en, this message translates to:
  /// **'Thoughtful writing matters more than length.'**
  String get composeBodyFooter;

  /// No description provided for @composeBodyRequired.
  ///
  /// In en, this message translates to:
  /// **'Please write the letter body first'**
  String get composeBodyRequired;

  /// No description provided for @composeBodySubtitleSelf.
  ///
  /// In en, this message translates to:
  /// **'To your future self — a memory, a wish, or how today feels.'**
  String get composeBodySubtitleSelf;

  /// No description provided for @composeBodySubtitlePenPal.
  ///
  /// In en, this message translates to:
  /// **'A thoughtful letter to {name}.'**
  String composeBodySubtitlePenPal(Object name);

  /// No description provided for @composeBodySubtitleTimePenPal.
  ///
  /// In en, this message translates to:
  /// **'A time letter to {name}, delivered on the date you choose.'**
  String composeBodySubtitleTimePenPal(Object name);

  /// No description provided for @composeBodySubtitleTopic.
  ///
  /// In en, this message translates to:
  /// **'Write about the topic you selected.'**
  String get composeBodySubtitleTopic;

  /// No description provided for @composeStepDeliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose delivery date'**
  String get composeStepDeliveryTitle;

  /// No description provided for @composeStepDeliverySubtitle.
  ///
  /// In en, this message translates to:
  /// **'The time letter stays sealed until that date.'**
  String get composeStepDeliverySubtitle;

  /// No description provided for @composeStepMailTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose template & paper'**
  String get composeStepMailTitle;

  /// No description provided for @composeStepMailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a template and paper first, then write the body.'**
  String get composeStepMailSubtitle;

  /// No description provided for @composeStepSealTitle.
  ///
  /// In en, this message translates to:
  /// **'Seal and send'**
  String get composeStepSealTitle;

  /// No description provided for @composeStepSealSubtitle.
  ///
  /// In en, this message translates to:
  /// **'After sealing, the letter waits until delivery day.'**
  String get composeStepSealSubtitle;

  /// No description provided for @composeStepSendTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to send'**
  String get composeStepSendTitle;

  /// No description provided for @composeStepSendSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track status in My Mailbox after sending.'**
  String get composeStepSendSubtitle;

  /// No description provided for @composeSendNow.
  ///
  /// In en, this message translates to:
  /// **'Send now'**
  String get composeSendNow;

  /// No description provided for @composeStepPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview letter'**
  String get composeStepPreviewTitle;

  /// No description provided for @composeStepPreviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm paper and text before sending.'**
  String get composeStepPreviewSubtitle;

  /// No description provided for @composeSeeAsRecipient.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get composeSeeAsRecipient;

  /// No description provided for @composePaperSettings.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get composePaperSettings;

  /// No description provided for @composeFontSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get composeFontSizeLarge;

  /// No description provided for @composeFontSizeXlarge.
  ///
  /// In en, this message translates to:
  /// **'Larger'**
  String get composeFontSizeXlarge;

  /// No description provided for @composeFontSizeSection.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get composeFontSizeSection;

  /// No description provided for @composeFontSection.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get composeFontSection;

  /// No description provided for @composeSkinSection.
  ///
  /// In en, this message translates to:
  /// **'Paper color'**
  String get composeSkinSection;

  /// No description provided for @composeSendLetterCta.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get composeSendLetterCta;

  /// No description provided for @composeRemainingQuota.
  ///
  /// In en, this message translates to:
  /// **'{count} left today'**
  String composeRemainingQuota(int count);

  /// No description provided for @composePreviewRequiredFirst.
  ///
  /// In en, this message translates to:
  /// **'Please preview once before sending, so you know what the recipient will see.'**
  String get composePreviewRequiredFirst;

  /// No description provided for @composeContinueAfterPreview.
  ///
  /// In en, this message translates to:
  /// **'Confirm and continue'**
  String get composeContinueAfterPreview;

  /// No description provided for @composeRecipientSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Who to'**
  String get composeRecipientSheetTitle;

  /// No description provided for @composeRecipientPostOffice.
  ///
  /// In en, this message translates to:
  /// **'A kindred spirit'**
  String get composeRecipientPostOffice;

  /// No description provided for @composeRecipientPenPal.
  ///
  /// In en, this message translates to:
  /// **'Pen pal'**
  String get composeRecipientPenPal;

  /// No description provided for @composeRecipientSelf.
  ///
  /// In en, this message translates to:
  /// **'Future self'**
  String get composeRecipientSelf;

  /// No description provided for @letterAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'Letter assistant'**
  String get letterAssistantTitle;

  /// No description provided for @letterAssistantClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get letterAssistantClose;

  /// No description provided for @letterAssistantPickModeHint.
  ///
  /// In en, this message translates to:
  /// **'Pick how to polish. Your original stays until you replace it.'**
  String get letterAssistantPickModeHint;

  /// No description provided for @letterAssistantModeWarmer.
  ///
  /// In en, this message translates to:
  /// **'❤️ Warmer'**
  String get letterAssistantModeWarmer;

  /// No description provided for @letterAssistantModeNatural.
  ///
  /// In en, this message translates to:
  /// **'✨ More natural'**
  String get letterAssistantModeNatural;

  /// No description provided for @letterAssistantModeContinue.
  ///
  /// In en, this message translates to:
  /// **'📖 Keep chatting'**
  String get letterAssistantModeContinue;

  /// No description provided for @letterAssistantModeShorten.
  ///
  /// In en, this message translates to:
  /// **'✂️ Shorten'**
  String get letterAssistantModeShorten;

  /// No description provided for @letterAssistantModeInspire.
  ///
  /// In en, this message translates to:
  /// **'💡 Give me ideas'**
  String get letterAssistantModeInspire;

  /// No description provided for @letterAssistantGenerate.
  ///
  /// In en, this message translates to:
  /// **'Polish'**
  String get letterAssistantGenerate;

  /// No description provided for @letterAssistantInspireGenerate.
  ///
  /// In en, this message translates to:
  /// **'Get ideas'**
  String get letterAssistantInspireGenerate;

  /// No description provided for @letterAssistantYourDraft.
  ///
  /// In en, this message translates to:
  /// **'Your draft'**
  String get letterAssistantYourDraft;

  /// No description provided for @letterAssistantSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Assistant draft'**
  String get letterAssistantSuggestion;

  /// No description provided for @letterAssistantReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace draft'**
  String get letterAssistantReplace;

  /// No description provided for @letterAssistantKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep mine'**
  String get letterAssistantKeep;

  /// No description provided for @letterAssistantRetry.
  ///
  /// In en, this message translates to:
  /// **'Revise again'**
  String get letterAssistantRetry;

  /// No description provided for @letterAssistantUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get letterAssistantUndo;

  /// No description provided for @letterAssistantUndoBanner.
  ///
  /// In en, this message translates to:
  /// **'Assistant changed your draft'**
  String get letterAssistantUndoBanner;

  /// No description provided for @letterAssistantEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Write something first, then ask the assistant.'**
  String get letterAssistantEmptyBody;

  /// No description provided for @letterAssistantBusy.
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get letterAssistantBusy;

  /// No description provided for @letterAssistantReplaced.
  ///
  /// In en, this message translates to:
  /// **'Applied. Tap Undo above to revert.'**
  String get letterAssistantReplaced;

  /// No description provided for @letterAssistantInspireAskTitle.
  ///
  /// In en, this message translates to:
  /// **'You could ask'**
  String get letterAssistantInspireAskTitle;

  /// No description provided for @letterAssistantInspireShareTitle.
  ///
  /// In en, this message translates to:
  /// **'You could share'**
  String get letterAssistantInspireShareTitle;

  /// No description provided for @letterAssistantInspireAppend.
  ///
  /// In en, this message translates to:
  /// **'Add to letter'**
  String get letterAssistantInspireAppend;

  /// No description provided for @letterAssistantInspireBridge.
  ///
  /// In en, this message translates to:
  /// **'We could also talk about:'**
  String get letterAssistantInspireBridge;

  /// No description provided for @letterAssistantInspirePickHint.
  ///
  /// In en, this message translates to:
  /// **'Pick topics to add to your letter'**
  String get letterAssistantInspirePickHint;

  /// No description provided for @composeSaveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get composeSaveDraft;

  /// No description provided for @composeDraftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved'**
  String get composeDraftSaved;

  /// No description provided for @composeEditorWordCount.
  ///
  /// In en, this message translates to:
  /// **'{count} chars'**
  String composeEditorWordCount(Object count);

  /// No description provided for @composePlaceholderBody.
  ///
  /// In en, this message translates to:
  /// **'Write what you want to say…'**
  String get composePlaceholderBody;

  /// No description provided for @composeHintEditablePrompt.
  ///
  /// In en, this message translates to:
  /// **'You can edit this prompt freely'**
  String get composeHintEditablePrompt;

  /// No description provided for @composeSealWhenReady.
  ///
  /// In en, this message translates to:
  /// **'Pick a date, then seal'**
  String get composeSealWhenReady;

  /// No description provided for @composeCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get composeCancel;

  /// No description provided for @composeStepTopicSubmitTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit to topic mailbox'**
  String get composeStepTopicSubmitTitle;

  /// No description provided for @composeStepTopicSubmitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'After review, approved submissions become visible to others.'**
  String get composeStepTopicSubmitSubtitle;

  /// No description provided for @composeTopicSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit to topic'**
  String get composeTopicSubmit;

  /// No description provided for @composeTopicSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted to the topic mailbox. It will appear after review.'**
  String get composeTopicSubmitted;

  /// No description provided for @shopVipSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Membership · VIP'**
  String get shopVipSectionTitle;

  /// No description provided for @shopVipOwnedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You are a member — see benefits below'**
  String get shopVipOwnedSubtitle;

  /// No description provided for @shopVipPromoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock more postal perks and cosmetics'**
  String get shopVipPromoSubtitle;

  /// No description provided for @shopVipBody.
  ///
  /// In en, this message translates to:
  /// **'VIP benefits are configured on the server (expression upgrades, ad-free, etc.). Checkout will appear here when payments are connected.'**
  String get shopVipBody;

  /// No description provided for @shopCatalogEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get shopCatalogEmptyTitle;

  /// No description provided for @shopCatalogEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Items will appear here once the catalog is configured.'**
  String get shopCatalogEmptySubtitle;

  /// No description provided for @shopMockPurchase.
  ///
  /// In en, this message translates to:
  /// **'Mock purchase'**
  String get shopMockPurchase;

  /// No description provided for @shopMockPurchaseSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchase complete — entitlement granted'**
  String get shopMockPurchaseSuccess;

  /// No description provided for @shopOwned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get shopOwned;

  /// No description provided for @shopPriceFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get shopPriceFree;

  /// No description provided for @shopPriceAmount.
  ///
  /// In en, this message translates to:
  /// **'\${amount}'**
  String shopPriceAmount(Object amount);

  /// No description provided for @shopProductTypeSkin.
  ///
  /// In en, this message translates to:
  /// **'Letter skins'**
  String get shopProductTypeSkin;

  /// No description provided for @shopProductTypeFont.
  ///
  /// In en, this message translates to:
  /// **'Fonts'**
  String get shopProductTypeFont;

  /// No description provided for @shopProductTypeTemplate.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get shopProductTypeTemplate;

  /// No description provided for @shopProductTypeVipBundle.
  ///
  /// In en, this message translates to:
  /// **'VIP bundles'**
  String get shopProductTypeVipBundle;

  /// No description provided for @shopProductTypeExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get shopProductTypeExport;

  /// No description provided for @shopProductTypeAttachment.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get shopProductTypeAttachment;

  /// No description provided for @commerceProductSkinDefault.
  ///
  /// In en, this message translates to:
  /// **'Default paper'**
  String get commerceProductSkinDefault;

  /// No description provided for @commerceProductSkinVintage.
  ///
  /// In en, this message translates to:
  /// **'Vintage paper'**
  String get commerceProductSkinVintage;

  /// No description provided for @commerceProductFontDefault.
  ///
  /// In en, this message translates to:
  /// **'Default font'**
  String get commerceProductFontDefault;

  /// No description provided for @commerceProductFontHandwriting.
  ///
  /// In en, this message translates to:
  /// **'Handwriting font'**
  String get commerceProductFontHandwriting;

  /// No description provided for @commerceProductExportPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF export'**
  String get commerceProductExportPdf;

  /// No description provided for @entitlementsTitle.
  ///
  /// In en, this message translates to:
  /// **'My cosmetics'**
  String get entitlementsTitle;

  /// No description provided for @entitlementsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No cosmetics yet'**
  String get entitlementsEmptyTitle;

  /// No description provided for @entitlementsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Visit the shop for letter skins, fonts, and more.'**
  String get entitlementsEmptySubtitle;

  /// No description provided for @entitlementsGrantedAt.
  ///
  /// In en, this message translates to:
  /// **'Granted {date}'**
  String entitlementsGrantedAt(Object date);

  /// No description provided for @profileLetterDrafts.
  ///
  /// In en, this message translates to:
  /// **'Letter drafts'**
  String get profileLetterDrafts;

  /// No description provided for @profileLetterFavorites.
  ///
  /// In en, this message translates to:
  /// **'Saved letters'**
  String get profileLetterFavorites;

  /// No description provided for @profileLetterExport.
  ///
  /// In en, this message translates to:
  /// **'Export letters'**
  String get profileLetterExport;

  /// No description provided for @profileMyEntitlements.
  ///
  /// In en, this message translates to:
  /// **'My cosmetics'**
  String get profileMyEntitlements;

  /// No description provided for @profilePrivacyHideRecommend.
  ///
  /// In en, this message translates to:
  /// **'Hide recommendations'**
  String get profilePrivacyHideRecommend;

  /// No description provided for @profilePrivacyRejectStranger.
  ///
  /// In en, this message translates to:
  /// **'Decline stranger mail'**
  String get profilePrivacyRejectStranger;

  /// No description provided for @letterDraftsTitle.
  ///
  /// In en, this message translates to:
  /// **'Letter drafts'**
  String get letterDraftsTitle;

  /// No description provided for @letterDraftsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No drafts'**
  String get letterDraftsEmptyTitle;

  /// No description provided for @letterDraftsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save a draft while writing and send it later.'**
  String get letterDraftsEmptySubtitle;

  /// No description provided for @letterDraftsSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get letterDraftsSend;

  /// No description provided for @letterDraftsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get letterDraftsDelete;

  /// No description provided for @letterDraftsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Draft deleted'**
  String get letterDraftsDeleted;

  /// No description provided for @letterDraftsNoContent.
  ///
  /// In en, this message translates to:
  /// **'(empty draft)'**
  String get letterDraftsNoContent;

  /// No description provided for @letterDraftsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String letterDraftsUpdated(Object time);

  /// No description provided for @letterFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved letters'**
  String get letterFavoritesTitle;

  /// No description provided for @letterFavoritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved letters'**
  String get letterFavoritesEmptyTitle;

  /// No description provided for @letterFavoritesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the star on a letter to save it here.'**
  String get letterFavoritesEmptySubtitle;

  /// No description provided for @letterExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export letters'**
  String get letterExportTitle;

  /// No description provided for @letterExportFromDate.
  ///
  /// In en, this message translates to:
  /// **'From date'**
  String get letterExportFromDate;

  /// No description provided for @letterExportToDate.
  ///
  /// In en, this message translates to:
  /// **'To date'**
  String get letterExportToDate;

  /// No description provided for @letterExportDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get letterExportDateOptional;

  /// No description provided for @letterExportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Generate export'**
  String get letterExportSubmit;

  /// No description provided for @letterExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Download link ready'**
  String get letterExportSuccess;

  /// No description provided for @letterExportPending.
  ///
  /// In en, this message translates to:
  /// **'Export submitted'**
  String get letterExportPending;

  /// No description provided for @letterFavorite.
  ///
  /// In en, this message translates to:
  /// **'Save letter'**
  String get letterFavorite;

  /// No description provided for @letterUnfavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove save'**
  String get letterUnfavorite;

  /// No description provided for @ritualOpenLetter.
  ///
  /// In en, this message translates to:
  /// **'A letter is waiting to be opened'**
  String get ritualOpenLetter;

  /// No description provided for @ritualDeliverySent.
  ///
  /// In en, this message translates to:
  /// **'Your letter is on its way'**
  String get ritualDeliverySent;

  /// No description provided for @composeSkinPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose letter skin'**
  String get composeSkinPickerTitle;

  /// No description provided for @settingsPreferencesSaved.
  ///
  /// In en, this message translates to:
  /// **'Preferences saved'**
  String get settingsPreferencesSaved;

  /// No description provided for @quotaClaimTitle.
  ///
  /// In en, this message translates to:
  /// **'Claim today\'s free quota'**
  String get quotaClaimTitle;

  /// No description provided for @quotaClaimMessage.
  ///
  /// In en, this message translates to:
  /// **'You can send {count} free letters each day. Claim today\'s quota before writing.'**
  String quotaClaimMessage(int count);

  /// No description provided for @quotaClaimButton.
  ///
  /// In en, this message translates to:
  /// **'Claim today\'s free quota'**
  String get quotaClaimButton;

  /// No description provided for @firstLetterGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Write your first letter'**
  String get firstLetterGuideTitle;

  /// No description provided for @firstLetterGuideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send a sincere letter through the post office — we\'ll match you with someone kind.'**
  String get firstLetterGuideSubtitle;

  /// No description provided for @firstLetterGuideHintTitle.
  ///
  /// In en, this message translates to:
  /// **'Ideas to start'**
  String get firstLetterGuideHintTitle;

  /// No description provided for @firstLetterGuideHintBody.
  ///
  /// In en, this message translates to:
  /// **'Share a recent feeling, a small joy, or the kind of pen pal you\'d like to meet. Short and sincere is enough.'**
  String get firstLetterGuideHintBody;

  /// No description provided for @firstLetterGuideCta.
  ///
  /// In en, this message translates to:
  /// **'Start my first letter'**
  String get firstLetterGuideCta;

  /// No description provided for @firstLetterGuideSkip.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get firstLetterGuideSkip;

  /// No description provided for @firstLetterComposeHint.
  ///
  /// In en, this message translates to:
  /// **'This is your first post-office letter. You can pick a free template and skin in the next step.'**
  String get firstLetterComposeHint;

  /// No description provided for @inTransitTitle.
  ///
  /// In en, this message translates to:
  /// **'Letters in transit'**
  String get inTransitTitle;

  /// No description provided for @inTransitLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load in-transit letters'**
  String get inTransitLoadFailed;

  /// No description provided for @inTransitEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing in transit'**
  String get inTransitEmptyTitle;

  /// No description provided for @inTransitEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sent and incoming letters will show progress here.'**
  String get inTransitEmptySubtitle;

  /// No description provided for @inTransitSectionOutbound.
  ///
  /// In en, this message translates to:
  /// **'Sent · not arrived'**
  String get inTransitSectionOutbound;

  /// No description provided for @inTransitSectionInbound.
  ///
  /// In en, this message translates to:
  /// **'Incoming · not arrived'**
  String get inTransitSectionInbound;

  /// No description provided for @inTransitSectionUnread.
  ///
  /// In en, this message translates to:
  /// **'Delivered · unread'**
  String get inTransitSectionUnread;

  /// No description provided for @inTransitSectionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No letters in this section'**
  String get inTransitSectionEmpty;

  /// No description provided for @inTransitEtaHours.
  ///
  /// In en, this message translates to:
  /// **'About {hours} hours until arrival'**
  String inTransitEtaHours(int hours);

  /// No description provided for @writeDestinationTitle.
  ///
  /// In en, this message translates to:
  /// **'Who are you writing to?'**
  String get writeDestinationTitle;

  /// No description provided for @writeDestinationPostOffice.
  ///
  /// In en, this message translates to:
  /// **'To a kindred spirit'**
  String get writeDestinationPostOffice;

  /// No description provided for @writeDestinationPostOfficeSub.
  ///
  /// In en, this message translates to:
  /// **'Drop it in the post office for a match'**
  String get writeDestinationPostOfficeSub;

  /// No description provided for @writeDestinationSelfTime.
  ///
  /// In en, this message translates to:
  /// **'To my future self'**
  String get writeDestinationSelfTime;

  /// No description provided for @writeDestinationSelfTimeSub.
  ///
  /// In en, this message translates to:
  /// **'A time letter that opens on a chosen date'**
  String get writeDestinationSelfTimeSub;

  /// No description provided for @composeAddParagraph.
  ///
  /// In en, this message translates to:
  /// **'Add paragraph'**
  String get composeAddParagraph;

  /// No description provided for @composeRemoveParagraph.
  ///
  /// In en, this message translates to:
  /// **'Remove paragraph'**
  String get composeRemoveParagraph;

  /// No description provided for @composeParagraphLabel.
  ///
  /// In en, this message translates to:
  /// **'Paragraph {n}'**
  String composeParagraphLabel(int n);

  /// No description provided for @composeTemplatePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Letter templates'**
  String get composeTemplatePickerTitle;

  /// No description provided for @composeTemplateEmpty.
  ///
  /// In en, this message translates to:
  /// **'No templates available'**
  String get composeTemplateEmpty;

  /// No description provided for @composeTemplateApplied.
  ///
  /// In en, this message translates to:
  /// **'Filled into the body — edit as you like'**
  String get composeTemplateApplied;

  /// No description provided for @composeStepMailSubtitleSkins.
  ///
  /// In en, this message translates to:
  /// **'Choose template and paper first, then write.'**
  String get composeStepMailSubtitleSkins;

  /// No description provided for @commerceProductSkinLinen.
  ///
  /// In en, this message translates to:
  /// **'Linen paper'**
  String get commerceProductSkinLinen;

  /// No description provided for @commerceProductTemplateEmotion.
  ///
  /// In en, this message translates to:
  /// **'Heartfelt note'**
  String get commerceProductTemplateEmotion;

  /// No description provided for @commerceProductTemplateNarrative.
  ///
  /// In en, this message translates to:
  /// **'Story sketch'**
  String get commerceProductTemplateNarrative;

  /// No description provided for @authRegisterSummaryLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get authRegisterSummaryLocation;

  /// No description provided for @authRegisterLocationCaptured.
  ///
  /// In en, this message translates to:
  /// **'Captured (optional)'**
  String get authRegisterLocationCaptured;

  /// No description provided for @authRegisterSummaryCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get authRegisterSummaryCity;

  /// No description provided for @authRegisterLocationPendingCity.
  ///
  /// In en, this message translates to:
  /// **'Located — city will be filled automatically'**
  String get authRegisterLocationPendingCity;

  /// No description provided for @profileCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get profileCity;

  /// No description provided for @profileCityHint.
  ///
  /// In en, this message translates to:
  /// **'Detected from location; shown read-only'**
  String get profileCityHint;
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
