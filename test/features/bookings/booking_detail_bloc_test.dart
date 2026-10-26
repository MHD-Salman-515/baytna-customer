import 'package:baytna_customer/core/error/failure.dart';
import 'package:baytna_customer/core/localization/localized_text.dart';
import 'package:baytna_customer/core/utils/clock.dart';
import 'package:baytna_customer/core/utils/result.dart';
import 'package:baytna_customer/features/bookings/data/booking_model.dart';
import 'package:baytna_customer/features/bookings/domain/booking_repository.dart';
import 'package:baytna_customer/features/bookings/domain/entities/booking.dart';
import 'package:baytna_customer/features/bookings/presentation/bloc/detail/booking_detail_bloc.dart';
import 'package:baytna_customer/features/countries/domain/entities/country.dart';
import 'package:baytna_customer/features/countries/domain/repositories/country_repository.dart';
import 'package:baytna_customer/features/services/data/models/service_model.dart';
import 'package:baytna_customer/features/services/domain/entities/service.dart';
import 'package:baytna_customer/features/services/domain/repositories/service_repository.dart';
import 'package:baytna_customer/features/workers/domain/repositories/worker_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/staging_fixtures.dart';

class _Bookings extends Mock implements BookingRepository;

class _Countries extends Mock implements CountryRepository;

class _Services extends Mock implements ServiceRepository;

class _Workers extends Mock implements WorkerRepository;

class _Clock extends Clock {
  const _Clock(this.fixed);
  final DateTime fixed;
  @override
  DateTime now() => fixed;
}

const _syria = Country(
  id: '6adbb9bbd141d68e87375528',
  code: 'SY',
  name: LocalizedText(ar: 'سوريا', en: 'Syria'),
  phonePrefix: '+963',
  currencyCode: 'SYP',
  timezone: 'Asia/Damascus',
);

void main() {
  final pending = BookingModel.fromJson(StagingFixtures.booking);
  final accepted = BookingModel.fromJson({
    ...StagingFixtures.booking,
    'status': 'ACCEPTED',
    'acceptedAt': '2026-10-26T13:00:00.000Z',
    'workerPhone': '+963945958947',
  });
  late _Bookings bookings;
  late _Workers workers;

  setUp(() {
    bookings = _Bookings();
    workers = _Workers();
  });

  BookingDetailBloc build(DateTime now) {
    final countries = _Countries();
    final services = _Services();
    when(() => countries.getById(any())).thenAnswer((_) async => const Ok(_syria));
    when(services.getServices).thenAnswer(
      (_) async => Ok<List<Service>>([
        ServiceModel.fromJson({
          'id': StagingFixtures.cleaningId,
          'key': 'CLEANING',
          'name': {'ar': 'تنظيف', 'en': 'Cleaning'},
          'description': {'ar': '', 'en': ''},
        }).toEntity(),
      ]),
    );
    return BookingDetailBloc(bookings, countries, services, workers, _Clock(now));
  }

  Future<BookingDetailState> settle(BookingDetailBloc bloc) async {
    for (var i = 0; i < 8; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    return bloc.state;
  }

  test('PENDING: the phone is hidden (null), and her missing profile is not an error', () async {
    when(() => bookings.get(any())).thenAnswer((_) async => Ok(pending));
    when(() => workers.getWorker(any())).thenAnswer((_) async => const Err(NotFoundFailure('Worker not found')));
    final s = await settle(build(DateTime.utc(2026, 10, 26, 12))..add(BookingDetailRequested(pending.id)));
    expect(s.status, DetailStatus.loaded);
    expect(s.booking!.workerPhone, isNull);
    expect(s.service!.key, 'CLEANING');
    expect(s.worker, isNull);
  });

  test('ACCEPTED: the phone the server now sends is shown', () async {
    when(() => bookings.get(any())).thenAnswer((_) async => Ok(accepted));
    when(() => workers.getWorker(any())).thenAnswer((_) async => const Err(NotFoundFailure()));
    final s = await settle(build(DateTime.utc(2026, 10, 26, 14))..add(BookingDetailRequested(accepted.id)));
    expect(s.booking!.workerPhone, '+963945958947');
  });

  test('fee preview: free 10 days ahead, 2,400 within 24 h', () async {
    when(() => bookings.get(any())).thenAnswer((_) async => Ok(pending));
    when(() => workers.getWorker(any())).thenAnswer((_) async => const Err(NotFoundFailure()));
    final early = build(DateTime.utc(2026, 10, 26, 12))..add(BookingDetailRequested(pending.id));
    await settle(early);
    expect(early.feePreview(), 0);
    final late = build(DateTime.utc(2026, 11, 4, 20))..add(BookingDetailRequested(pending.id));
    await settle(late);
    expect(late.feePreview(), 2400);
  });

  test('cancel sends the trimmed reason and shows the server result', () async {
    when(() => bookings.get(any())).thenAnswer((_) async => Ok(pending));
    when(() => workers.getWorker(any())).thenAnswer((_) async => const Err(NotFoundFailure()));
    when(() => bookings.cancel(any(), any()))
        .thenAnswer((_) async => Ok(BookingModel.fromJson(StagingFixtures.cancelledLate)));
    final bloc = build(DateTime.utc(2026, 11, 4, 20))..add(BookingDetailRequested(pending.id));
    await settle(bloc);
    bloc.add(const BookingCancelRequested('  تغيّرت خططي '));
    final s = await settle(bloc);
    verify(() => bookings.cancel(pending.id, 'تغيّرت خططي')).called(1);
    expect(s.booking!.status, BookingStatus.cancelled);
    expect(s.booking!.cancellation!.feeAmount, 2400);
  });

  test('a refused cancel reports and reloads (her status may have moved on)', () async {
    when(() => bookings.get(any())).thenAnswer((_) async => Ok(pending));
    when(() => workers.getWorker(any())).thenAnswer((_) async => const Err(NotFoundFailure()));
    when(() => bookings.cancel(any(), any())).thenAnswer(
      (_) async => const Err(ValidationFailure(['Cannot CUSTOMER_CANCEL a booking from status IN_PROGRESS'])),
    );
    final bloc = build(DateTime.utc(2026, 10, 26, 12))..add(BookingDetailRequested(pending.id));
    await settle(bloc);
    bloc.add(const BookingCancelRequested('x'));
    final s = await settle(bloc);
    expect(s.cancelFailure, isA<ValidationFailure>());
    verify(() => bookings.get(pending.id)).called(2);
  });
}
