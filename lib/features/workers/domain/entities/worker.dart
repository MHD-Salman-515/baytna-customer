import 'package:baytna_customer/core/localization/localized_text.dart';
import 'package:baytna_customer/features/services/domain/entities/service.dart';
import 'package:equatable/equatable.dart';

/// A bookable worker as the CUSTOMER sees her: the backend's public
/// projection, a strict allowlist. There is no phone, no documents, no
/// commission here, and this class must never grow fields for them.
class Worker extends Equatable {
  const Worker({
    required this.id,
    required this.bio,
    required this.rating,
    required this.cityId,
    required this.serviceAreas,
    required this.offerings,
    this.displayName,
    this.photoUrl,
  });

  /// Her workerProfileId.
  final String id;

  /// Null when she never set one (the backend then sends the literal
  /// "Worker"). The UI describes her by service and city instead.
  final String? displayName;

  /// HTTPS only; anything else is dropped at the model.
  final String? photoUrl;
  final LocalizedText bio;

  /// 0 means "no reviews yet", not "rated zero".
  final double rating;
  final String cityId;

  /// City ids she accepts bookings in. A booking's cityId must be one of them.
  final List<String> serviceAreas;
  final List<WorkerOffering> offerings;

  bool get hasRating => rating > 0;

  WorkerOffering? offeringFor(String serviceId) =>
      offerings.where((o) => o.serviceId == serviceId).firstOrNull;

  @override
  List<Object?> get props => [id, displayName, photoUrl, bio, rating, cityId, serviceAreas, offerings];
}

/// One service she offers, with the price the backend chooses to display.
///
/// What [displayPrice] means depends on [pricingType]: the hourly rate
/// (HOURLY), the flat price (FIXED), or a starting price (BY_SIZE). Minimum
/// hours and size tiers are NOT in the projection; the quote endpoint is the
/// source for them.
class WorkerOffering extends Equatable {
  const WorkerOffering({
    required this.serviceId,
    required this.serviceName,
    required this.pricingType,
    required this.displayPrice,
    required this.currency,
    this.workerServiceId,
  });

  final String serviceId;
  final LocalizedText serviceName;
  final PricingType pricingType;
  final num displayPrice;
  final String currency;

  /// Needed to quote and to book. Missing from today's projection (see
  /// DevWorkerServices); null means this offering can't be booked yet.
  final String? workerServiceId;

  bool get isBookable => workerServiceId != null && pricingType != PricingType.unknown;

  @override
  List<Object?> get props => [serviceId, serviceName, pricingType, displayPrice, currency, workerServiceId];
}
