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

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back to your global post office.'**
  String get authWelcomeBack;

  /// No description provided for @authMockTip.
  ///
  /// In en, this message translates to:
  /// **'Mock mode is enabled. You can try all flows without backend APIs.'**
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
  /// **'Send postcards and letters at your own pace. No like-count pressure.'**
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
  /// **'OSS upload requires Mock off: flutter run --dart-define=USE_MOCK=false …'**
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
  /// **'Mock: postcard published (+1 stamp)'**
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

  /// No description provided for @directoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Post Directory'**
  String get directoryTitle;

  /// No description provided for @directorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find pen pals by country and interests'**
  String get directorySubtitle;

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
  /// **'Try clearing filters or changing age range.'**
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

  /// No description provided for @authCountryAutoLabel.
  ///
  /// In en, this message translates to:
  /// **'Region (from app language)'**
  String get authCountryAutoLabel;

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
  /// **'Mock: profile updated'**
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

  /// No description provided for @profileStampsLedger.
  ///
  /// In en, this message translates to:
  /// **'Stamps ledger'**
  String get profileStampsLedger;

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
  /// **'English / 中文 / System'**
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
  /// **'Follow system'**
  String get settingsLanguageSystem;

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
