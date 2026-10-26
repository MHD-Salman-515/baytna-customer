import 'package:baytna_customer/features/services/domain/entities/service.dart';
import 'package:equatable/equatable.dart';

/// GET /pricing/quote — the customer-facing preview. It deliberately has no
/// commission and no worker earnings; nothing here may be derived from them.
///
/// Verified on staging: `{ price, currency, pricingType, hours }` for HOURLY.
/// [hours] is the EFFECTIVE number of hours: the server raises a request
/// below her minimum to the minimum (asking for 1 h with minHours 2 returns
/// hours: 2 and the 2-hour price), and an omitted `estimatedHours` defaults
/// to the minimum — which is how the app learns minHours at all.
class Quote extends Equatable {
  const Quote({
    required this.price,
    required this.currency,
    required this.pricingType,
    this.hours,
    this.roomCount,
  });

  final num price;
  final String currency;
  final PricingType pricingType;
  final num? hours;
  final int? roomCount;

  @override
  List<Object?> get props => [price, currency, pricingType, hours, roomCount];
}
