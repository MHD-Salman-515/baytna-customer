import 'package:baytna_customer/core/error/failure.dart';
import 'package:baytna_customer/core/utils/result.dart';
import 'package:baytna_customer/features/services/data/datasources/service_remote_data_source.dart';
import 'package:baytna_customer/features/services/data/models/service_model.dart';
import 'package:baytna_customer/features/services/data/repositories/service_repository_impl.dart';
import 'package:baytna_customer/features/services/domain/entities/service.dart';
import 'package:baytna_customer/features/services/domain/repositories/service_repository.dart';
import 'package:baytna_customer/features/services/presentation/bloc/services_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements ServiceRemoteDataSource;

class _MockRepo extends Mock implements ServiceRepository;

/// Verbatim element of staging's GET /services (2026-10-26).
const _cleaning = <String, dynamic>{
  'isDeleted': false,
  'deletedAt': null,
  'key': 'CLEANING',
  'name': {'ar': 'تنظيف', 'en': 'Cleaning'},
  'description': {'ar': 'تنظيف المنزل الشامل', 'en': 'General home cleaning'},
  'icon': null,
  'allowedPricingTypes': ['HOURLY', 'BY_SIZE'],
  'commissionRate': null,
  'isActive': true,
  'displayOrder': 1,
  'id': '6adbb9cad141d68e8737557b',
};

void main() {
  test('parses a real staging service; unknown pricing types do not crash', () {
    final s = ServiceModel.fromJson({
      ..._cleaning,
      'allowedPricingTypes': ['HOURLY', 'BY_SIZE', 'PER_PIECE'],
    }).toEntity();
    expect(s.key, 'CLEANING');
    expect(s.name.ar, 'تنظيف');
    expect(s.icon, isNull);
    expect(s.allowedPricingTypes, [
      PricingType.hourly,
      PricingType.bySize,
      PricingType.unknown,
    ]);
  });

  group('repository', () {
    late _MockRemote remote;
    setUp(() => remote = _MockRemote());

    ServiceModel model(String key, int order) => ServiceModel.fromJson({
      ..._cleaning,
      'id': key,
      'key': key,
      'displayOrder': order,
    });

    test('sorts by displayOrder and caches until forceRefresh', () async {
      when(() => remote.fetchActive())
          .thenAnswer((_) async => [model('B', 2), model('A', 1)]);
      final repo = ServiceRepositoryImpl(remote);
      final first = await repo.getServices();
      expect((first as Ok<List<Service>>).value.map((s) => s.key), ['A', 'B']);
      await repo.getServices();
      verify(() => remote.fetchActive()).called(1);
      await repo.getServices(forceRefresh: true);
      verify(() => remote.fetchActive()).called(1);
    });

    test('a failure is returned, not cached', () async {
      when(() => remote.fetchActive()).thenThrow(const NetworkFailure());
      final repo = ServiceRepositoryImpl(remote);
      expect(await repo.getServices(), isA<Err<List<Service>>>());
      when(() => remote.fetchActive()).thenAnswer((_) async => [model('A', 1)]);
      expect(await repo.getServices(), isA<Ok<List<Service>>>());
    });
  });

  group('ServicesBloc', () {
    final service = ServiceModel.fromJson(_cleaning).toEntity();

    blocTest<ServicesBloc, ServicesState>(
      'loads',
      build: () {
        final repo = _MockRepo();
        when(() => repo.getServices(forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => Ok([service]));
        return ServicesBloc(repo);
      },
      act: (b) => b.add(const ServicesRequested()),
      expect: () => [
        const ServicesLoading(),
        ServicesLoaded([service]),
      ],
    );

    blocTest<ServicesBloc, ServicesState>(
      'surfaces a failure',
      build: () {
        final repo = _MockRepo();
        when(() => repo.getServices(forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => const Err(NetworkFailure()));
        return ServicesBloc(repo);
      },
      act: (b) => b.add(const ServicesRequested()),
      expect: () => [
        const ServicesLoading(),
        const ServicesFailure(NetworkFailure()),
      ],
    );
  });
}
