import 'package:baytna_customer/core/format/money.dart';
import 'package:baytna_customer/core/localization/l10n.dart';
import 'package:baytna_customer/features/services/domain/entities/service.dart';
import 'package:baytna_customer/features/workers/domain/entities/worker.dart';
import 'package:flutter/widgets.dart';

extension WorkerLabels on BuildContext {
  /// Her name, or a neutral description when she never set one, rather than
  /// the backend's literal "Worker".
  String workerName(Worker worker) => worker.displayName ?? l10n.workerUnnamed;

  String money(num amount, String currency) =>
      formatMoney(amount, currency, Localizations.localeOf(this).languageCode);

  /// What `displayPrice` means for each pricing model.
  String offeringPrice(WorkerOffering o) {
    final price = money(o.displayPrice, o.currency);
    return switch (o.pricingType) {
      PricingType.hourly => l10n.priceHourly(price),
      PricingType.fixed => l10n.priceFixed(price),
      PricingType.bySize => l10n.priceBySize(price),
      PricingType.unknown => price,
    };
  }
}
