import 'package:baytna_customer/core/error/failure.dart';
import 'package:baytna_customer/core/utils/result.dart';
import 'package:baytna_customer/features/cities/data/models/city_model.dart';
import 'package:baytna_customer/features/cities/domain/entities/city.dart';
import 'package:baytna_customer/features/cities/domain/repositories/city_repository.dart';
import 'package:baytna_customer/features/workers/data/models/worker_model.dart';
import 'package:baytna_customer/features/workers/domain/repositories/worker_repository.dart';
import 'package:baytna_customer/features/workers/presentation/bloc/detail/worker_detail_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/staging_fixtures.dart';

class _Workers extends Mock implements WorkerRepository;

class _Cities extends Mock implements CityRepository;

void main() {
  final worker = WorkerModel.fromJson(StagingFixtures.worker);
  final damascus = CityModel.fromJson(StagingFixtures.damascus).toEntity();
  const request = WorkerDetailRequested(workerId: StagingFixtures.workerId, countryId: 'sy');

  blocTest<WorkerDetailBloc, WorkerDetailState>(
    'loads her profile with the names of the cities she serves',
    build: () {
      final workers = _Workers();
      final cities = _Cities();
      when(() => workers.getWorker(any())).thenAnswer((_) async => Ok(worker));
      when(() => cities.getCities(any())).thenAnswer((_) async => Ok<List<City>>([damascus]));
      return WorkerDetailBloc(workers, cities);
    },
    act: (b) => b.add(request),
    expect: () => [
      const WorkerDetailLoading(),
      WorkerDetailLoaded(worker: worker, cities: {damascus.id: damascus}),
    ],
  );

  blocTest<WorkerDetailBloc, WorkerDetailState>(
    'a failed city lookup still shows her profile',
    build: () {
      final workers = _Workers();
      final cities = _Cities();
      when(() => workers.getWorker(any())).thenAnswer((_) async => Ok(worker));
      when(() => cities.getCities(any())).thenAnswer((_) async => const Err(NetworkFailure()));
      return WorkerDetailBloc(workers, cities);
    },
    act: (b) => b.add(request),
    expect: () => [const WorkerDetailLoading(), WorkerDetailLoaded(worker: worker, cities: const {})],
  );

  blocTest<WorkerDetailBloc, WorkerDetailState>(
    'she is no longer bookable → failure the screen can retry',
    build: () {
      final workers = _Workers();
      final cities = _Cities();
      when(() => workers.getWorker(any())).thenAnswer((_) async => const Err(NotFoundFailure('Worker not found')));
      when(() => cities.getCities(any())).thenAnswer((_) async => Ok<List<City>>([damascus]));
      return WorkerDetailBloc(workers, cities);
    },
    act: (b) => b.add(request),
    expect: () => [const WorkerDetailLoading(), const WorkerDetailFailure(NotFoundFailure('Worker not found'))],
  );
}
