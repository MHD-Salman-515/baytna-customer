import 'package:intl/intl.dart';

/// Prices are whole units of the country currency (the backend stores
/// integers, no minor units). Grouped digits plus a local currency symbol:
/// "12,000 ل.س" / "12,000 SYP". Western digits in both languages, like the
/// phone numbers elsewhere in the app.
String formatMoney(num amount, String currencyCode, String languageCode) {
  final digits = NumberFormat.decimalPattern('en').format(amount.round());
  return '$digits ${currencySymbol(currencyCode, languageCode)}';
}

String currencySymbol(String code, String languageCode) {
  if (languageCode != 'ar') return code;
  return switch (code) {
    'SYP' => 'ل.س',
    'IQD' => 'د.ع',
    _ => code,
  };
}
