// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Baytna';

  @override
  String get appTagline => 'Trusted home services at your fingertips';

  @override
  String get switchLanguage => 'العربية';

  @override
  String get retry => 'Try again';

  @override
  String get continueAction => 'Continue';

  @override
  String get serverWakingUp =>
      'The server is waking up — this can take a minute…';

  @override
  String get countrySelectTitle => 'Choose your country';

  @override
  String get countrySelectSubtitle =>
      'We show services and prices for your country';

  @override
  String get countriesEmpty => 'No countries are available right now';

  @override
  String get phoneTitle => 'Phone number';

  @override
  String get phoneSubtitle =>
      'Enter your mobile number and we\'ll text you a verification code';

  @override
  String get phoneFieldLabel => 'Mobile number';

  @override
  String get phoneInvalid => 'Enter a valid phone number';

  @override
  String get phoneRejected =>
      'This number isn\'t valid for the selected country';

  @override
  String get sendCode => 'Send code';

  @override
  String get otpTitle => 'Verification code';

  @override
  String otpSubtitle(String phone) {
    return 'Enter the 6-digit code sent to $phone';
  }

  @override
  String get otpVerify => 'Verify';

  @override
  String otpResendIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds seconds',
      one: '1 second',
    );
    return 'You can resend in $_temp0';
  }

  @override
  String get otpResend => 'Resend code';

  @override
  String get otpResent => 'A new code has been sent';

  @override
  String get otpInvalid => 'The code is incorrect or has expired';

  @override
  String get otpTooManyAttempts =>
      'Too many incorrect attempts. Request a new code to continue.';

  @override
  String get changeNumber => 'Change number';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeWelcome => 'Welcome to Baytna';

  @override
  String get homeSignedInAs => 'Signed in as';

  @override
  String get homeChooseService => 'Choose the service you need';

  @override
  String get homeServicesEmpty => 'No services are available right now.';

  @override
  String get logout => 'Log out';

  @override
  String get sessionExpired => 'Your session has ended. Please log in again.';

  @override
  String get errorNetwork =>
      'Couldn\'t connect. Check your internet connection.';

  @override
  String get errorTimeout =>
      'The server took too long to respond. Please try again.';

  @override
  String get errorServer =>
      'Something went wrong on our side. Please try later.';

  @override
  String get errorRateLimited =>
      'Too many requests. Please wait a moment and try again.';

  @override
  String get errorValidation => 'Some of the details you entered are invalid.';

  @override
  String get errorUnauthorized => 'You don\'t have permission to do that.';

  @override
  String get errorNotFound => 'We couldn\'t find what you were looking for.';

  @override
  String get errorUnknown => 'Something unexpected happened.';

  @override
  String get devFillOtp => 'Autofill code (dev mode)';

  @override
  String devOtpUnavailable(String reason) {
    return 'Couldn\'t fetch the code: $reason';
  }
}
