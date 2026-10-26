import 'package:baytna_customer/core/error/failure.dart';
import 'package:baytna_customer/core/geo/geo_point.dart';
import 'package:baytna_customer/core/network/paged.dart';
import 'package:baytna_customer/core/utils/result.dart';
import 'package:baytna_customer/features/bookings/data/booking_model.dart';
import 'package:baytna_customer/features/bookings/data/booking_remote_data_source.dart';
import 'package:baytna_customer/features/bookings/data/booking_repository_impl.dart';
import 'package:baytna_customer/features/bookings/domain/booking_failures.dart';
import 'package:baytna_customer/features/bookings/domain/entities/booking.dart';
import 'package:baytna_customer/features/bookings/domain/entities/new_booking.dart';
import 'package:baytna_customer/features/pricing/domain/job_size.dart';
import 'package:baytna_customer/features/services/domain/entities/service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/staging_fixtures.dart';

class _Remote extends Mock implements BookingRemoteDataSource;

final _request = NewBooking(
  serviceId: StagingFixtures.cleaningId,
  workerServiceId: StagingFixtures.workerServiceId,
  cityId: StagingFixtures.damascusId,
  scheduledFor: DateTime.utc(2026, 11, 5, 7),
  size: const JobSize(pricingType: PricingType.hourly, hours: 2, durationMinutes: 120),
  address: const BookingAddress(
    point: GeoPoint(latitude: 33.5138, longitude: 36.2765),
    text: 'المزة، شارع 12',
    landmark: 'بجانب الجامع الأزرق',
    floor: '3',
  ),
);

void main() {
  setUpAll(() => registerFallbackValue(_request));

  test('request body: what the server needs, no price, no workerId', () {
    final body = _request.toJson();
    expect(body, {
      'type': 'SCHEDULED',
      'serviceId': StagingFixtures.cleaningId,
      'workerServiceId': StagingFixtures.workerServiceId,
      'cityId': StagingFixtures.damascusId,
      'scheduledFor': '2026-11-05T07:00:00.000Z',
      'estimatedDurationMinutes': 120,
      'estimatedHours': 2,
      'address': {
        'point': {
          'type': 'Point',
          'coordinates': [36.2765, 33.5138],
        },
        'text': 'المزة، شارع 12',
        'landmark': 'بجانب الجامع الأزرق',
        'floor': '3',
      },
    });
    final flat = body.toString().toLowerCase();
    expect(flat.contains('price'), isFalse);
    expect(body.containsKey('workerId'), isFalse);
  });

  test('BY_SIZE sends roomCount, never estimatedHours', () {
    final body = NewBooking(
      serviceId: 's',
      workerServiceId: 'ws',
      cityId: 'c',
      scheduledFor: DateTime.utc(2026, 11, 5, 7),
      size: const JobSize(pricingType: PricingType.bySize, roomCount: 3, durationMinutes: 180),
      address: _request.address,
    ).toJson();
    expect(body['roomCount'], 3);
    expect(body.containsKey('estimatedHours'), isFalse);
    expect(body['estimatedDurationMinutes'], 180);
  });

  test('decodes the real POST /bookings answer; phone hidden while pending', () {
    final b = BookingModel.fromJson(StagingFixtures.booking);
    expect(b.bookingNumber, 'BK-4S2DC6');
    expect(b.status, BookingStatus.pendingWorker);
    expect(b.pricing!.basePrice, 12000);
    expect(b.pricing!.hours, 2);
    expect(b.address.landmark, contains('الجامع'));
    expect(b.address.point.latitude, 33.5138);
    expect(b.workerPhone, isNull);
    expect(b.status.customerCanCancel, isTrue);
  });

  group('server refusals → specific failures (messages captured live)', () {
    final cases = <Failure, Type>{
      const ServerFailure(
        409,
        'This time overlaps one of her existing bookings (including the travel buffer between jobs)',
      ): SlotTaken,
      const ValidationFailure(['scheduledFor may not be more than 90 days in the future']): BeyondHorizon,
      const ValidationFailure(['scheduledFor falls outside her available hours for that date']): OutsideHerHours,
      const ValidationFailure(['scheduledFor must be in the future']): InThePast,
      const ValidationFailure(['This worker does not serve the selected city']): CityNotServed,
      const ValidationFailure(['address.landmark should not be empty']): LandmarkMissing,
      const NotFoundFailure('Worker service not found'): WorkerUnavailable,
    };
    for (final MapEntry(key: failure, value: type) in cases.entries) {
      test('$type', () => expect(BookingFailure.from(failure).runtimeType, type));
    }
    test('anything else stays generic', () {
      expect(BookingFailure.from(const ValidationFailure(['something new'])), isA<ValidationFailure>());
    });
  });

  group('no double booking when the answer is lost', () {
    late _Remote remote;
    setUp(() => remote = _Remote());

    test('a timeout whose booking DID land is adopted, not re-sent', () async {
      when(() => remote.create(any())).thenThrow(const TimeoutFailure());
      when(() => remote.list(status: BookingStatus.pendingWorker)).thenAnswer(
        (_) async => Paged(
          items: [BookingModel.fromJson(StagingFixtures.booking)],
          meta: const PageMeta(page: 1, limit: 20, total: 1, totalPages: 1),
        ),
      );
      final result = await BookingRepositoryImpl(remote).create(_request);
      expect((result as Ok<Booking>).value.bookingNumber, 'BK-4S2DC6');
      verify(() => remote.create(any())).called(1);
    });

    test('a timeout that did NOT land is reported, still not re-sent', () async {
      when(() => remote.create(any())).thenThrow(const TimeoutFailure());
      when(() => remote.list(status: BookingStatus.pendingWorker)).thenAnswer(
        (_) async => const Paged(items: [], meta: PageMeta(page: 1, limit: 20, total: 0, totalPages: 1)),
      );
      final result = await BookingRepositoryImpl(remote).create(_request);
      expect((result as Err<Booking>).failure, isA<TimeoutFailure>());
      verify(() => remote.create(any())).called(1);
    });

    test('a clear refusal never triggers the lookup', () async {
      when(() => remote.create(any())).thenThrow(const ServerFailure(409, 'overlaps'));
      final result = await BookingRepositoryImpl(remote).create(_request);
      expect((result as Err<Booking>).failure, isA<SlotTaken>());
      verifyNever(() => remote.list(status: any(named: 'status')));
    });
  });
}
