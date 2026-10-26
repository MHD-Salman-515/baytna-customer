import 'package:baytna_customer/core/localization/l10n.dart';
import 'package:flutter/widgets.dart';

extension DurationLabels on BuildContext {
  /// "ساعتان", "3 ساعات", "2.5 ساعة" — proper plurals for whole hours.
  String hoursLabel(num hours) => hours == hours.roundToDouble()
      ? l10n.hoursCount(hours.toInt())
      : l10n.hoursDecimal(hours.toString());
}
