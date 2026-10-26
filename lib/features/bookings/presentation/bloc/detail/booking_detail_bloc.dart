import 'package:baytna_customer/core/error/failure.dart';
import 'package:baytna_customer/core/utils/clock.dart';
import 'package:baytna_customer/core/utils/result.dart';
import 'package:baytna_customer/features/bookings/domain/booking_repository.dart';
import 'package:baytna_customer/features/bookings/domain/cancellation_fee.dart';
import 'package:baytna_customer/features/bookings/domain/entities/booking.dart';
import 'package:baytna_customer/features/countries/domain/entities/country.dart';
import 'package:baytna_customer/features/countries/domain/repositories/country_repository.dart';
import 'package:baytna_customer/features/services/domain/entities/service.dart';
import 'package:baytna_customer/features/services/domain/repositories/service_repository.dart';
import 'package:baytna_customer/features/workers/domain/entities/worker.dart';
import 'package:baytna_customer/features/workers/domain/repositories/worker_repository.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'booking_detail_event.dart';
part 'booking_detail_state.dart';

@injectable
class BookingDetailBloc extends Bloc<BookingDetailEvent, BookingDetailState> {
  BookingDetailBloc(this._bookings, this._countries, this._services, this._workers, this._clock)
    : super(const BookingDetailState()) {
    on<BookingDetailRequested>(_onRequested, transformer: restartable());
    on<BookingCancelRequested>(_onCancel, transformer: droppable());
  }

  final BookingRepository _bookings;
  final CountryRepository _countries;
  final ServiceRepository _services;
  final WorkerRepository _workers;
  final Clock _clock;

  Future<void> _onRequested(BookingDetailRequested e, Emitter<BookingDetailState> emit) async {
    if (state.booking == null) emit(const BookingDetailState());
    final result = await _bookings.get(e.id);
    switch (result) {
      case Err(:final failure):
        emit(state.copyWith(status: DetailStatus.failure, failure: failure));
        return;
      case Ok(value: final booking):
        final country = await _countries.getById(booking.countryId);
        final services = await _services.getServices();
        // Her public profile only exists while she's bookable; a booking
        // outlives that, so a 404 here just means "no name to show".
        final worker = await _workers.getWorker(booking.workerProfileId);
        emit(state.copyWith(
          status: DetailStatus.loaded,
          booking: booking,
          country: switch (country) {
            Ok(:final value) => value,
            Err() => state.country,
          },
          service: switch (services) {
            Ok(:final value) => value.where((s) => s.id == booking.serviceId).firstOrNull,
            Err() => state.service,
          },
          worker: switch (worker) {
            Ok(:final value) => value,
            Err() => state.worker,
          },
        ));
    }
  }

  Future<void> _onCancel(BookingCancelRequested e, Emitter<BookingDetailState> emit) async {
    final booking = state.booking;
    if (booking == null || !booking.status.customerCanCancel) return;
    emit(state.copyWith(cancelling: true, clearCancelFailure: true));
    final result = await _bookings.cancel(booking.id, e.reason.trim());
    switch (result) {
      case Ok(:final value):
        emit(state.copyWith(booking: value, cancelling: false));
      case Err(:final failure):
        emit(state.copyWith(cancelling: false, cancelFailure: failure));
        // Her status may have moved on (e.g. the worker started); refresh.
        add(BookingDetailRequested(booking.id));
    }
  }

  /// Fee for cancelling right now, from the country's policy.
  num feePreview() {
    final booking = state.booking;
    final country = state.country;
    if (booking == null) return 0;
    return CancellationFee.preview(booking, country?.bookingPolicy ?? BookingPolicy.defaults, _clock.now());
  }

  DateTime now() => _clock.now();
}
