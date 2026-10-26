import 'package:baytna_customer/core/error/failure.dart';
import 'package:baytna_customer/core/geo/geo_point.dart';
import 'package:baytna_customer/core/location/location_service.dart';
import 'package:baytna_customer/core/time/country_time.dart';
import 'package:baytna_customer/core/utils/clock.dart';
import 'package:baytna_customer/core/utils/result.dart';
import 'package:baytna_customer/features/bookings/domain/booking_failures.dart';
import 'package:baytna_customer/features/bookings/domain/booking_repository.dart';
import 'package:baytna_customer/features/bookings/domain/entities/booking.dart';
import 'package:baytna_customer/features/bookings/domain/entities/new_booking.dart';
import 'package:baytna_customer/features/bookings/domain/start_times.dart';
import 'package:baytna_customer/features/cities/domain/entities/city.dart';
import 'package:baytna_customer/features/cities/domain/repositories/city_repository.dart';
import 'package:baytna_customer/features/countries/domain/entities/country.dart';
import 'package:baytna_customer/features/countries/domain/repositories/country_repository.dart';
import 'package:baytna_customer/features/pricing/domain/job_size.dart';
import 'package:baytna_customer/features/pricing/domain/pricing_repository.dart';
import 'package:baytna_customer/features/pricing/domain/quote.dart';
import 'package:baytna_customer/features/services/domain/entities/service.dart';
import 'package:baytna_customer/features/workers/domain/entities/worker.dart';
import 'package:baytna_customer/features/workers/domain/repositories/worker_repository.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'booking_flow_event.dart';
part 'booking_flow_state.dart';

/// Time → address → review → POST /bookings, for one offering of one worker.
@injectable
class BookingFlowBloc extends Bloc<BookingFlowEvent, BookingFlowState> {
  BookingFlowBloc(
    this._workers,
    this._countries,
    this._cities,
    this._pricing,
    this._bookings,
    this._location,
    this._clock,
  ) : super(const BookingFlowState()) {
    on<FlowStarted>(_onStarted);
    on<FlowDaySelected>(_onDaySelected, transformer: restartable());
    on<FlowStartSelected>((e, emit) => emit(state.copyWith(start: e.start)));
    on<FlowStepRequested>(_onStepRequested);
    on<FlowPinMoved>((e, emit) => emit(state.copyWith(pin: e.point)));
    on<FlowLocateRequested>(_onLocate, transformer: droppable());
    on<FlowAddressSubmitted>(_onAddressSubmitted);
    on<FlowSubmitted>(_onSubmitted, transformer: droppable());
  }

  final WorkerRepository _workers;
  final CountryRepository _countries;
  final CityRepository _cities;
  final PricingRepository _pricing;
  final BookingRepository _bookings;
  final LocationService _location;
  final Clock _clock;

  /// A GPS fix farther than this from the booking city is not her door in
  /// that city (an emulator in California, or booking for her mother in
  /// another city): start from the city centre instead.
  static const maxGpsDistanceKm = 40.0;

  /// Day chips shown before she reaches for the calendar.
  static const quickDays = 14;

  Future<void> _onStarted(FlowStarted e, Emitter<BookingFlowState> emit) async {
    emit(const BookingFlowState());
    final worker = await _workers.getWorker(e.workerId);
    final country = await _countries.getById(e.countryId);
    final cities = await _cities.getCities(e.countryId);
    final failure = [worker, country, cities].whereType<Err<Object?>>().firstOrNull?.failure;
    if (failure != null) {
      emit(state.copyWith(setup: SetupStatus.failure, failure: failure));
      return;
    }
    final w = (worker as Ok<Worker>).value;
    final offering = w.offeringFor(e.serviceId);
    final city = (cities as Ok<List<City>>).value.where((c) => c.id == e.cityId).firstOrNull;
    if (offering == null || !offering.isBookable || city == null || !w.serviceAreas.contains(city.id)) {
      emit(state.copyWith(setup: SetupStatus.failure, failure: const WorkerUnavailable()));
      return;
    }
    final size = switch (offering.pricingType) {
      PricingType.hourly => JobSize(
        pricingType: offering.pricingType,
        hours: e.hours,
        durationMinutes: DurationSteps.minutes(e.hours ?? DurationSteps.defaultHours),
      ),
      PricingType.bySize => JobSize(
        pricingType: offering.pricingType,
        roomCount: e.rooms,
        durationMinutes: e.durationMinutes ?? DurationSteps.minutes(DurationSteps.defaultHours),
      ),
      PricingType.fixed || PricingType.unknown => JobSize(
        pricingType: offering.pricingType,
        durationMinutes: e.durationMinutes ?? DurationSteps.minutes(DurationSteps.defaultHours),
      ),
    };
    emit(state.copyWith(
      setup: SetupStatus.ready,
      worker: w,
      offering: offering,
      country: (country as Ok<Country>).value,
      city: city,
      size: size,
      pin: city.center,
      pinFromGps: false,
    ));
    add(const FlowDaySelected(0));
  }

  Future<void> _onDaySelected(FlowDaySelected e, Emitter<BookingFlowState> emit) async {
    final time = state.time;
    if (time == null) return;
    final now = _clock.now();
    final day = time.day(now, e.daysFromToday);
    emit(state.copyWith(day: e.daysFromToday, slots: SlotsStatus.loading, startTimes: const [], clearStart: true));
    final result = await _workers.getFreeIntervals(state.worker!.id, time.dateKey(day));
    switch (result) {
      case Ok(:final value):
        emit(state.copyWith(
          slots: SlotsStatus.ready,
          startTimes: StartTimes.compute(
            intervals: value,
            duration: Duration(minutes: state.size!.durationMinutes),
            now: now,
            horizonDays: state.country!.bookingPolicy.bookingHorizonDays,
          ),
        ));
      case Err(:final failure):
        emit(state.copyWith(slots: SlotsStatus.failure, failure: failure));
    }
  }

  Future<void> _onStepRequested(FlowStepRequested e, Emitter<BookingFlowState> emit) async {
    if (e.step == FlowStep.address && state.step == FlowStep.time) {
      if (state.start == null) return;
      emit(state.copyWith(step: FlowStep.address));
      // Try her position once, the first time she reaches the map.
      if (!state.locationTried) add(const FlowLocateRequested());
      return;
    }
    emit(state.copyWith(step: e.step, clearSubmitFailure: true));
  }

  Future<void> _onLocate(FlowLocateRequested e, Emitter<BookingFlowState> emit) async {
    emit(state.copyWith(locating: true, locationTried: true));
    final here = await _location.currentPosition();
    final center = state.city?.center;
    final usable = here != null && (center == null || distanceKm(here, center) <= maxGpsDistanceKm);
    emit(state.copyWith(
      locating: false,
      pin: usable ? here : state.pin,
      pinFromGps: usable || state.pinFromGps,
      gpsTooFar: here != null && !usable,
    ));
  }

  Future<void> _onAddressSubmitted(FlowAddressSubmitted e, Emitter<BookingFlowState> emit) async {
    final pin = state.pin;
    if (pin == null) return;
    emit(state.copyWith(
      address: BookingAddress(
        point: pin,
        text: e.text.trim(),
        landmark: e.landmark.trim(),
        floor: e.floor.trim(),
        notes: e.notes.trim(),
      ),
      step: FlowStep.review,
      clearQuote: true,
    ));
    // A fresh quote for the review: the price she sees right before confirming.
    final size = state.size!;
    final quote = await _pricing.quote(
      state.offering!.workerServiceId!,
      hours: size.pricingType == PricingType.hourly ? size.hours : null,
      roomCount: size.pricingType == PricingType.bySize ? size.roomCount : null,
    );
    if (quote case Ok(:final value)) emit(state.copyWith(quote: value));
  }

  Future<void> _onSubmitted(FlowSubmitted e, Emitter<BookingFlowState> emit) async {
    final start = state.start;
    final address = state.address;
    if (start == null || address == null || state.submitting) return;
    emit(state.copyWith(submitting: true, clearSubmitFailure: true));
    final result = await _bookings.create(NewBooking(
      serviceId: state.offering!.serviceId,
      workerServiceId: state.offering!.workerServiceId!,
      cityId: state.city!.id,
      scheduledFor: start,
      size: state.size!,
      address: address,
    ));
    switch (result) {
      case Ok(:final value):
        emit(state.copyWith(submitting: false, created: value));
      case Err(:final failure):
        final backToTime = failure is SlotTaken || failure is OutsideHerHours || failure is InThePast || failure is BeyondHorizon;
        emit(state.copyWith(
          submitting: false,
          submitFailure: failure,
          step: backToTime ? FlowStep.time : state.step,
        ));
        // Her free times changed under us: show the real ones again.
        if (backToTime) add(FlowDaySelected(state.day));
    }
  }
}
