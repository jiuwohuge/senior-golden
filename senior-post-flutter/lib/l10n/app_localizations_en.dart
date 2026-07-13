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
  String get appTagline => 'A calm post office for trusted pen pals.';

  @override
  String get tabPostWall => 'Post Office';

  @override
  String get tabDirectory => 'Pen Pals';

  @override
  String get tabMailbox => 'Mailbox';

  @override
  String get tabProfile => 'Me';

  @override
  String get a11yTabPostWall =>
      'Post Office: write letters, messages and in-transit mail';

  @override
  String get a11yTabDirectory =>
      'Pen Pals: recommendations, search and my pen pals';

  @override
  String get a11yTabMailbox => 'Mailbox: received, sent and time letters';

  @override
  String get postOfficeGreeting => 'Good morning';

  @override
  String get postOfficeTodayHint =>
      'Write your first letter and wait for a reply';

  @override
  String get postOfficeWriteLetter => 'Write a letter';

  @override
  String postOfficeFreeQuotaHint(int count) {
    return '$count free letters left today';
  }

  @override
  String postOfficeMessagesSummary(int count) {
    return 'Messages · $count';
  }

  @override
  String postOfficeInTransitSummary(int count) {
    return 'In transit · $count';
  }

  @override
  String get a11yTabProfile => 'Me: profile, saved letters and settings';

  @override
  String get a11yNavBar => 'Main sections of the app';

  @override
  String get placeholderWelcomeTitle => 'This area is being prepared';

  @override
  String get placeholderWelcomeBody =>
      'We are finishing this screen. Your postcards, letters, and friends will appear here soon. Thank you for your patience.';

  @override
  String get placeholderHint =>
      'Tip: use the bar below to switch between Topics, Pen Pals, My Mailbox, and Memorial.';

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
  String get authWelcomeRegister => 'Create account';

  @override
  String get authWelcomeLogin => 'Sign in';

  @override
  String get authWelcomeHaveAccount => 'Already have an account?';

  @override
  String get authWelcomeHighlightLetters =>
      'Write and receive real letters at a calm pace';

  @override
  String get authWelcomeHighlightDirectory =>
      'Meet pen pals worldwide in the directory';

  @override
  String get authWelcomeHighlightPace => 'Designed for adults 45 and over';

  @override
  String get authWelcomeTagline => 'Letters at your pace — for adults 45+';

  @override
  String authWelcomeLegalFooter(Object privacy, Object terms) {
    return 'By signing up, you accept our $terms and $privacy.';
  }

  @override
  String get authRegisterWizardEmailTitle => 'What\'s your email?';

  @override
  String get authRegisterWizardEmailSubtitle =>
      'We\'ll use it for sign-in and important notices about your post.';

  @override
  String get authRegisterWizardPasswordTitle => 'Choose a password';

  @override
  String get authRegisterWizardPasswordSubtitle =>
      'At least 8 characters. Keep it somewhere safe.';

  @override
  String get authRegisterWizardNameTitle => 'What should we call you?';

  @override
  String get authRegisterWizardNameSubtitle =>
      'This name appears on postcards, letters, and the directory.';

  @override
  String get authRegisterWizardGenderTitle => 'How do you identify?';

  @override
  String get authRegisterWizardGenderSubtitle =>
      'Helps us show you the right people in the directory.';

  @override
  String get authRegisterWizardAgeTitle => 'How old are you?';

  @override
  String get authRegisterWizardAgeSubtitle =>
      'Your birth year helps us tailor the community for 45+.';

  @override
  String get authRegisterProfileHint => 'This info shows on your profile.';

  @override
  String authRegisterAgePreview(Object age) {
    return 'I\'m $age';
  }

  @override
  String get authRegisterSummaryGender => 'Gender';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authOrContinueWithEmail => 'or sign in with email';

  @override
  String get authGoogleNotConfigured => 'Google sign-in is not configured yet';

  @override
  String get authGenderLabel => 'Gender';

  @override
  String get authGenderMale => 'Male';

  @override
  String get authGenderFemale => 'Female';

  @override
  String get authRegisterAvatarOptional => 'Profile photo (optional)';

  @override
  String get authRegisterAvatarSkipHint =>
      'You can skip and add a photo later in My Post.';

  @override
  String get authRegisterWizardAvatarTitle => 'Show us your smile';

  @override
  String get authRegisterWizardAvatarSubtitle =>
      'Add a friendly photo of yourself — a smile goes a long way.';

  @override
  String get authRegisterAvatarTapToAdd => 'Tap to add a photo';

  @override
  String get authRegisterAvatarAgreeFirst =>
      'Please accept the terms below before uploading a photo';

  @override
  String get authRegisterAvatarUploading => 'Uploading photo…';

  @override
  String get authRegisterAvatarUploaded => 'Uploaded';

  @override
  String get authRegisterSummaryAvatarPending => 'Selected, pending upload';

  @override
  String get authRegisterSummaryAvatar => 'Photo';

  @override
  String get authRegisterSummaryAvatarSet => 'Selected — uploads after sign-up';

  @override
  String get authRegisterSummaryAvatarSkipped => 'Skipped';

  @override
  String get authSocialCompleteTitle => 'Complete your profile';

  @override
  String get directoryFilterGender => 'Gender';

  @override
  String get directoryFilterGenderHint =>
      'Optional — leave all selected to show everyone.';

  @override
  String get directoryFilterGenderAll => 'All';

  @override
  String get directoryFilterInterests => 'Interest tags';

  @override
  String get directoryFilterInterestsHint =>
      'Optional — pick one or more to narrow pen pals by shared hobbies.';

  @override
  String get directoryFilterInterestsEmpty =>
      'No interest tags from the server. Try another language or ask an admin to add tags.';

  @override
  String get directoryFilterApply => 'Apply filters';

  @override
  String get directoryFilterClear => 'Clear';

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
      'Sign in with your registered email to use all features.';

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
  String get authForgotIntro =>
      'We\'ll email a 6-digit code to your registered address. In local dev, check server logs if SMTP is not configured.';

  @override
  String get authForgotCodeHint => '6-digit code';

  @override
  String get authForgotResetSuccess => 'Password updated. You can sign in now.';

  @override
  String get authForgotCodeInvalid => 'Enter the 6-digit code';

  @override
  String get authOnboardingAgain => 'View introduction';

  @override
  String get authEmailInvalid => 'Please enter a valid email address';

  @override
  String get authRegisterSubtitle =>
      'Create your postal social account in one minute.';

  @override
  String get authRegisterWizardHint =>
      'Tap any step below to jump — your entries stay until you submit.';

  @override
  String get authRegisterTabAccount => 'Account';

  @override
  String get authRegisterTabProfile => 'Profile';

  @override
  String get authRegisterTabInterests => 'Interests';

  @override
  String get authRegisterTabReview => 'Review';

  @override
  String authRegisterStepProgress(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String get authRegisterStepAccountTitle => 'Sign-in details';

  @override
  String get authRegisterStepAccountSubtitle =>
      'We’ll use your email to reach you about letters and security.';

  @override
  String get authRegisterStepProfileTitle => 'About you';

  @override
  String get authRegisterStepProfileSubtitle =>
      'This is how you appear on postcards, letters, and the directory.';

  @override
  String get authRegisterStepInterestsTitle => 'Interests';

  @override
  String get authRegisterStepInterestsSubtitle =>
      'Choose at least three tags — they power better pen-pal matches.';

  @override
  String get authRegisterStepReviewTitle => 'Review & terms';

  @override
  String get authRegisterStepReviewSubtitle =>
      'Check your details, then accept the policies to open your account.';

  @override
  String get authRegisterNext => 'Continue';

  @override
  String get authRegisterBack => 'Back';

  @override
  String get authRegisterSummaryEmail => 'Email';

  @override
  String get authRegisterSummaryNickname => 'Nickname';

  @override
  String get authRegisterSummaryBirth => 'Year of birth';

  @override
  String get authRegisterSummaryCountry => 'Country / region';

  @override
  String get authRegisterSummaryInterests => 'Interests';

  @override
  String get authRegisterInterestsMin =>
      'Please select at least three interests.';

  @override
  String get authRegisterInterestsServerEmpty =>
      'No interest tags from the server. Try another language or ask an admin to add tags.';

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
  String get commonRetry => 'Retry';

  @override
  String get postWallUnavailable => 'Post wall is temporarily unavailable';

  @override
  String get postWallEmptyTitle => 'No postcards yet';

  @override
  String get postWallEmptySubtitle => 'Be the first to share a postcard today.';

  @override
  String get postWallWriteAction => 'Write postcard';

  @override
  String get postWallFAB => 'Write';

  @override
  String get postWallFeedEveryone => 'Everyone';

  @override
  String get postWallFeedConnections => 'Connections';

  @override
  String get postWallEmptyConnectionsSubtitle =>
      'No postcards from your postal friends yet. Connect through letters first.';

  @override
  String get userCardFriendPostcardsTitle => 'Their postcards';

  @override
  String get userCardFriendPostcardsSubtitle =>
      'Recent posts from your postal friend';

  @override
  String get userCardFriendPostcardsEmpty => 'No public postcards yet';

  @override
  String get userCardLoadMorePostcards => 'Load more';

  @override
  String get postComposeRejected =>
      'Your postcard was not approved. Please revise and try again.';

  @override
  String postWallPhotosLabel(Object count) {
    return '$count photos';
  }

  @override
  String get postWallSendLetterTooltip => 'Send letter';

  @override
  String postWallCommentsCount(Object count) {
    return 'Comments $count';
  }

  @override
  String get postComposeTitle => 'Write postcard';

  @override
  String get postComposeSectionTitle => 'Compose';

  @override
  String get postComposeSectionSubtitle => 'Write one postcard for today';

  @override
  String get postComposeContentLabel => 'Postcard content';

  @override
  String get postComposeContentHint =>
      'Write your day, thoughts, or greetings…';

  @override
  String postComposeMaxImages(Object max) {
    return 'At most $max images';
  }

  @override
  String get postComposeUploadNeedRealApi =>
      'Image upload needs a server-issued URL. Check your network and try again.';

  @override
  String get postComposePickerChannelError =>
      'Gallery channel not connected. Fully stop the app and run again; if it persists run flutter clean.';

  @override
  String get postComposeImageUploaded => 'Image uploaded';

  @override
  String get postComposeNeedContent => 'Please write something first.';

  @override
  String get postComposePublishedMock => 'Postcard submitted.';

  @override
  String get postComposePublishedReal =>
      'Submitted for review. It will appear after approval.';

  @override
  String get postComposeUploading => 'Uploading…';

  @override
  String get postComposeAddImage => 'Add image (OSS)';

  @override
  String postComposeAddAnother(Object n, Object max) {
    return 'Add another ($n/$max)';
  }

  @override
  String get postComposePublish => 'Publish now';

  @override
  String get postcardImageCropTitle => 'Crop image (4:3)';

  @override
  String get postcardImageCropHelp =>
      'Pan and zoom, then confirm to crop to 4:3 and upload.';

  @override
  String get profileBlacklist => 'Blocked users';

  @override
  String get settingsFeedback => 'Send feedback';

  @override
  String get dialogConfirm => 'OK';

  @override
  String get socialBlockUser => 'Block';

  @override
  String get socialBlockConfirmTitle => 'Block this user?';

  @override
  String get socialBlockConfirmMessage =>
      'They won\'t be able to send you letters, and you won\'t see each other on the wall or directory.';

  @override
  String get socialBlockSuccess => 'User blocked';

  @override
  String get socialUnblock => 'Unblock';

  @override
  String socialUnblockConfirm(Object name) {
    return 'Unblock $name?';
  }

  @override
  String get socialUnblockSuccess => 'Unblocked';

  @override
  String get socialBlacklistTitle => 'Blocked users';

  @override
  String get socialBlacklistSubtitle =>
      'Blocked users won\'t appear on the wall or directory and can\'t send you letters.';

  @override
  String get socialBlacklistEmpty => 'No blocked users';

  @override
  String socialBlockedAt(Object time) {
    return 'Blocked at: $time';
  }

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get feedbackBodyLabel => 'Your message (required)';

  @override
  String get feedbackBodyHint =>
      'Describe steps, what you expected, and what happened.';

  @override
  String get feedbackSubmit => 'Submit';

  @override
  String get feedbackSubmitting => 'Submitting…';

  @override
  String get feedbackSuccess => 'Thanks — we\'ll review it soon.';

  @override
  String get feedbackNeedContent => 'Please enter your feedback.';

  @override
  String get userCardTitle => 'Member profile';

  @override
  String get userCardSendLetter => 'Send letter';

  @override
  String get userCardBack => 'Back';

  @override
  String get userCardBioSection => 'Introduction';

  @override
  String get userCardBioEmpty => 'No introduction yet.';

  @override
  String get userCardReportUser => 'Report';

  @override
  String get userCardReportSheetTitle => 'Report this member';

  @override
  String get userCardErrorTitle => 'Unable to load profile';

  @override
  String get userCardNotFoundTitle => 'Profile not found';

  @override
  String get userCardNotFoundSubtitle =>
      'This member may be unavailable or restricted for you.';

  @override
  String get directoryTitle => 'Pen Pal Hall';

  @override
  String get directorySubtitle =>
      'Read a profile first, then write one thoughtful letter. This is not fast matching.';

  @override
  String get directoryFilterCta => 'Filter pen pals';

  @override
  String get directorySafetyTitle => 'Letters before anything else';

  @override
  String get directorySafetyBody =>
      'Profiles are only a beginning. Avoid money, investment, verification codes, and private contact requests until trust is real.';

  @override
  String get directoryListTitle => 'People open to letters';

  @override
  String get directoryListSubtitle =>
      'Choose by story and shared interests, not by speed.';

  @override
  String get directoryLetterFirstBadge => 'Letter first';

  @override
  String get directoryViewProfile => 'Read profile';

  @override
  String get directoryBioFallback =>
      'This member has not written a self-introduction yet. You can read their interests before deciding whether to write.';

  @override
  String get directoryInterestEmpty => 'Interests to be added';

  @override
  String directoryMoreInterests(Object count) {
    return '+$count more';
  }

  @override
  String get directoryLoadFailed => 'Unable to load directory';

  @override
  String get directoryEmptyTitle => 'No matching members';

  @override
  String get directoryEmptySubtitle =>
      'Try clearing filters, or come back after new official topics bring more letters.';

  @override
  String directoryAgeYears(Object age) {
    return '$age years old';
  }

  @override
  String get authBirthYearSheetTitle => 'Year of birth';

  @override
  String authBirthYearFormat(Object year, Object age) {
    return '$year ($age)';
  }

  @override
  String get authCountryAutoLabel => 'Region (from app language)';

  @override
  String get authEmailHint => 'name@example.com';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileNickname => 'Nickname';

  @override
  String get profileCountry => 'Country';

  @override
  String get profileBio => 'Bio';

  @override
  String get profileSave => 'Save';

  @override
  String get profileMockUpdated => 'Profile updated';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get profileAvatarChange => 'Change profile photo';

  @override
  String get profileAvatarCropTitle => 'Crop photo';

  @override
  String get profileAvatarCropDone => 'Done';

  @override
  String get profileAvatarCropCancel => 'Cancel';

  @override
  String get profileAvatarCropConfirm => 'Confirm crop';

  @override
  String get profileAvatarCropHelp =>
      'Drag and pinch to fit your face in the circle. Cancel returns without saving.';

  @override
  String get profileAvatarPreviewHint =>
      'Adjust the circle, then confirm crop. On the previous screen, tap Upload photo to save, or Discard to cancel.';

  @override
  String get profileAvatarConfirmUpload => 'Upload photo';

  @override
  String get profileAvatarDiscardUpload => 'Discard';

  @override
  String get profileAvatarUploadSuccess => 'Profile photo updated';

  @override
  String get profileAvatarUploadFailed => 'Could not upload photo';

  @override
  String get profileAvatarUploading => 'Uploading photo…';

  @override
  String get profileAvatarAuditPending => 'Under review';

  @override
  String get profileAvatarAuditRejected => 'Rejected';

  @override
  String get profileAvatarUploadPendingReview => 'Photo submitted for review';

  @override
  String get profileAvatarRejectedHint =>
      'Photo was not approved. Please upload again.';

  @override
  String get profileEditCancel => 'Close';

  @override
  String get profileEditProfile => 'Edit profile';

  @override
  String get profileInterestTags => 'Interest tags';

  @override
  String get profileStampsLedger => 'Stamps ledger';

  @override
  String get profileVipCenter => 'VIP center';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileAbout => 'About';

  @override
  String get profileUserAgreement => 'User Agreement';

  @override
  String get profilePrivacyPolicy => 'Privacy Policy';

  @override
  String get profileLogout => 'Log out';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPushNotifications => 'Push notifications';

  @override
  String get settingsUnreadBadges => 'Show unread badges';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSubtitle =>
      'Follow device by default; override for testing';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageChinese => '中文';

  @override
  String get settingsLanguageSystem => 'Follow device';

  @override
  String get settingsEmailVerify => 'Verify email';

  @override
  String get settingsEmailVerifyPending => 'Not verified — tap to bind';

  @override
  String get settingsEmailVerifyDone => 'Verified';

  @override
  String get settingsEmailVerifyTitle => 'Email verification';

  @override
  String settingsEmailVerifyHint(String email) {
    return 'We will send a code to $email';
  }

  @override
  String get settingsEmailVerifyCodeLabel => 'Verification code';

  @override
  String get settingsEmailVerifySendCode => 'Send code';

  @override
  String get settingsEmailVerifyConfirm => 'Confirm';

  @override
  String get settingsEmailVerifyCodeSent => 'Verification code sent';

  @override
  String get settingsEmailVerifyCodeRequired => 'Please enter the code';

  @override
  String get settingsEmailVerifySuccess => 'Email verified';

  @override
  String get authLoginChallengeTitle => 'Confirm it\'s you';

  @override
  String get authLoginChallengeHint =>
      'Unusual sign-in detected. Enter the code sent to your email.';

  @override
  String get authLoginChallengeSend => 'Send code';

  @override
  String get authLoginChallengeConfirm => 'Verify and continue';

  @override
  String get authLoginChallengeCodeSent => 'Code sent';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get legalEffectiveDate => 'Effective date: 2026-05-01';

  @override
  String get legalTermsContent =>
      '1) This app provides interest-based social communication for adults aged 45+ only.\\n\\n2) The product does not provide dating or matchmaking services.\\n\\n3) You are responsible for the legality of your content and must not publish prohibited content.\\n\\n4) We may suspend accounts for abuse, harassment, spam, fraud, or policy violations.\\n\\n5) We provide moderation and reporting mechanisms to maintain a safe communication environment.';

  @override
  String get legalPrivacyContent =>
      '1) We collect account and device information required for security and fraud prevention.\\n\\n2) We process your data under applicable privacy laws and provide deletion/export pathways.\\n\\n3) We never sell personal data.\\n\\n4) Some data processing is required to deliver core messaging and moderation services.\\n\\n5) You can contact support to request account deletion and related data removal.';

  @override
  String get vipCenterUnlimitedRegisteredMail =>
      'Unlimited registered mail for members (server rules apply).';

  @override
  String vipCenterStandardPriorityHours(Object hours) {
    return 'Standard mail priority: ~${hours}h (configured).';
  }

  @override
  String get vipCenterFreeSpeedUpStandard =>
      'Free speed-up on standard mail for members (server rules apply).';

  @override
  String get vipCenterPurchaseDisabled => 'VIP purchase is currently disabled.';

  @override
  String get vipCenterCheckoutNotWired =>
      'Subscription checkout is not wired yet; benefits follow your account VIP flag.';

  @override
  String vipCenterLoadFailed(Object error) {
    return 'Failed to load VIP info: $error';
  }

  @override
  String get profileMyPostcards => 'My postcards';

  @override
  String get myPostcardsEmptyTitle => 'No postcards yet';

  @override
  String get myPostcardsEmptySubtitle =>
      'Write one from the Post Wall tab — it will appear here with review status.';

  @override
  String get myPostcardsLoadFailedTitle => 'Could not load postcards';

  @override
  String get postcardReviewPendingBadge => 'Pending review';

  @override
  String get postcardReviewApprovedBadge => 'Approved';

  @override
  String get postcardReviewRejectedBadge => 'Rejected';

  @override
  String get postcardPostHiddenBadge => 'Hidden';

  @override
  String get postcardPostRemovedBadge => 'Removed';

  @override
  String get postcardReviewPendingBanner =>
      'This postcard is pending review. Only you can see it here.';

  @override
  String get postcardReviewRejectedBanner =>
      'This postcard was not approved for the public wall. You can still view it from your list.';

  @override
  String get letterMailboxSealedPreview => 'Letter sealed until arrival';

  @override
  String get letterContentHiddenHint =>
      'This letter is still on its way. The message stays sealed until it arrives.';

  @override
  String get letterEarlyOpenCta => 'Open early (1 stamp)';

  @override
  String get letterEarlyOpenSuccess =>
      'Letter opened — full message is now visible.';

  @override
  String get postDetailTitle => 'Postcard';

  @override
  String get letterDetailTitle => 'Letter';

  @override
  String get letterModePostOffice => 'Post office';

  @override
  String get letterModeDirect => 'Direct';

  @override
  String get letterModeSelfTime => 'Time letter (SELF_TIME)';

  @override
  String letterModeLine(String mode) {
    return 'Mode: $mode';
  }

  @override
  String get letterStatusMatched => 'Matched';

  @override
  String get letterAuditPending => 'Pending review';

  @override
  String get letterAuditApproved => 'Approved';

  @override
  String get letterAuditRejected => 'Rejected';

  @override
  String letterAuditLine(String status) {
    return 'Audit: $status';
  }

  @override
  String get letterEtaLabel => 'Estimated arrival';

  @override
  String get letterDeliveredLabel => 'Delivered';

  @override
  String get letterPeerPostOfficePool => 'Post office pool';

  @override
  String get letterPeerUnknown => 'Unknown recipient';

  @override
  String get letterAcceptContact => 'Add pen pal';

  @override
  String get letterAcceptContactDone => 'Request sent';

  @override
  String get letterAcceptContactSuccess =>
      'Pen pal request sent. After they accept, find them under My pen pals.';

  @override
  String get postDetailCommentRequired => 'Please enter a comment.';

  @override
  String get postDetailCommentPosted => 'Comment posted.';

  @override
  String get postDetailReply => 'Reply';

  @override
  String postDetailReplyingTo(Object name) {
    return 'Replying to @$name';
  }

  @override
  String get postDetailCancelReply => 'Cancel';

  @override
  String get postDetailLike => 'Like';

  @override
  String get postDetailReportComment => 'Report';

  @override
  String get postDetailCommentsSection => 'Comments';

  @override
  String get postDetailReplyPrefix => 'Reply';

  @override
  String get postDetailWriteComment => 'Write a comment';

  @override
  String get postDetailSendComment => 'Send';

  @override
  String get postDetailNoCommentsTitle => 'No comments yet';

  @override
  String get postDetailNoCommentsSubtitle => 'Start the first kind reply.';

  @override
  String get errorInvalidContentId => 'Invalid content id.';

  @override
  String get errorInvalidResponse => 'Invalid response from server.';

  @override
  String get directoryFilterSectionTitle => 'Filter directory';

  @override
  String get directoryFilterSectionSubtitle =>
      'Country, age range, interests, and sort';

  @override
  String get directoryFilterCountryLabel => 'Country';

  @override
  String get directoryFilterSort => 'Sort';

  @override
  String get directoryFilterNewest => 'Newest';

  @override
  String get directoryFilterClosestAge => 'Closest age';

  @override
  String get directoryFilterSharedInterests => 'Shared interests';

  @override
  String get directoryFilterAllCountries => 'All countries';

  @override
  String directoryFilterMinAge(Object age) {
    return 'Min age: $age';
  }

  @override
  String directoryFilterMaxAge(Object age) {
    return 'Max age: $age';
  }

  @override
  String get mailboxArchiveTitle => 'Letter archive';

  @override
  String get mailboxOpenArchive => 'Archive';

  @override
  String get mailboxPostOnTheWay => 'A post is on the way';

  @override
  String get shopTitleStampsVip => 'Stamps & membership';

  @override
  String get shopPlaceholderOrders => 'Orders & history (placeholder)';

  @override
  String get shopPlaceholderBuy => 'Buy (placeholder)';

  @override
  String get shopOrdersSnackbar =>
      'Orders and payment history will open once the catalog is connected.';

  @override
  String get shopPricePlaceholder => 'Price: —';

  @override
  String get shopCheckoutSnackbar =>
      'Checkout opens when payments are connected.';

  @override
  String shopSkuStampLine(Object count) {
    return '×$count stamps';
  }

  @override
  String get interestsPickerSaved => 'Interests saved.';

  @override
  String get reportReasonRequired => 'Please enter a report reason.';

  @override
  String get reportSubmitted => 'Report submitted.';

  @override
  String get accountDeleteTitle => 'Delete account';

  @override
  String get stampsLedgerTitle => 'Stamps ledger';

  @override
  String get interestsPickerTitle => 'Interest tags';

  @override
  String get sendLetterRegisteredMail => 'Registered Mail';

  @override
  String get sendLetterStandardPost => 'Standard Post';

  @override
  String get sendLetterBodyRequired => 'Please write the letter content.';

  @override
  String get sendLetterRegisteredStampShort =>
      'Not enough stamps for registered mail.';

  @override
  String get sendLetterSentSuccess => 'Letter sent.';

  @override
  String get sendLetterSentSuccessTitle => 'Letter sent';

  @override
  String get sendLetterSentSuccessMessage =>
      'Your letter is on its way. They will find it in their Post Box.';

  @override
  String sendLetterSheetTitle(Object name) {
    return 'Send letter to $name';
  }

  @override
  String get sendLetterRegisteredSubVip => 'Free for VIP';

  @override
  String get sendLetterRegisteredSubPaid => 'Consumes 1 stamp';

  @override
  String get sendLetterStandardSub => 'Free, delayed delivery';

  @override
  String get sendLetterContentLabel => 'Letter content';

  @override
  String get mailboxTabReceived => 'Received';

  @override
  String get mailboxTabSent => 'Sent';

  @override
  String get mailboxTabTimeLetter => 'Time letter';

  @override
  String get mailboxReceivedEmptyTitle => 'No received letters';

  @override
  String get mailboxReceivedEmptySubtitle =>
      'Letters from the post office or pen pals appear here.';

  @override
  String get mailboxSentEmptyTitle => 'No sent letters';

  @override
  String get mailboxSentEmptySubtitle =>
      'Letters you send stay here until the recipient has read them.';

  @override
  String get directoryTabRecommend => 'For you';

  @override
  String get directoryTabFind => 'Find pen pals';

  @override
  String get directoryTabMyPenpals => 'My pen pals';

  @override
  String get directoryRecommendEmpty => 'No recommendations today';

  @override
  String get directoryRecommendEmptyHint =>
      'Check back tomorrow, or browse Find pen pals.';

  @override
  String get directoryPenpalsEmpty => 'No pen pals yet';

  @override
  String get directoryPenpalsEmptyHint =>
      'After enough letters, send a pen pal request. Confirmed pals appear here.';

  @override
  String get directoryWriteLetter => 'Write';

  @override
  String penpalListMeta(Object days, Object count) {
    return 'Pen pal ${days}d · $count letters';
  }

  @override
  String get postOfficeRelationMessagesTitle => 'Relation messages';

  @override
  String get postOfficeRelationMessagesEmpty => 'No relation messages';

  @override
  String get postOfficeRelationMessagesEmptyHint =>
      'Pen pal requests and add-pen-pal reminders show up here.';

  @override
  String penpalExchangeCount(Object count) {
    return '$count letters exchanged';
  }

  @override
  String get penpalAccept => 'Accept';

  @override
  String get penpalIgnore => 'Ignore';

  @override
  String get penpalAcceptSuccess => 'You are now pen pals';

  @override
  String get penpalRequestSent => 'Pen pal request sent';

  @override
  String get relationAddPenpal => 'Add pen pal';

  @override
  String get relationAddPenpalSuccess =>
      'Request sent — waiting for confirmation';

  @override
  String get relationStateStranger => 'Stranger';

  @override
  String get relationStateContacting => 'In correspondence';

  @override
  String get relationStateCanAddPenpal => 'Can add pen pal';

  @override
  String get relationStatePendingOut => 'Request sent';

  @override
  String get relationStatePendingIn => 'Awaiting you';

  @override
  String get relationStatePenpal => 'Pen pal';

  @override
  String get userCardWriteFirstLetter => 'Write first letter';

  @override
  String get userCardContinueWriting => 'Keep writing';

  @override
  String get profileOverviewPenpals => 'Pen pals';

  @override
  String get profileOverviewLetters => 'Letters';

  @override
  String get profileOverviewTimeLetters => 'Time letters';

  @override
  String get profileSectionMyContent => 'My content';

  @override
  String get profileSectionShop => 'Shop & membership';

  @override
  String get profileSectionPrivacy => 'Privacy & safety';

  @override
  String get profileTimeLetterDrafts => 'Time letters';

  @override
  String get profilePrivacyRecommendPlaceholder =>
      'Hide recommendations (coming soon)';

  @override
  String get profilePrivacyStrangerPlaceholder =>
      'Decline stranger mail (coming soon)';

  @override
  String get commonLoadFailed => 'Unable to load';

  @override
  String get timeLetterComposeTitle => 'Time Post Office';

  @override
  String get timeLetterComposeToSelf => 'Letter to future me';

  @override
  String timeLetterComposeToFriend(Object name) {
    return 'To $name';
  }

  @override
  String get timeLetterDeliveryDate => 'Delivery date';

  @override
  String timeLetterDaysUntil(Object days) {
    return '$days days until delivery';
  }

  @override
  String get timeLetterBodyHint =>
      'Write what you want your future self or friend to read…';

  @override
  String get timeLetterBodyEmpty => 'Please write your letter.';

  @override
  String get timeLetterSealSlide => 'Slide to seal';

  @override
  String get timeLetterSealSuccessTitle => 'Sealed';

  @override
  String get timeLetterSealSuccessMessage =>
      'Your time letter is on its way. It will arrive on the date you chose.';

  @override
  String get timeLetterTabOutbox => 'Outbox';

  @override
  String get timeLetterTabInbox => 'Inbox';

  @override
  String get timeLetterTabMemorial => 'Memorial';

  @override
  String get timeLetterEmptyTitle => 'No time letters yet';

  @override
  String get timeLetterEmptySubtitle =>
      'Write to your future self or a postal friend.';

  @override
  String get timeLetterLoadError => 'Could not load time letters';

  @override
  String get timeLetterSealedHidden => 'Sealed — content hidden until delivery';

  @override
  String get timeLetterTapToOpen => 'Tap to open when delivered';

  @override
  String get timeLetterCancelTitle => 'Cancel this letter?';

  @override
  String get timeLetterCancelMessage =>
      'Stamps will be refunded if you cancel within 24 hours.';

  @override
  String get timeLetterOpenTitle => 'Open time letter';

  @override
  String get timeLetterOpenRitual => 'Open the envelope';

  @override
  String timeLetterReadEstimate(Object minutes) {
    return 'About $minutes min read';
  }

  @override
  String get timeLetterStar => 'Add to memorial';

  @override
  String get timeLetterStarred => 'In memorial';

  @override
  String get timeLetterSendToFriend => 'Time letter';

  @override
  String timeLetterBanner(Object inFlight, Object unread, Object today) {
    return '$inFlight in transit · $unread to open · $today arrived today';
  }

  @override
  String get topicFriendFallback => 'friend';

  @override
  String topicTodayGreeting(Object name) {
    return 'Good to see you, $name';
  }

  @override
  String get topicTodayIntro =>
      'There is no rush here. Read what has arrived, write one thoughtful letter, or pick a topic for today.';

  @override
  String get topicTodayLetters => 'Letters needing attention';

  @override
  String topicTodayLettersCount(Object count) {
    return '$count letters';
  }

  @override
  String get topicTodayLoading => 'Loading';

  @override
  String get topicTodayTime => 'Time letters';

  @override
  String topicTodayTimeLetters(Object inFlight, Object unread) {
    return '$inFlight waiting · $unread ready';
  }

  @override
  String get topicTodayTimeLettersLoading => 'Checking';

  @override
  String get topicWriteLetter => 'Write a letter';

  @override
  String get topicOpenMailbox => 'Open mailbox';

  @override
  String get topicOfficialLetterTitle => 'A note from the Post Office';

  @override
  String get topicOfficialIdentity => 'Official letter · clearly marked';

  @override
  String get topicOfficialLetterBody =>
      'Today you can write about a memory, a meal, or a place you miss. We will never pretend an official note is a real pen pal.';

  @override
  String get topicOfficialCta => 'Write to future me';

  @override
  String get topicDailyTitle => 'Today\'s topic mailboxes';

  @override
  String get topicDailySubtitle =>
      'Choose one gentle prompt. A good letter is better than a long scroll.';

  @override
  String get topicWriteToTopic => 'Write here';

  @override
  String get topicOfficialExample => 'Official example';

  @override
  String get topicTodayTopic => 'Today';

  @override
  String get topicHometownTitle => 'Hometown memories';

  @override
  String get topicHometownPrompt =>
      'Describe a road, a market, or a familiar doorway from the place you still remember.';

  @override
  String get topicRetirementTitle => 'A quiet day after retirement';

  @override
  String get topicRetirementPrompt =>
      'Write about one ordinary moment that made you feel comfortable recently.';

  @override
  String get topicOldPhotoTitle => 'The story behind an old photo';

  @override
  String get topicOldPhotoPrompt =>
      'Pick a person, place, or season from an old photo and write what still stays with you.';

  @override
  String get topicSafetyTitle => 'A calmer way to meet pen pals';

  @override
  String get topicSafetyBody =>
      'Money, investment, verification codes and private contact requests will be treated carefully. You can write slowly and decide slowly.';

  @override
  String get composeTitle => 'Write a letter';

  @override
  String get composeStepDestinationTitle => 'Who is this letter for?';

  @override
  String get composeStepDestinationSubtitle =>
      'One step at a time. There is no rush.';

  @override
  String get composeStepFooter =>
      'Basic letter writing is never blocked by payment.';

  @override
  String get composeChooseSelf => 'To myself (time letter)';

  @override
  String get composeChooseSelfSub => 'SELF_TIME — open on a future date';

  @override
  String get composeChoosePenPal => 'To a pen pal';

  @override
  String get composeChoosePenPalSub => 'DIRECT — send to someone you know';

  @override
  String get composeChooseTopic => 'To a topic mailbox';

  @override
  String get composeChooseTopicSub => 'Start from today\'s gentle prompt';

  @override
  String get composeChoosePostOffice => 'To the post office';

  @override
  String get composeChoosePostOfficeSub =>
      'POST_OFFICE — no recipient; wait for a match';

  @override
  String get composeBodySubtitlePostOffice =>
      'Write freely — the post office will find a reader.';

  @override
  String get composePostOfficeSendHint =>
      'This letter goes into the post office pool';

  @override
  String get composePickDestinationRequired =>
      'Please choose who you are writing to';

  @override
  String get composeStepPenPalTitle => 'Choose a pen pal';

  @override
  String get composeStepPenPalSubtitle =>
      'Start with someone you already connected with. If you have none yet, visit the pen pal hall first.';

  @override
  String get composePickPenPalRequired => 'Please choose a pen pal';

  @override
  String get composePenPalEmptyTitle => 'No pen pals yet';

  @override
  String get composePenPalEmptySubtitle =>
      'Visit the pen pal hall, read profiles, and send your first thoughtful letter.';

  @override
  String get composePenPalLoadFailed => 'Could not load pen pals';

  @override
  String get composeGoDirectory => 'Go to pen pals';

  @override
  String get composeStepTopicTitle => 'Choose a topic';

  @override
  String get composeStepTopicSubtitle => 'Pick one gentle prompt for today.';

  @override
  String get composePickTopicRequired => 'Please choose a topic';

  @override
  String get composeStepBodyTitle => 'Write the letter';

  @override
  String get composeBodyLabel => 'Letter body';

  @override
  String get composeBodyFooter =>
      'Thoughtful writing matters more than length.';

  @override
  String get composeBodyRequired => 'Please write the letter body first';

  @override
  String get composeBodySubtitleSelf =>
      'To your future self — a memory, a wish, or how today feels.';

  @override
  String composeBodySubtitlePenPal(Object name) {
    return 'A thoughtful letter to $name.';
  }

  @override
  String composeBodySubtitleTimePenPal(Object name) {
    return 'A time letter to $name, delivered on the date you choose.';
  }

  @override
  String get composeBodySubtitleTopic => 'Write about the topic you selected.';

  @override
  String get composeStepDeliveryTitle => 'Choose delivery date';

  @override
  String get composeStepDeliverySubtitle =>
      'The time letter stays sealed until that date.';

  @override
  String get composeStepMailTitle => 'Choose template & paper';

  @override
  String get composeStepMailSubtitle =>
      'Pick a template and paper first, then write the body.';

  @override
  String get composeStepSealTitle => 'Seal and send';

  @override
  String get composeStepSealSubtitle =>
      'After sealing, the letter waits until delivery day.';

  @override
  String get composeStepSendTitle => 'Ready to send';

  @override
  String get composeStepSendSubtitle =>
      'Track status in My Mailbox after sending.';

  @override
  String get composeSendNow => 'Send now';

  @override
  String get composeStepPreviewTitle => 'Preview letter';

  @override
  String get composeStepPreviewSubtitle =>
      'Confirm paper and text before sending.';

  @override
  String get composeStepTopicSubmitTitle => 'Submit to topic mailbox';

  @override
  String get composeStepTopicSubmitSubtitle =>
      'After review, approved submissions become visible to others.';

  @override
  String get composeTopicSubmit => 'Submit to topic';

  @override
  String get composeTopicSubmitted =>
      'Submitted to the topic mailbox. It will appear after review.';

  @override
  String get shopVipSectionTitle => 'Membership · VIP';

  @override
  String get shopVipOwnedSubtitle => 'You are a member — see benefits below';

  @override
  String get shopVipPromoSubtitle => 'Unlock more postal perks and cosmetics';

  @override
  String get shopVipBody =>
      'VIP benefits are configured on the server (e.g. registered-mail perks). Checkout will appear here when payments are connected.';

  @override
  String get shopCatalogEmptyTitle => 'No products yet';

  @override
  String get shopCatalogEmptySubtitle =>
      'Items will appear here once the catalog is configured.';

  @override
  String get shopMockPurchase => 'Mock purchase';

  @override
  String get shopMockPurchaseSuccess =>
      'Purchase complete — entitlement granted';

  @override
  String get shopOwned => 'Owned';

  @override
  String get shopPriceFree => 'Free';

  @override
  String shopPriceAmount(Object amount) {
    return '\$$amount';
  }

  @override
  String get shopProductTypeSkin => 'Letter skins';

  @override
  String get shopProductTypeFont => 'Fonts';

  @override
  String get shopProductTypeTemplate => 'Templates';

  @override
  String get shopProductTypeVipBundle => 'VIP bundles';

  @override
  String get shopProductTypeExport => 'Export';

  @override
  String get shopProductTypeAttachment => 'Attachments';

  @override
  String get commerceProductSkinDefault => 'Default paper';

  @override
  String get commerceProductSkinVintage => 'Vintage paper';

  @override
  String get commerceProductFontDefault => 'Default font';

  @override
  String get commerceProductFontHandwriting => 'Handwriting font';

  @override
  String get commerceProductExportPdf => 'PDF export';

  @override
  String get entitlementsTitle => 'My cosmetics';

  @override
  String get entitlementsEmptyTitle => 'No cosmetics yet';

  @override
  String get entitlementsEmptySubtitle =>
      'Visit the shop for letter skins, fonts, and more.';

  @override
  String entitlementsGrantedAt(Object date) {
    return 'Granted $date';
  }

  @override
  String get profileLetterDrafts => 'Letter drafts';

  @override
  String get profileLetterFavorites => 'Saved letters';

  @override
  String get profileLetterExport => 'Export letters';

  @override
  String get profileMyEntitlements => 'My cosmetics';

  @override
  String get profilePrivacyHideRecommend => 'Hide recommendations';

  @override
  String get profilePrivacyRejectStranger => 'Decline stranger mail';

  @override
  String get letterDraftsTitle => 'Letter drafts';

  @override
  String get letterDraftsEmptyTitle => 'No drafts';

  @override
  String get letterDraftsEmptySubtitle =>
      'Save a draft while writing and send it later.';

  @override
  String get letterDraftsSend => 'Send';

  @override
  String get letterDraftsDelete => 'Delete';

  @override
  String get letterDraftsDeleted => 'Draft deleted';

  @override
  String get letterDraftsNoContent => '(empty draft)';

  @override
  String letterDraftsUpdated(Object time) {
    return 'Updated $time';
  }

  @override
  String get letterFavoritesTitle => 'Saved letters';

  @override
  String get letterFavoritesEmptyTitle => 'No saved letters';

  @override
  String get letterFavoritesEmptySubtitle =>
      'Tap the star on a letter to save it here.';

  @override
  String get letterExportTitle => 'Export letters';

  @override
  String get letterExportFromDate => 'From date';

  @override
  String get letterExportToDate => 'To date';

  @override
  String get letterExportDateOptional => 'Optional';

  @override
  String get letterExportSubmit => 'Generate export';

  @override
  String get letterExportSuccess => 'Download link ready';

  @override
  String get letterExportPending => 'Export submitted';

  @override
  String get letterFavorite => 'Save letter';

  @override
  String get letterUnfavorite => 'Remove save';

  @override
  String get ritualOpenLetter => 'A letter is waiting to be opened';

  @override
  String get ritualDeliverySent => 'Your letter is on its way';

  @override
  String get composeSkinPickerTitle => 'Choose letter skin';

  @override
  String get settingsPreferencesSaved => 'Preferences saved';

  @override
  String get quotaClaimTitle => 'Claim today\'s free quota';

  @override
  String quotaClaimMessage(int count) {
    return 'You can send $count free letters each day. Claim today\'s quota before writing.';
  }

  @override
  String get quotaClaimButton => 'Claim today\'s free quota';

  @override
  String get firstLetterGuideTitle => 'Write your first letter';

  @override
  String get firstLetterGuideSubtitle =>
      'Send a sincere letter through the post office — we\'ll match you with someone kind.';

  @override
  String get firstLetterGuideHintTitle => 'Ideas to start';

  @override
  String get firstLetterGuideHintBody =>
      'Share a recent feeling, a small joy, or the kind of pen pal you\'d like to meet. Short and sincere is enough.';

  @override
  String get firstLetterGuideCta => 'Start my first letter';

  @override
  String get firstLetterGuideSkip => 'Maybe later';

  @override
  String get firstLetterComposeHint =>
      'This is your first post-office letter. You can pick a free template and skin in the next step.';

  @override
  String get inTransitTitle => 'Letters in transit';

  @override
  String get inTransitLoadFailed => 'Couldn\'t load in-transit letters';

  @override
  String get inTransitEmptyTitle => 'Nothing in transit';

  @override
  String get inTransitEmptySubtitle =>
      'Sent and incoming letters will show progress here.';

  @override
  String get inTransitSectionOutbound => 'Sent · not arrived';

  @override
  String get inTransitSectionInbound => 'Incoming · not arrived';

  @override
  String get inTransitSectionUnread => 'Delivered · unread';

  @override
  String get inTransitSectionEmpty => 'No letters in this section';

  @override
  String inTransitEtaHours(int hours) {
    return 'About $hours hours until arrival';
  }

  @override
  String get writeDestinationTitle => 'Who are you writing to?';

  @override
  String get writeDestinationPostOffice => 'To a kindred spirit';

  @override
  String get writeDestinationPostOfficeSub =>
      'Drop it in the post office for a match';

  @override
  String get writeDestinationSelfTime => 'To my future self';

  @override
  String get writeDestinationSelfTimeSub =>
      'A time letter that opens on a chosen date';

  @override
  String get composeAddParagraph => 'Add paragraph';

  @override
  String get composeRemoveParagraph => 'Remove paragraph';

  @override
  String composeParagraphLabel(int n) {
    return 'Paragraph $n';
  }

  @override
  String get composeTemplatePickerTitle => 'Letter templates';

  @override
  String get composeTemplateEmpty => 'No templates available';

  @override
  String get composeTemplateApplied =>
      'Filled into the body — edit as you like';

  @override
  String get composeStepMailSubtitleSkins =>
      'Choose template and paper first, then write.';

  @override
  String get commerceProductSkinLinen => 'Linen paper';

  @override
  String get commerceProductTemplateEmotion => 'Heartfelt note';

  @override
  String get commerceProductTemplateNarrative => 'Story sketch';

  @override
  String get authRegisterSummaryLocation => 'Location';

  @override
  String get authRegisterLocationCaptured => 'Captured (optional)';

  @override
  String get authRegisterSummaryCity => 'City';

  @override
  String get authRegisterLocationPendingCity =>
      'Located — city will be filled automatically';

  @override
  String get profileCity => 'City';

  @override
  String get profileCityHint => 'Detected from location; shown read-only';
}
