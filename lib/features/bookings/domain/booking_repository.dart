import 'package:baytna_customer/core/network/paged.dart';
import 'package:baytna_customer/core/utils/result.dart';
import 'package:baytna_customer/features/bookings/domain/entities/booking.dart';
import 'package:baytna_customer/features/bookings/domain/entities/new_booking.dart';

abstract interface class BookingRepository {
  /// Errors the server explains come back as a `BookingFailure`.
  Future<Result<Booking>> create(NewBooking booking);

  /// Hers, newest first. [status] filters server-side.
  Future<Result<Paged<Booking>>> list({BookingStatus? status, int page = 1});

  Future<Result<Booking>> get(String id);

  /// Returns the cancelled booking, including the fee the server charged.
  Future<Result<Booking>> cancel(String id, String reason);
}
