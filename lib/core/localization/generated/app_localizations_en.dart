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

  @override
  String get browseTitle => 'Choose a worker';

  @override
  String get browseCity => 'City';

  @override
  String get browseSortRating => 'Top rated';

  @override
  String get browseSortPriceAsc => 'Lowest price';

  @override
  String get browseSortPriceDesc => 'Highest price';

  @override
  String browseEmpty(String city) {
    return 'No workers are available for this service in $city right now.';
  }

  @override
  String get browseEmptyHint => 'Try another city, or check back later.';

  @override
  String get browseNoCities => 'No cities are available in your country yet.';

  @override
  String get workerUnnamed => 'Home-services worker';

  @override
  String get workerNew => 'New on Baytna';

  @override
  String priceHourly(String price) {
    return '$price / hour';
  }

  @override
  String priceFixed(String price) {
    return '$price · fixed price';
  }

  @override
  String priceBySize(String price) {
    return 'From $price';
  }

  @override
  String get workerProfileTitle => 'Profile';

  @override
  String workerServesCities(String cities) {
    return 'Works in: $cities';
  }

  @override
  String get workerAbout => 'About her';

  @override
  String get workerServices => 'Her services and prices';

  @override
  String get offeringNotBookable =>
      'This service can\'t be booked in the app yet.';

  @override
  String pricingExplainHourly(String rate) {
    return 'Charged by the hour: $rate per hour.';
  }

  @override
  String pricingExplainBySize(String price) {
    return 'Priced by the number of rooms, from $price.';
  }

  @override
  String pricingExplainFixed(String price) {
    return 'One fixed price for the whole job: $price.';
  }

  @override
  String get pricingExplainUnknown =>
      'You\'ll see the price before you confirm.';

  @override
  String hoursCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String hoursDecimal(String hours) {
    return '$hours hours';
  }

  @override
  String roomsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rooms',
      one: '1 room',
    );
    return '$_temp0';
  }

  @override
  String get quoteSectionTitle => 'Work out the price';

  @override
  String get quoteHours => 'Hours';

  @override
  String get quoteRooms => 'Rooms';

  @override
  String get quoteExpectedDuration => 'Expected duration';

  @override
  String quoteMinimumHours(String duration) {
    return 'The shortest booking with her is $duration. You pay for at least $duration, even if the job finishes sooner.';
  }

  @override
  String get quotePriceLabel => 'Price';

  @override
  String quoteForHours(String duration) {
    return 'For $duration';
  }

  @override
  String quoteForRooms(String rooms) {
    return 'For $rooms';
  }

  @override
  String get quoteFrozenNote =>
      'This price comes from Baytna and is locked in when you confirm.';
}
