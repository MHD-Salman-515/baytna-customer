import 'package:baytna_customer/core/network/api_client.dart';
import 'package:baytna_customer/core/network/json.dart';
import 'package:baytna_customer/core/network/paged.dart';
import 'package:baytna_customer/features/bookings/data/booking_model.dart';
import 'package:baytna_customer/features/bookings/domain/entities/booking.dart';
import 'package:baytna_customer/features/bookings/domain/entities/new_booking.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class BookingRemoteDataSource {
  BookingRemoteDataSource(this._api);

  final ApiClient _api;

  static const pageSize = 20;

  /// Not retried on a 504 by the network layer (it may have landed); see
  /// BookingRepositoryImpl.create for how an ambiguous outcome is resolved.
  Future<Booking> create(NewBooking booking) => _api.post(
    '/bookings',
    body: booking.toJson(),
    decode: (data) => BookingModel.fromJson(asJson(data)),
  );

  /// Her bookings, newest first; [status] filters server-side.
  Future<Paged<Booking>> list({BookingStatus? status, int page = 1}) => _api.getPage(
    '/bookings',
    query: {'status': ?status?.wire, 'page': page, 'limit': pageSize},
    decodeItem: BookingModel.fromJson,
  );

  Future<Booking> get(String id) =>
      _api.get('/bookings/$id', decode: (data) => BookingModel.fromJson(asJson(data)));

  /// [reason] is required and must not be empty (400 otherwise).
  Future<Booking> cancel(String id, String reason) => _api.post(
    '/bookings/$id/cancel',
    body: {'reason': reason},
    decode: (data) => BookingModel.fromJson(asJson(data)),
  );
}
