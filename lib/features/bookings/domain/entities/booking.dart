import 'package:baytna_customer/core/geo/geo_point.dart';
import 'package:baytna_customer/features/services/domain/entities/service.dart';
import 'package:equatable/equatable.dart';

enum BookingStatus {
  searching,
  pendingWorker,
  accepted,
  onTheWay,
  arrived,
  inProgress,
  completed,
  rejected,
  cancelled,
  expired,
  noWorkerFound,
  noShow,
  unknown;

  static BookingStatus parse(Object? raw) => switch (raw) {
    'SEARCHING' => searching,
    'PENDING_WORKER' => pendingWorker,
    'ACCEPTED' => accepted,
    'ON_THE_WAY' => onTheWay,
    'ARRIVED' => arrived,
    'IN_PROGRESS' => inProgress,
    'COMPLETED' => completed,
    'REJECTED' => rejected,
    'CANCELLED' => cancelled,
    'EXPIRED' => expired,
    'NO_WORKER_FOUND' => noWorkerFound,
    'NO_SHOW' => noShow,
    _ => unknown,
  };

  String get wire => switch (this) {
    searching => 'SEARCHING',
    pendingWorker => 'PENDING_WORKER',
    accepted => 'ACCEPTED',
    onTheWay => 'ON_THE_WAY',
    arrived => 'ARRIVED',
    inProgress => 'IN_PROGRESS',
    completed => 'COMPLETED',
    rejected => 'REJECTED',
    cancelled => 'CANCELLED',
    expired => 'EXPIRED',
    noWorkerFound => 'NO_WORKER_FOUND',
    noShow => 'NO_SHOW',
    unknown => 'UNKNOWN',
  };

  /// From the backend's own transition error (verified live): "requires
  /// current status to be one of: SEARCHING, PENDING_WORKER, ACCEPTED,
  /// ON_THE_WAY, ARRIVED".
  bool get customerCanCancel => const {searching, pendingWorker, accepted, onTheWay, arrived}.contains(this);

  bool get isFinished => const {completed, rejected, cancelled, expired, noWorkerFound, noShow}.contains(this);
}

/// The address as booked: a pin AND words. In our markets the words
/// (especially the landmark) are how she actually finds the door.
class BookingAddress extends Equatable {
  const BookingAddress({
    required this.point,
    required this.text,
    required this.landmark,
    this.floor,
    this.notes,
  });

  final GeoPoint point;
  final String text;
  final String landmark;
  final String? floor;
  final String? notes;

  Map<String, Object> toJson() => {
    'point': point.toGeoJson(),
    'text': text,
    'landmark': landmark,
    if (floor case final f? when f.isNotEmpty) 'floor': f,
    if (notes case final n? when n.isNotEmpty) 'notes': n,
  };

  @override
  List<Object?> get props => [point, text, landmark, floor, notes];
}

/// The server's frozen price snapshot (`pricing`). The client never sends
/// a price; this is what the server decided at creation.
class BookingPricing extends Equatable {
  const BookingPricing({
    required this.pricingType,
    required this.basePrice,
    required this.currency,
    this.hours,
    this.roomCount,
  });

  final PricingType pricingType;
  final num basePrice;
  final String currency;
  final num? hours;
  final int? roomCount;

  @override
  List<Object?> get props => [pricingType, basePrice, currency, hours, roomCount];
}

class BookingCancellation extends Equatable {
  const BookingCancellation({required this.byRole, required this.feeAmount, this.reason});

  final String byRole;
  final String? reason;
  final num feeAmount;

  @override
  List<Object?> get props => [byRole, reason, feeAmount];
}

class Booking extends Equatable {
  const Booking({
    required this.id,
    required this.bookingNumber,
    required this.status,
    required this.workerProfileId,
    required this.serviceId,
    required this.countryId,
    required this.cityId,
    required this.scheduledFor,
    required this.estimatedDurationMinutes,
    required this.address,
    this.workerServiceId,
    this.pricing,
    this.responseDeadline,
    this.acceptedAt,
    this.cancelledAt,
    this.cancellation,
    this.workerPhone,
  });

  final String id;

  /// Human-friendly, e.g. "BK-4S2DC6". What she quotes to support.
  final String bookingNumber;
  final BookingStatus status;
  final String workerProfileId;
  final String serviceId;
  final String? workerServiceId;
  final String countryId;
  final String cityId;
  final DateTime scheduledFor;
  final int estimatedDurationMinutes;
  final BookingAddress address;
  final BookingPricing? pricing;

  /// When a PENDING_WORKER booking expires if she doesn't answer.
  final DateTime? responseDeadline;
  final DateTime? acceptedAt;
  final DateTime? cancelledAt;
  final BookingCancellation? cancellation;

  /// Null until she ACCEPTS: the backend's status-dependent projection hides
  /// it. Never assume it exists; never guess it.
  final String? workerPhone;

  @override
  List<Object?> get props => [
    id,
    bookingNumber,
    status,
    workerProfileId,
    serviceId,
    workerServiceId,
    countryId,
    cityId,
    scheduledFor,
    estimatedDurationMinutes,
    address,
    pricing,
    responseDeadline,
    acceptedAt,
    cancelledAt,
    cancellation,
    workerPhone,
  ];
}
