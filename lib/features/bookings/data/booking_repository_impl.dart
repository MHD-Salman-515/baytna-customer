import 'package:baytna_customer/core/error/failure.dart';
import 'package:baytna_customer/core/utils/result.dart';
import 'package:baytna_customer/features/bookings/data/booking_remote_data_source.dart';
import 'package:baytna_customer/features/bookings/domain/booking_failures.dart';
import 'package:baytna_customer/features/bookings/domain/booking_repository.dart';
import 'package:baytna_customer/features/bookings/domain/entities/booking.dart';
import 'package:baytna_customer/features/bookings/domain/entities/new_booking.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: BookingRepository)
class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl(this._remote);

  final BookingRemoteDataSource _remote;

  @override
  Future<Result<Booking>> create(NewBooking booking) async {
    final result = await guard(() => _remote.create(booking));
    if (result case Err(:final failure)) {
      if (_isAmbiguous(failure)) {
        // The request may have been processed even though we got no answer.
        // Retrying blindly could book her twice (the backend doesn't
        // dedupe), so look for it first.
        if (await _findLanded(booking) case final landed?) return Ok(landed);
      }
      return Err(BookingFailure.from(failure));
    }
    return result;
  }

  /// No answer, or a gateway error after the request may have reached the app.
  static bool _isAmbiguous(Failure f) => switch (f) {
    TimeoutFailure() || NetworkFailure() => true,
    ServerFailure(:final statusCode) => statusCode == null || statusCode >= 500,
    _ => false,
  };

  Future<Booking?> _findLanded(NewBooking booking) async {
    final page = await guard(() => _remote.list(status: BookingStatus.pendingWorker));
    if (page case Ok(:final value)) {
      return value.items
          .where((b) => b.workerServiceId == booking.workerServiceId && b.scheduledFor.isAtSameMomentAs(booking.scheduledFor))
          .firstOrNull;
    }
    return null;
  }
}
