import 'package:baytna_customer/core/localization/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Formatting for COUNTRY-local DateTimes (TZDateTime from CountryTime):
/// DateFormat reads their wall-clock fields, so these show country time.
extension TimeLabels on BuildContext {
  String get _locale => Localizations.localeOf(this).languageCode;

  String clockTime(DateTime countryLocal) => DateFormat.jm(_locale).format(countryLocal);

  String longDate(DateTime countryLocal) => DateFormat.MMMMEEEEd(_locale).format(countryLocal);

  String dayChip(DateTime countryLocal, int daysFromToday) => switch (daysFromToday) {
    0 => l10n.dayToday,
    1 => l10n.dayTomorrow,
    _ => DateFormat.MMMEd(_locale).format(countryLocal),
  };
}
