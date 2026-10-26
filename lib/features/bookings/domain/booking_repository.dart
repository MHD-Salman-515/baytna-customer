import 'package:baytna_customer/core/utils/result.dart';
import 'package:baytna_customer/features/bookings/domain/entities/booking.dart';
import 'package:baytna_customer/features/bookings/domain/entities/new_booking.dart';

abstract interface class BookingRepository {
  /// Errors the server explains come back as a `BookingFailure`.
  Future<Result<Booking>> create(NewBooking booking);
}
