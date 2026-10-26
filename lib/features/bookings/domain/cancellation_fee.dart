import 'package:baytna_customer/features/bookings/domain/entities/booking.dart';
import 'package:baytna_customer/features/countries/domain/entities/country.dart';

/// What cancelling NOW would cost, from the country's own policy — shown
/// BEFORE she confirms. The rule, verified on staging (2026-10-26):
///
///   * at least `freeCancellationHours` before `scheduledFor` → free;
///   * later → `basePrice × cancellationFeeBasisPoints / 10000`
///     (12,000 SYP × 2000 bp → 2,400, exactly what the server charged),
///     and this applies even while the booking is still PENDING_WORKER.
///
/// It's a preview: the server computes the real fee at the moment of the
/// cancel and returns it as `cancellation.feeAmount`, which is what the
/// booking shows afterwards.
abstract final class CancellationFee {
  static num preview(Booking booking, BookingPolicy policy, DateTime now) {
    final pricing = booking.pricing;
    if (pricing == null) return 0;
    if (!isLate(booking, policy, now)) return 0;
    return (pricing.basePrice * policy.cancellationFeeBasisPoints / 10000).round();
  }

  static bool isLate(Booking booking, BookingPolicy policy, DateTime now) =>
      booking.scheduledFor.difference(now) < Duration(hours: policy.freeCancellationHours);

  /// When cancelling stops being free.
  static DateTime freeUntil(Booking booking, BookingPolicy policy) =>
      booking.scheduledFor.subtract(Duration(hours: policy.freeCancellationHours));
}
