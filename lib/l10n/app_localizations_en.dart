// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Baby Tracker';

  @override
  String get navHome => 'HOME';

  @override
  String get navDiapers => 'DIAPERS';

  @override
  String get navFeeding => 'FEEDING';

  @override
  String get navWeight => 'WEIGHT';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDone => 'Done';

  @override
  String get commonSave => 'Save';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonDelete => 'Delete';

  @override
  String get deleteRecordConfirmTitle => 'Delete this entry?';

  @override
  String get deleteRecordConfirmBody =>
      'It will be permanently removed. This can’t be undone.';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonDate => 'Date';

  @override
  String get commonTime => 'Time';

  @override
  String get commonTimeStart => 'Start time';

  @override
  String get commonTimeEnd => 'End time';

  @override
  String get commonGenderBoy => 'Boy';

  @override
  String get commonGenderGirl => 'Girl';

  @override
  String get commonSend => 'Send';

  @override
  String get commonNext => 'Next';

  @override
  String get commonExit => 'Exit';

  @override
  String get historyTitle => 'History';

  @override
  String get historyScrollLoadMore =>
      'Scroll to the bottom to load three more days of history.';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get timeSuffixMinute => 'min';

  @override
  String get timeSuffixHour => 'h';

  @override
  String get timeSuffixSecond => 's';

  @override
  String timeHoursOnly(Object h) {
    return '${h}h';
  }

  @override
  String timeHoursMinutes(Object h, Object m) {
    return '${h}h $m min';
  }

  @override
  String timeMinutesOnly(Object m) {
    return '$m min';
  }

  @override
  String durationMinutesSeconds(Object m, Object s) {
    return '${m}m ${s}s';
  }

  @override
  String durationHoursMinutes(Object h, Object m) {
    return '${h}h ${m}m';
  }

  @override
  String durationHoursMinutesSeconds(Object h, Object m, Object s) {
    return '${h}h ${m}m ${s}s';
  }

  @override
  String durationHoursOnly(Object h) {
    return '${h}h';
  }

  @override
  String get feedingIntervalHoursOne => '1 hour';

  @override
  String feedingIntervalHoursN(Object n) {
    return '$n hours';
  }

  @override
  String feedingIntervalHoursMinutes(Object h, Object m) {
    return '${h}h ${m}min';
  }

  @override
  String get profileDefaultBabyName => 'Baby';

  @override
  String get profileWeightLabel => 'WEIGHT';

  @override
  String get profileHeightLabel => 'HEIGHT';

  @override
  String get babyAgeMonthsOneDaysOne => '1 MONTH, 1 DAY';

  @override
  String babyAgeMonthsOneDaysN(Object days) {
    return '1 MONTH, $days DAYS';
  }

  @override
  String babyAgeMonthsNDaysOne(Object months) {
    return '$months MONTHS, 1 DAY';
  }

  @override
  String babyAgeMonthsNDaysN(Object days, Object months) {
    return '$months MONTHS, $days DAYS';
  }

  @override
  String get monthiversaryOne => 'Today turns 1 month old!';

  @override
  String monthiversaryN(Object months) {
    return 'Today turns $months months old!';
  }

  @override
  String get monthiversarySemanticsHint =>
      'Tap for confetti; up to twice until it finishes';

  @override
  String get homeSummaryTitle => 'Today\'s summary';

  @override
  String get homeLastFeedLabel => 'LAST FEED';

  @override
  String homeLastFeedAgo(Object time) {
    return '$time ago';
  }

  @override
  String get homeNextFeedSoon => 'Next feed soon';

  @override
  String homeNextFeedIn(Object time) {
    return 'Next feed in $time';
  }

  @override
  String get homeNoFeedingsYet =>
      'No feeds logged yet. Tap to add the first one.';

  @override
  String get homeWeightNoRecords =>
      'No weight entries. Tap to add the first one.';

  @override
  String homeWeightTrendGramsPerDay(Object sign, Object value) {
    return '$sign$value g/day';
  }

  @override
  String homeWeightTrendOuncesPerDay(Object sign, Object value) {
    return '$sign$value oz/day';
  }

  @override
  String homeWeightLast(Object date) {
    return 'Last: $date';
  }

  @override
  String get homeDiapersNoRecords =>
      'No diaper changes. Tap to add the first one.';

  @override
  String homeDiapersWetDirty(Object dirty, Object wet) {
    return '$wet wet · $dirty dirty';
  }

  @override
  String get homeDiaperChangesOne => '1 change';

  @override
  String homeDiaperChangesN(Object n) {
    return '$n changes';
  }

  @override
  String get homeTipTitle => 'Tip of the day ✨';

  @override
  String get homeTipFallback =>
      'Babies can recognize their caregiver\'s voice before birth. Calm talking helps build that bond.';

  @override
  String get sabiasQueNoBirthDate =>
      'Add your baby\'s birth date in settings to see age-matched tips.';

  @override
  String get homeConfigureProfileFirst =>
      'Set up your baby\'s profile in Settings first';

  @override
  String get homePickPhoto => 'Choose photo';

  @override
  String get homeRemovePhoto => 'Remove profile photo';

  @override
  String get homePhotoRemoved => 'Profile photo removed';

  @override
  String homePhotoRemoveError(Object error) {
    return 'Could not remove photo: $error';
  }

  @override
  String get homePhotoUpdated => 'Photo updated';

  @override
  String homePhotoUploadError(Object error) {
    return 'Could not upload photo: $error';
  }

  @override
  String get feedingTitle => 'Feeding';

  @override
  String get feedingSessionType => 'Feed type';

  @override
  String get feedingBreast => 'Breast';

  @override
  String get feedingLeft => 'Left';

  @override
  String get feedingRight => 'Right';

  @override
  String get feedingBottle => 'Bottle';

  @override
  String get feedingSolidFood => 'Solids';

  @override
  String get solidFoodTitle => 'Solid food';

  @override
  String get solidFoodNameLabel => 'What they ate';

  @override
  String get solidFoodNameHint => 'e.g. apple purée';

  @override
  String get solidFoodQuantityLabel => 'Amount';

  @override
  String get solidFoodUnitGrams => 'g (grams)';

  @override
  String get solidFoodUnitUnits => 'units';

  @override
  String get solidFoodUnitGramShort => 'g';

  @override
  String get solidFoodUnitUnitsShort => 'u';

  @override
  String get solidFoodQuantityHintGrams => 'e.g. 40 or 0.47 (comma or dot)';

  @override
  String get solidFoodQuantityHintUnits => 'Whole number only, e.g. 2';

  @override
  String get solidFoodValidatorNameEmpty => 'Enter what they ate';

  @override
  String get solidFoodValidatorQuantityEmpty => 'Enter the amount';

  @override
  String solidFoodValidatorQuantityInvalid(Object max) {
    return 'Whole number from 1 to $max';
  }

  @override
  String get solidFoodValidatorQuantityParse =>
      'Invalid format: use digits and at most one decimal comma or dot (e.g. 0.47).';

  @override
  String get solidFoodValidatorUnitsNoDecimals =>
      'For units, use a whole number only (no decimals).';

  @override
  String get solidFoodValidatorGramsPositive =>
      'Weight in grams must be greater than zero.';

  @override
  String solidFoodValidatorGramsRange(Object max) {
    return 'Weight cannot exceed $max g.';
  }

  @override
  String get feedingChooseSideTitle => 'Which side?';

  @override
  String get feedingChooseSideSubtitle => 'Pick a side to start the timer.';

  @override
  String get feedingEditSolid => 'Edit solids';

  @override
  String get feedingStop => 'Stop';

  @override
  String feedingActiveTimer(Object side) {
    return 'Timer running: $side';
  }

  @override
  String get feedingSideLeft => 'Left';

  @override
  String get feedingSideRight => 'Right';

  @override
  String get feedingHistoryEmpty =>
      'No entries yet. Use “Breast”, “Bottle”, or “Solids” above to add the first one.';

  @override
  String get feedingSessionCountOne => '1 feed';

  @override
  String feedingSessionCountN(Object n) {
    return '$n feeds';
  }

  @override
  String get feedingEditBottle => 'Edit bottle';

  @override
  String get feedingEditSession => 'Edit feed';

  @override
  String get feedingAmountMl => 'Amount (ml)';

  @override
  String get hintExampleMl => 'e.g. 120';

  @override
  String get feedingStreamError =>
      'Could not load feeds. Retry or check your connection.';

  @override
  String lastFeedDetailLeftMinutes(Object minutes) {
    return 'Left • $minutes min';
  }

  @override
  String get lastFeedDetailLeft => 'Left';

  @override
  String lastFeedDetailRightMinutes(Object minutes) {
    return 'Right • $minutes min';
  }

  @override
  String get lastFeedDetailRight => 'Right';

  @override
  String lastFeedDetailBottleVolume(Object volume) {
    return 'Bottle • $volume';
  }

  @override
  String get lastFeedDetailSolid => 'Solids';

  @override
  String get diapersTitle => 'Diaper log';

  @override
  String get diapersChangeType => 'Change type';

  @override
  String get diaperWet => 'Wet';

  @override
  String get diaperDirty => 'Dirty';

  @override
  String get diaperBoth => 'Both';

  @override
  String get diapersRegisterButton => 'Log diaper change';

  @override
  String get diapersHistoryEmpty =>
      'No entries yet. Use “Log diaper change” above to add the first one.';

  @override
  String get diaperChangeCountOne => '1 change';

  @override
  String diaperChangeCountN(Object n) {
    return '$n changes';
  }

  @override
  String get diapersStreamError =>
      'Could not load diapers. Retry or check your connection.';

  @override
  String get diapersEditRecord => 'Edit entry';

  @override
  String get diapersTypeLabel => 'Type';

  @override
  String get weightTitle => 'Weight log';

  @override
  String get weightFieldLabelMetric => 'Weight (kg)';

  @override
  String get weightFieldLabelImperial => 'Weight (lb)';

  @override
  String get hintExampleWeight => 'e.g. 4.5';

  @override
  String get weightRegister => 'Log';

  @override
  String get weightValidatorEmpty => 'Enter weight';

  @override
  String get weightValidatorInvalid => 'Invalid weight';

  @override
  String get weightStreamError =>
      'Could not load weights. Check connection or retry.';

  @override
  String get weightEvolution => 'Trend';

  @override
  String get weightChartCaption => 'Reference line weight-for-age (WHO).';

  @override
  String get weightChartSource =>
      'Source: World Health Organization (WHO) — Child Growth Standards. who.int/tools/child-growth-standards';

  @override
  String get weightChartLoadError => 'Could not load the weight chart.';

  @override
  String get weightHistoryLoadError => 'Could not load weight history.';

  @override
  String get weightHistoryEmpty =>
      'No entries yet. Enter weight and tap “Log” above to add the first one.';

  @override
  String get weightCurrentCard => 'Current weight';

  @override
  String get weightTrendCard => 'Daily trend';

  @override
  String weightTrendGramsCompact(Object sign, Object value) {
    return '$sign${value}g';
  }

  @override
  String weightTrendOuncesCompact(Object sign, Object value) {
    return '$sign$value oz';
  }

  @override
  String get weightNoData => 'No data';

  @override
  String get weightDash => '-';

  @override
  String get weightChartEmpty => 'No data yet';

  @override
  String get weightChartNoDataInRange => 'No weigh-ins in this period';

  @override
  String get weightChartRangeAll => 'All';

  @override
  String get weightChartRange7d => '7 days';

  @override
  String get weightChartRange30d => '30 days';

  @override
  String get weightChartRange90d => '3 months';

  @override
  String get weightChartRange365d => '1 year';

  @override
  String weightTooltipPercentile(String label, String value) {
    return '$label (WHO): $value';
  }

  @override
  String weightTooltipWeighIn(Object value) {
    return 'Weigh-in: $value';
  }

  @override
  String get weightChartPercentileSelector => 'Percentile';

  @override
  String get weightEditTitle => 'Edit weight';

  @override
  String get bottleTitle => 'Bottle';

  @override
  String get bottleValidatorEmpty => 'Enter amount';

  @override
  String get bottleValidatorInvalid => 'Invalid amount';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsBabyProfile => 'Baby profile';

  @override
  String get settingsShareFamily => 'Share family';

  @override
  String get settingsSuggestedFeedings => 'Suggested feeds';

  @override
  String get settingsName => 'Name';

  @override
  String get settingsBirthDate => 'Date of birth';

  @override
  String get settingsHeight => 'Height';

  @override
  String get settingsNoProfile => 'No profile configured';

  @override
  String get settingsEditProfile => 'Edit profile';

  @override
  String get settingsShareQrIntro =>
      'Invite family members by scanning the QR code.';

  @override
  String get settingsFeedingConfigureFirst =>
      'Set up your baby\'s profile first.';

  @override
  String get settingsFeedingIntro => 'Set how often your baby usually feeds';

  @override
  String get settingsFeedingInterval => 'Time between feeds';

  @override
  String get settingsNotifyTitle => 'Enable notifications';

  @override
  String get settingsNotifySubtitle =>
      'Notifications at the suggested time for the next feed.';

  @override
  String get settingsNotifyPermission =>
      'Turn on notifications in system settings to get reminders.';

  @override
  String get settingsSignOutSection => 'Sign out';

  @override
  String get settingsSignOutButton => 'Sign out';

  @override
  String get settingsSignOutRowSubtitle => 'Sign out on this device';

  @override
  String get settingsDeleteSection => 'Delete account';

  @override
  String get settingsDeleteIntro =>
      'Deletes your account and sign-in data. If you\'re the only family member, all baby data will be removed too.';

  @override
  String get settingsDeleteAccount => 'Delete my account';

  @override
  String get settingsDeleteAccountRowSubtitle =>
      'Delete your account and its data';

  @override
  String get settingsDeleting => 'Deleting...';

  @override
  String get settingsFamilyFirebaseOnly =>
      'Family sharing is only available with Firebase.';

  @override
  String get settingsShowQr => 'Show invite QR';

  @override
  String get settingsHideQr => 'Hide QR';

  @override
  String get settingsQrCaption => 'Scan to join the family';

  @override
  String get settingsGroupBaby => 'Baby';

  @override
  String get settingsGroupPreferences => 'Preferences';

  @override
  String get settingsGroupFamily => 'Family';

  @override
  String get settingsGroupAccount => 'Account';

  @override
  String get settingsRowProfileTitle => 'Profile details';

  @override
  String get settingsRowProfileSubtitle => 'Name, date and height';

  @override
  String get settingsRowProfileEmpty => 'Not set';

  @override
  String get settingsRowFeedingInterval => 'Time between feeds';

  @override
  String get settingsRowFeedingNotify => 'Next-feed reminder';

  @override
  String get settingsRowUnitWeight => 'Weight unit';

  @override
  String get settingsRowUnitLiquid => 'Liquid unit';

  @override
  String get settingsRowFamilyShare => 'Share with family';

  @override
  String get settingsRowFamilyShareSubtitle => 'Show invite QR code';

  @override
  String get settingsValueOn => 'On';

  @override
  String get settingsValueOff => 'Off';

  @override
  String get settingsValueNotSet => '—';

  @override
  String get settingsBabyAgeMonthsOne => '1 month';

  @override
  String settingsBabyAgeMonthsN(int months) {
    return '$months months';
  }

  @override
  String get settingsBabyAgeDaysOne => '1 day';

  @override
  String settingsBabyAgeDaysN(int days) {
    return '$days days';
  }

  @override
  String settingsBabyBornOn(String date) {
    return 'Born on $date';
  }

  @override
  String settingsBabyBornOnFemale(String date) {
    return 'Born on $date';
  }

  @override
  String get settingsSheetUnitWeightTitle => 'Weight unit';

  @override
  String get settingsSheetUnitLiquidTitle => 'Liquid unit';

  @override
  String get settingsSheetFeedingIntervalTitle => 'Time between feeds';

  @override
  String get settingsSheetShareTitle => 'Share with family';

  @override
  String get editBabyProfileTitle => 'Edit baby profile';

  @override
  String get labelName => 'Name';

  @override
  String get labelGender => 'Gender';

  @override
  String get heightFieldLabel => 'Height (cm)';

  @override
  String get heightFieldHint => 'Optional, e.g. 58';

  @override
  String get heightInvalid => 'Invalid height';

  @override
  String get heightRangeError => 'Height must be between 25 and 120 cm';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountBody =>
      'This will permanently delete your account and sign-in data. If you\'re the only family member, all baby data will be removed too.\n\nThis can\'t be undone. Are you sure?';

  @override
  String get deleteAccountConfirm => 'Delete account';

  @override
  String deleteAccountError(Object error) {
    return 'Could not delete account: $error';
  }

  @override
  String get signOutTitle => 'Sign out';

  @override
  String get signOutBody => 'Are you sure you want to sign out?';

  @override
  String get signOutConfirm => 'Sign out';

  @override
  String signOutError(Object error) {
    return 'Could not sign out: $error';
  }

  @override
  String get loginForgotPasswordTitle => 'Reset password';

  @override
  String get loginForgotPasswordBody =>
      'We\'ll email you a link to choose a new password.';

  @override
  String get loginEmailHint => 'Your email';

  @override
  String get loginResetInvalidEmail => 'Enter a valid email';

  @override
  String get loginResetCheckEmail =>
      'Check your email (and spam) to reset your password';

  @override
  String get loginResetSendFail => 'Could not send the email. Try again later.';

  @override
  String get loginHeaderTitle => 'My Baby Diary';

  @override
  String get loginPasswordHint => 'Your password';

  @override
  String get loginForgotLink => 'Forgot your password?';

  @override
  String get loginValidatorEmailEmpty => 'Enter your email';

  @override
  String get loginValidatorEmailInvalid => 'Invalid email';

  @override
  String get loginValidatorPasswordEmpty => 'Enter your password';

  @override
  String get loginSignIn => 'Sign in';

  @override
  String get loginGuestQr => 'Join with QR code (no account)';

  @override
  String get loginOrWith => 'OR SIGN IN WITH';

  @override
  String get loginNoAccount => 'Don\'t have an account? ';

  @override
  String get loginRegisterLink => 'Sign up';

  @override
  String get loginErrorGeneric => 'Sign-in error';

  @override
  String get loginErrorGoogle => 'Google sign-in error';

  @override
  String get loginErrorApple => 'Apple sign-in error';

  @override
  String get loginGuestNeedsFirebase =>
      'Firebase is required to join with a QR code';

  @override
  String get loginGuestNotAllowed =>
      'Anonymous sign-in is disabled. In Firebase Console → Authentication → Sign-in method, enable Anonymous.';

  @override
  String get loginGuestFailed => 'Could not sign in as guest';

  @override
  String get authErrorUserNotFound => 'No account exists with this email';

  @override
  String get authErrorWrongPassword => 'Incorrect password';

  @override
  String get authErrorInvalidEmail => 'Invalid email';

  @override
  String get authErrorUserDisabled => 'This account has been disabled';

  @override
  String get authErrorInvalidCredential => 'Invalid credentials';

  @override
  String get authErrorOperationNotAllowed =>
      'This sign-in method is not enabled';

  @override
  String get authErrorGeneric => 'Sign-in error';

  @override
  String get resetErrorInvalidEmail => 'Invalid email';

  @override
  String get resetErrorUserNotFound =>
      'No account with this email. Check the address or sign up.';

  @override
  String get resetErrorUserDisabled => 'This account is disabled';

  @override
  String get resetErrorOpNotAllowed =>
      'Email recovery isn\'t enabled in Firebase (Authentication → Sign-in method → Email).';

  @override
  String get resetErrorGeneric => 'Could not send the email. Try again later.';

  @override
  String get registerTitle => 'Sign up';

  @override
  String get registerHeadline => 'Create your account';

  @override
  String get registerSubtitle => 'Enter your details to sign up';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerPasswordLabel => 'Password';

  @override
  String get registerConfirmLabel => 'Confirm password';

  @override
  String get registerPasswordHint => 'At least 6 characters';

  @override
  String get registerEmailHint => 'you@email.com';

  @override
  String get registerValidatorEmailEmpty => 'Enter your email';

  @override
  String get registerValidatorPasswordEmpty => 'Enter a password';

  @override
  String get registerValidatorPasswordShort => 'At least 6 characters';

  @override
  String get registerValidatorConfirmEmpty => 'Confirm your password';

  @override
  String get registerValidatorMismatch => 'Passwords don\'t match';

  @override
  String get registerButton => 'Sign up';

  @override
  String get registerHaveAccount => 'Already have an account? ';

  @override
  String get registerSignInLink => 'Sign in';

  @override
  String get registerErrorGeneric =>
      'Sign-up failed. Check your connection and that email sign-up is enabled in Firebase.';

  @override
  String get registerErrorEmailInUse =>
      'An account already exists with this email. Use “Sign in” instead.';

  @override
  String get registerErrorWeakPassword =>
      'Password must be at least 6 characters';

  @override
  String get registerErrorOpNotAllowed =>
      'Email sign-up isn\'t enabled. Turn it on in Firebase Console → Authentication → Sign-in method';

  @override
  String get registerErrorNetwork => 'Network error. Check your internet.';

  @override
  String get registerErrorTooMany => 'Too many attempts. Wait a few minutes.';

  @override
  String get registerErrorInvalidCredential => 'Invalid credentials';

  @override
  String registerErrorUnknown(Object code) {
    return 'Error: $code. Check Firebase Console.';
  }

  @override
  String get onboardingWelcome => 'Welcome to My Baby Diary';

  @override
  String get onboardingHowStart => 'How would you like to start?';

  @override
  String get onboardingCreateBabyTitle => 'Create baby';

  @override
  String get onboardingCreateBabySubtitle =>
      'Set up a new profile from scratch';

  @override
  String get onboardingScanTitle => 'Scan baby';

  @override
  String get onboardingScanSubtitle =>
      'Join an existing baby by scanning their QR code';

  @override
  String get onboardingScanDisabled => 'Requires Firebase for sharing';

  @override
  String get onboardingExitLogin => 'Exit and return to sign-in';

  @override
  String get onboardingConfigureTitle => 'Set up baby';

  @override
  String get onboardingCreateProfileTitle => 'Create baby profile';

  @override
  String get onboardingCreateProfileSubtitle => 'Enter your baby\'s details';

  @override
  String get onboardingBabyName => 'Baby\'s name';

  @override
  String get onboardingBabyNameHint => 'e.g. Maria, Lucas...';

  @override
  String get onboardingNameRequired => 'Name is required';

  @override
  String get onboardingGender => 'Gender';

  @override
  String get onboardingBirthDate => 'Date of birth';

  @override
  String get onboardingBirthNote => 'Used for WHO percentiles (0–12 months)';

  @override
  String get onboardingHeightTitle => 'Length / height';

  @override
  String get onboardingHeightSubtitle =>
      'Optional. Current height in centimeters (shown on the profile).';

  @override
  String get onboardingHeightHint => 'Leave blank if unknown';

  @override
  String get onboardingHeightInvalid => 'Enter a valid number (e.g. 52.5)';

  @override
  String get onboardingHeightRange => 'Height is usually between 25 and 130 cm';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get onboardingEnterName => 'Enter the baby\'s name';

  @override
  String get onboardingHeightReview =>
      'Check height: a number between 25 and 130 cm, or leave the field empty';

  @override
  String get onboardingSaveDenied =>
      'No permission in Firebase (rules or session). Check Firestore.';

  @override
  String onboardingSaveFailed(Object code) {
    return 'Could not save ($code). Check connection and Firebase.';
  }

  @override
  String onboardingSaveError(Object error) {
    return 'Could not save: $error';
  }

  @override
  String get onboardingExitTitle => 'Leave?';

  @override
  String get onboardingExitBody =>
      'You will sign out and return to the sign-in screen.';

  @override
  String onboardingSignOutError(Object error) {
    return 'Could not sign out: $error';
  }

  @override
  String get familyQrTitle => 'Scan QR code';

  @override
  String get familyQrHint => 'Point the camera at the baby\'s QR code';

  @override
  String get familyQrDetailLabel => 'Detail:';

  @override
  String get familyQrJoinFailPermission =>
      'Permission denied in Firebase (Firestore rules or session).';

  @override
  String get familyQrJoinFailUnavailable =>
      'Firebase is unavailable. Check your internet connection.';

  @override
  String get familyQrJoinFailNotFound => 'Resource not found in Firebase.';

  @override
  String familyQrJoinFailFirebase(Object code) {
    return 'Firebase error ($code).';
  }

  @override
  String get familyQrJoinFailFamily =>
      'Family not found. Check that the QR is correct.';

  @override
  String get familyQrJoinFailState => 'Could not process the QR code.';

  @override
  String get familyQrJoinFailUnsupported =>
      'QR join isn\'t available (Firebase is required on this device).';

  @override
  String get familyQrJoinFailGeneric => 'Could not join the family.';

  @override
  String get familyQrDecodeFail => 'Failed to read or decode the code.';

  @override
  String get familyQrInternalCode => 'Internal code:';

  @override
  String get notificationChannelName => 'Next feeds';

  @override
  String get notificationChannelDescription =>
      'Reminder when the next feed is due';

  @override
  String get notificationNextFeedTitle => 'Next feed';

  @override
  String notificationNextFeedBody(Object name) {
    return 'It may be time for another feed for $name.';
  }

  @override
  String formatWeightMetricKg(Object kg) {
    return '$kg kg';
  }

  @override
  String formatWeightLbOz(Object lb, Object oz) {
    return '$lb lb $oz oz';
  }

  @override
  String formatVolumeMlOnly(Object ml) {
    return '$ml ml';
  }

  @override
  String formatVolumeFlOzOnly(Object flOz) {
    return '$flOz fl oz';
  }

  @override
  String get unitMlShort => 'ml';

  @override
  String get hintExampleWeightLb => 'e.g. 9.5';

  @override
  String get hintExampleFlOz => 'e.g. 4';

  @override
  String get liquidFieldLabelFlOz => 'Amount (US fl oz)';

  @override
  String get settingsUnitsTitle => 'Units';

  @override
  String get settingsUnitsIntro =>
      'Choose how you enter and view weight and bottle amounts. Data is always stored in kg and ml.';

  @override
  String get settingsUnitsWeight => 'Weight';

  @override
  String get settingsUnitsLiquid => 'Liquids';

  @override
  String get unitSegmentKg => 'kg';

  @override
  String get unitSegmentLbOz => 'lb · oz';

  @override
  String get unitSegmentMl => 'mL';

  @override
  String get unitSegmentFlOz => 'fl oz';
}
