import 'package:baytna_customer/core/error/failure.dart';

/// Why the server refused a booking, derived from its (English, diagnostic)
/// messages, which were captured live on staging on 2026-10-26:
///
///   409 "This time overlaps one of her existing bookings (including the travel buffer between jobs)"
///   400 "scheduledFor may not be more than 90 days in the future"
///   400 "scheduledFor falls outside her available hours for that date"
///   400 "scheduledFor must be in the future"
///   400 "This worker does not serve the selected city"
///   400 "address.landmark should not be empty"
///   404 "Worker service not found" / "Worker not found"
sealed class BookingFailure extends FeatureFailure {
  const BookingFailure([super.debugMessage]);

  /// Maps a generic failure from POST /bookings; anything unrecognized is
  /// returned unchanged so the generic copy applies.
  static Failure from(Failure failure) {
    final text = (failure.debugMessage ?? '').toLowerCase();
    return switch (failure) {
      ServerFailure(statusCode: 409) => SlotTaken(failure.debugMessage),
      ValidationFailure() when text.contains('days in the future') => BeyondHorizon(failure.debugMessage),
      ValidationFailure() when text.contains('outside her available hours') => OutsideHerHours(failure.debugMessage),
      ValidationFailure() when text.contains('must be in the future') => InThePast(failure.debugMessage),
      ValidationFailure() when text.contains('does not serve') => CityNotServed(failure.debugMessage),
      ValidationFailure() when text.contains('landmark') => LandmarkMissing(failure.debugMessage),
      NotFoundFailure() => WorkerUnavailable(failure.debugMessage),
      _ => failure,
    };
  }
}

/// Someone else booked her at that time (or too close to it) meanwhile.
final class SlotTaken extends BookingFailure {
  const SlotTaken([super.debugMessage]);
}

final class BeyondHorizon extends BookingFailure {
  const BeyondHorizon([super.debugMessage]);
}

final class OutsideHerHours extends BookingFailure {
  const OutsideHerHours([super.debugMessage]);
}

final class InThePast extends BookingFailure {
  const InThePast([super.debugMessage]);
}

final class CityNotServed extends BookingFailure {
  const CityNotServed([super.debugMessage]);
}

final class LandmarkMissing extends BookingFailure {
  const LandmarkMissing([super.debugMessage]);
}

/// She (or this offering) is no longer bookable.
final class WorkerUnavailable extends BookingFailure {
  const WorkerUnavailable([super.debugMessage]);
}
