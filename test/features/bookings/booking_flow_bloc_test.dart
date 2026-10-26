import 'package:baytna_customer/core/geo/geo_point.dart';
import 'package:baytna_customer/core/localization/localized_text.dart';
import 'package:baytna_customer/core/location/location_service.dart';
import 'package:baytna_customer/core/utils/clock.dart';
import 'package:baytna_customer/core/utils/result.dart';
import 'package:baytna_customer/features/bookings/data/booking_model.dart';
import 'package:baytna_customer/features/bookings/domain/booking_failures.dart';
import 'package:baytna_customer/features/bookings/domain/booking_repository.dart';
import 'package:baytna_customer/features/bookings/domain/entities/new_booking.dart';
import 'package:baytna_customer/features/bookings/presentation/bloc/flow/booking_flow_bloc.dart';
import 'package:baytna_customer/features/cities/data/models/city_model.dart';
import 'package:baytna_customer/features/cities/domain/entities/city.dart';
import 'package:baytna_customer/features/cities/domain/repositories/city_repository.dart';
import 'package:baytna_customer/features/countries/domain/entities/country.dart';
import 'package:baytna_customer/features/countries/domain/repositories/country_repository.dart';
import 'package:baytna_customer/features/pricing/domain/job_size.dart';
import 'package:baytna_customer/features/pricing/domain/pricing_repository.dart';
import 'package:baytna_customer/features/pricing/domain/quote.dart';
import 'package:baytna_customer/features/services/domain/entities/service.dart';
import 'package:baytna_customer/features/workers/domain/entities/free_interval.dart';
import 'package:baytna_customer/features/workers/domain/entities/worker.dart';
import 'package:baytna_customer/features/workers/domain/repositories/worker_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/staging_fixtures.dart';

class _Workers extends Mock implements WorkerRepository;

class _Countries extends Mock implements CountryRepository;

class _Cities extends Mock implements CityRepository;

class _Pricing extends Mock implements PricingRepository;

class _Bookings extends Mock implements BookingRepository;

class _Location extends Mock implements LocationService;

class _Clock extends Clock {
  const _Clock(this.fixed);
  final DateTime fixed;
  @override
  DateTime now() => fixed;
}

const _syria = Country(
  id: 'sy',
  code: 'SY',
  name: LocalizedText(ar: 'سوريا', en: 'Syria'),
  phonePrefix: '+963',
  currencyCode: 'SYP',
  timezone: 'Asia/Damascus',
);

// The live worker, with the workerServiceId the backend doesn't send yet.
const _worker = Worker(
  id: StagingFixtures.workerId,
  bio: LocalizedText(ar: '', en: ''),
  rating: 0,
  cityId: StagingFixtures.damascusId,
  serviceAreas: [StagingFixtures.aleppoId, StagingFixtures.damascusId],
  offerings: [
    WorkerOffering(
      serviceId: StagingFixtures.cleaningId,
      serviceName: LocalizedText(ar: 'تنظيف', en: 'Cleaning'),
      pricingType: PricingType.hourly,
      displayPrice: 6000,
      currency: 'SYP',
      workerServiceId: StagingFixtures.workerServiceId,
    ),
  ],
);

void main() {
  setUpAll(() {
    registerFallbackValue(NewBooking(
      serviceId: '',
      workerServiceId: '',
      cityId: '',
      scheduledFor: DateTime.utc(2026),
      size: const JobSize(pricingType: PricingType.hourly, durationMinutes: 60),
      address: BookingModel.fromJson(StagingFixtures.booking).address,
    ));
  });

  final damascus = CityModel.fromJson(StagingFixtures.damascus).toEntity();
  // Monday 26 Oct 2026, 11:53 UTC = 14:53 in Damascus.
  final now = DateTime.utc(2026, 10, 26, 11, 53);

  late _Workers workers;
  late _Location location;
  late _Bookings bookings;

  setUp(() {
    workers = _Workers();
    location = _Location();
    bookings = _Bookings();
    when(() => workers.getWorker(any())).thenAnswer((_) async => const Ok(_worker));
    when(() => workers.getFreeIntervals(any(), any())).thenAnswer(
      (i) async => Ok([
        FreeInterval(
          start: DateTime.parse('${i.positionalArguments[1]}T05:00:00.000Z'),
          end: DateTime.parse('${i.positionalArguments[1]}T17:00:00.000Z'),
        ),
      ]),
    );
  });

  BookingFlowBloc build() {
    final countries = _Countries();
    final cities = _Cities();
    final pricing = _Pricing();
    when(() => countries.getById(any())).thenAnswer((_) async => const Ok(_syria));
    when(() => cities.getCities(any())).thenAnswer((_) async => Ok<List<City>>([damascus]));
    when(() => pricing.quote(any(), hours: any(named: 'hours'), roomCount: any(named: 'roomCount'))).thenAnswer(
      (_) async => const Ok(Quote(price: 12000, currency: 'SYP', pricingType: PricingType.hourly, hours: 2)),
    );
    return BookingFlowBloc(workers, countries, cities, pricing, bookings, location, _Clock(now));
  }

  Future<BookingFlowState> settle(BookingFlowBloc bloc) async {
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    return bloc.state;
  }

  const start = FlowStarted(
    workerId: StagingFixtures.workerId,
    serviceId: StagingFixtures.cleaningId,
    cityId: StagingFixtures.damascusId,
    countryId: 'sy',
    hours: 2,
  );

  test('opens on today in DAMASCUS time and offers only future, fitting times', () async {
    final bloc = build()..add(start);
    final s = await settle(bloc);
    verify(() => workers.getFreeIntervals(StagingFixtures.workerId, '2026-10-26')).called(1);
    // Now + 1 h lead = 12:53Z → first half-hour 13:00Z (16:00 Damascus);
    // a 2-hour job must end by 17:00Z → last start 15:00Z.
    expect(s.startTimes.first, DateTime.utc(2026, 10, 26, 13));
    expect(s.startTimes.last, DateTime.utc(2026, 10, 26, 15));
    expect(s.size!.durationMinutes, 120);
    expect(s.pin, damascus.center);
  });

  test('a GPS fix in the city moves the pin there', () async {
    const mezzeh = GeoPoint(latitude: 33.5005, longitude: 36.2500);
    when(() => location.currentPosition()).thenAnswer((_) async => mezzeh);
    final bloc = build()..add(start);
    await settle(bloc);
    bloc
      ..add(FlowStartSelected(DateTime.utc(2026, 10, 26, 13)))
      ..add(const FlowStepRequested(FlowStep.address));
    final s = await settle(bloc);
    expect(s.step, FlowStep.address);
    expect(s.pin, mezzeh);
    expect(s.pinFromGps, isTrue);
  });

  test('a GPS fix far away (emulator in California) keeps the city centre', () async {
    when(() => location.currentPosition())
        .thenAnswer((_) async => const GeoPoint(latitude: 37.4220, longitude: -122.0841));
    final bloc = build()..add(start);
    await settle(bloc);
    bloc
      ..add(FlowStartSelected(DateTime.utc(2026, 10, 26, 13)))
      ..add(const FlowStepRequested(FlowStep.address));
    final s = await settle(bloc);
    expect(s.pin, damascus.center);
    expect(s.pinFromGps, isFalse);
    expect(s.gpsTooFar, isTrue);
  });

  test('cannot leave the time step without a time', () async {
    final bloc = build()..add(start);
    await settle(bloc);
    bloc.add(const FlowStepRequested(FlowStep.address));
    expect((await settle(bloc)).step, FlowStep.time);
  });

  Future<BookingFlowBloc> atReview() async {
    when(() => location.currentPosition()).thenAnswer((_) async => null);
    final bloc = build()..add(start);
    await settle(bloc);
    bloc
      ..add(FlowStartSelected(DateTime.utc(2026, 10, 26, 13)))
      ..add(const FlowStepRequested(FlowStep.address));
    await settle(bloc);
    bloc.add(const FlowAddressSubmitted(landmark: '  مقابل الصيدلية ', text: 'المزة', floor: '3'));
    await settle(bloc);
    return bloc;
  }

  test('review shows a fresh server quote; submit sends exactly the chosen booking', () async {
    when(() => bookings.create(any())).thenAnswer((_) async => Ok(BookingModel.fromJson(StagingFixtures.booking)));
    final bloc = await atReview();
    expect(bloc.state.step, FlowStep.review);
    expect(bloc.state.quote!.price, 12000);
    expect(bloc.state.address!.landmark, 'مقابل الصيدلية');

    bloc.add(const FlowSubmitted());
    final s = await settle(bloc);
    final sent = verify(() => bookings.create(captureAny())).captured.single as NewBooking;
    expect(sent.workerServiceId, StagingFixtures.workerServiceId);
    expect(sent.cityId, StagingFixtures.damascusId);
    expect(sent.scheduledFor, DateTime.utc(2026, 10, 26, 13));
    expect(sent.size.hours, 2);
    expect(sent.address.point, damascus.center);
    expect(s.created!.bookingNumber, 'BK-4S2DC6');
  });

  test('slot taken meanwhile → back to the time step with fresh times', () async {
    when(() => bookings.create(any())).thenAnswer((_) async => const Err(SlotTaken()));
    final bloc = await atReview();
    clearInteractions(workers);
    bloc.add(const FlowSubmitted());
    final s = await settle(bloc);
    expect(s.step, FlowStep.time);
    expect(s.submitFailure, isA<SlotTaken>());
    expect(s.start, isNull);
    verify(() => workers.getFreeIntervals(any(), '2026-10-26')).called(1);
  });

  test('she is no longer offering it → setup fails as WorkerUnavailable', () async {
    when(() => workers.getWorker(any())).thenAnswer(
      (_) async => Ok(Worker(
        id: _worker.id,
        bio: _worker.bio,
        rating: 0,
        cityId: _worker.cityId,
        serviceAreas: _worker.serviceAreas,
        offerings: const [],
      )),
    );
    final s = await settle(build()..add(start));
    expect(s.setup, SetupStatus.failure);
    expect(s.failure, isA<WorkerUnavailable>());
  });
}
