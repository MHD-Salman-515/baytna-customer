import 'package:baytna_customer/core/error/failure.dart';
import 'package:baytna_customer/core/network/paged.dart';
import 'package:baytna_customer/core/utils/result.dart';
import 'package:baytna_customer/features/cities/data/models/city_model.dart';
import 'package:baytna_customer/features/cities/domain/city_selection.dart';
import 'package:baytna_customer/features/cities/domain/entities/city.dart';
import 'package:baytna_customer/features/cities/domain/repositories/city_repository.dart';
import 'package:baytna_customer/features/workers/data/models/worker_model.dart';
import 'package:baytna_customer/features/workers/domain/entities/worker.dart';
import 'package:baytna_customer/features/workers/domain/entities/worker_query.dart';
import 'package:baytna_customer/features/workers/domain/repositories/worker_repository.dart';
import 'package:baytna_customer/features/workers/presentation/bloc/browse/browse_workers_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/staging_fixtures.dart';

class _Workers extends Mock implements WorkerRepository;

class _Cities extends Mock implements CityRepository;

void main() {
  setUpAll(() => registerFallbackValue(const WorkerQuery(cityId: '', serviceId: '')));

  final damascus = CityModel.fromJson(StagingFixtures.damascus).toEntity();
  final aleppo = CityModel.fromJson({
    ...StagingFixtures.damascus,
    'id': StagingFixtures.aleppoId,
    'name': {'ar': 'حلب', 'en': 'Aleppo'},
  }).toEntity();
  final worker = WorkerModel.fromJson(StagingFixtures.worker);

  late _Workers workers;
  late _Cities cities;
  late CitySelection selection;

  setUp(() {
    workers = _Workers();
    cities = _Cities();
    selection = CitySelection();
    when(() => cities.getCities(any())).thenAnswer((_) async => Ok<List<City>>([aleppo, damascus]));
  });

  Paged<Worker> page(List<Worker> items, {int page = 1, int totalPages = 1}) => Paged(
    items: items,
    meta: PageMeta(page: page, limit: 20, total: items.length * totalPages, totalPages: totalPages),
  );

  BrowseWorkersBloc build() => BrowseWorkersBloc(workers, cities, selection);

  Future<BrowseWorkersState> settle(BrowseWorkersBloc bloc) async {
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    return bloc.state;
  }

  const start = BrowseStarted(
    countryId: 'sy',
    serviceId: StagingFixtures.cleaningId,
    homeCityId: StagingFixtures.damascusId,
  );

  test('uses her home city, not just the first city in the list', () async {
    when(() => workers.browse(any(), page: any(named: 'page'))).thenAnswer((_) async => Ok(page([worker])));
    final bloc = build()..add(start);
    final state = await settle(bloc);
    expect(state.status, BrowseStatus.loaded);
    expect(state.query!.cityId, StagingFixtures.damascusId);
    expect(state.workers, [worker]);
    expect(selection.cityId, StagingFixtures.damascusId);
  });

  test('an empty city is a normal loaded state, not an error', () async {
    when(() => workers.browse(any(), page: any(named: 'page'))).thenAnswer((_) async => Ok(page([])));
    final state = await settle(build()..add(start));
    expect(state.status, BrowseStatus.loaded);
    expect(state.workers, isEmpty);
  });

  test('changing city or sort re-queries from page 1 with the new filter', () async {
    when(() => workers.browse(any(), page: any(named: 'page'))).thenAnswer((_) async => Ok(page([worker])));
    final bloc = build()..add(start);
    await settle(bloc);
    bloc.add(const BrowseQueryChanged(cityId: StagingFixtures.aleppoId, sort: WorkerSort.priceAsc));
    final state = await settle(bloc);
    final sent = verify(() => workers.browse(captureAny())).captured.last as WorkerQuery;
    expect(sent.cityId, StagingFixtures.aleppoId);
    expect(sent.sort, WorkerSort.priceAsc);
    expect(state.query, sent);
  });

  test('next page appends, using meta to know when to stop', () async {
    final other = WorkerModel.fromJson({...StagingFixtures.worker, 'id': 'w2'});
    when(() => workers.browse(any())).thenAnswer((_) async => Ok(page([worker], totalPages: 2)));
    when(() => workers.browse(any(), page: 2)).thenAnswer((_) async => Ok(page([other], page: 2, totalPages: 2)));
    final bloc = build()..add(start);
    await settle(bloc);
    bloc.add(const BrowseNextPageRequested());
    var state = await settle(bloc);
    expect(state.workers.map((w) => w.id), [worker.id, 'w2']);
    bloc.add(const BrowseNextPageRequested());
    state = await settle(bloc);
    verifyNever(() => workers.browse(any(), page: 3));
  });

  test('a failing page keeps the list she is already looking at', () async {
    when(() => workers.browse(any())).thenAnswer((_) async => Ok(page([worker], totalPages: 2)));
    when(() => workers.browse(any(), page: 2)).thenAnswer((_) async => const Err(NetworkFailure()));
    final bloc = build()..add(start);
    await settle(bloc);
    bloc.add(const BrowseNextPageRequested());
    final state = await settle(bloc);
    expect(state.workers, [worker]);
    expect(state.status, BrowseStatus.loaded);
    expect(state.loadingMore, isFalse);
  });
}
