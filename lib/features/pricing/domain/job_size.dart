import 'package:baytna_customer/features/services/domain/entities/service.dart';
import 'package:equatable/equatable.dart';

/// What the customer chose to book, which the booking flow carries forward:
/// billed hours (HOURLY), rooms (BY_SIZE) and how long the job takes, which
/// the server needs for scheduling whatever the pricing model.
class JobSize extends Equatable {
  const JobSize({required this.pricingType, required this.durationMinutes, this.hours, this.roomCount});

  final PricingType pricingType;
  final num? hours;
  final int? roomCount;
  final int durationMinutes;

  @override
  List<Object?> get props => [pricingType, hours, roomCount, durationMinutes];
}

/// Durations offered for scheduling, in half hours.
abstract final class DurationSteps {
  static const step = 0.5;
  static const maxHours = 10.0;

  /// Default job length when the price doesn't depend on time.
  static const defaultHours = 2.0;

  static num clamp(num hours, {num min = step}) => hours.clamp(min, maxHours);

  static int minutes(num hours) => (hours * 60).round();
}
