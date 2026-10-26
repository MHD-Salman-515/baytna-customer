import 'package:baytna_customer/features/bookings/data/booking_model.dart';
import 'package:baytna_customer/features/bookings/domain/cancellation_fee.dart';
import 'package:baytna_customer/features/countries/domain/entities/country.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/staging_fixtures.dart';

void main() {
  // basePrice 12,000 SYP, scheduled 2026-11-05T07:00Z; Syria: 24 h free, 2000 bp.
  final booking = BookingModel.fromJson(StagingFixtures.booking);
  const syria = BookingPolicy.defaults;

  test('more than 24 h ahead → free', () {
    expect(CancellationFee.preview(booking, syria, DateTime.utc(2026, 11, 3, 7)), 0);
  });

  test('exactly 24 h ahead → still free', () {
    expect(CancellationFee.preview(booking, syria, DateTime.utc(2026, 11, 4, 7)), 0);
  });

  test('inside 24 h → 20% of basePrice: 2,400, what staging actually charged', () {
    expect(CancellationFee.preview(booking, syria, DateTime.utc(2026, 11, 4, 7, 1)), 2400);
  });

  test('uses the country numbers, not constants', () {
    const strict = BookingPolicy(
      bookingHorizonDays: 90,
      freeCancellationHours: 48,
      cancellationFeeBasisPoints: 5000,
      interBookingBufferMinutes: 30,
    );
    expect(CancellationFee.preview(booking, strict, DateTime.utc(2026, 11, 3, 8)), 6000);
    expect(CancellationFee.freeUntil(booking, strict), DateTime.utc(2026, 11, 3, 7));
  });

  test('policy parsed from the real /countries block', () {
    final p = BookingPolicy.fromJson(const {
      'responseDeadlineHours': 12,
      'bookingHorizonDays': 90,
      'interBookingBufferMinutes': 30,
      'freeCancellationHours': 24,
      'cancellationFeeBasisPoints': 2000,
    });
    expect(p, BookingPolicy.defaults);
    expect(BookingPolicy.fromJson(null), BookingPolicy.defaults);
  });

  test('a late-cancelled booking carries the server fee', () {
    final cancelled = BookingModel.fromJson(StagingFixtures.cancelledLate);
    expect(cancelled.cancellation!.feeAmount, 2400);
    expect(cancelled.status.customerCanCancel, isFalse);
  });
}
