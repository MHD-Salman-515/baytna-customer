import 'package:baytna_customer/features/bookings/domain/entities/booking.dart';
import 'package:baytna_customer/features/pricing/domain/job_size.dart';
import 'package:baytna_customer/features/services/domain/entities/service.dart';
import 'package:equatable/equatable.dart';

/// Everything POST /bookings needs for a SCHEDULED booking — and nothing
/// else. In particular: NO price (the server freezes its own snapshot) and
/// NO workerId (verified live: the server rejects it as
/// "property workerId should not exist"; the worker is implied by
/// workerServiceId).
class NewBooking extends Equatable {
  const NewBooking({
    required this.serviceId,
    required this.workerServiceId,
    required this.cityId,
    required this.scheduledFor,
    required this.size,
    required this.address,
  });

  final String serviceId;
  final String workerServiceId;

  /// Must be one of her serviceAreas.
  final String cityId;
  final DateTime scheduledFor;
  final JobSize size;
  final BookingAddress address;

  Map<String, Object> toJson() => {
    'type': 'SCHEDULED',
    'serviceId': serviceId,
    'workerServiceId': workerServiceId,
    'cityId': cityId,
    'scheduledFor': scheduledFor.toUtc().toIso8601String(),
    'estimatedDurationMinutes': size.durationMinutes,
    if (size.pricingType == PricingType.hourly && size.hours != null) 'estimatedHours': size.hours!,
    if (size.pricingType == PricingType.bySize && size.roomCount != null) 'roomCount': size.roomCount!,
    'address': address.toJson(),
  };

  @override
  List<Object?> get props => [serviceId, workerServiceId, cityId, scheduledFor, size, address];
}
