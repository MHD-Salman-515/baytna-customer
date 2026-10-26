import 'package:baytna_customer/core/error/failure.dart';
import 'package:baytna_customer/core/network/paged.dart';
import 'package:baytna_customer/core/utils/result.dart';
import 'package:baytna_customer/features/cities/domain/city_selection.dart';
import 'package:baytna_customer/features/cities/domain/entities/city.dart';
import 'package:baytna_customer/features/cities/domain/repositories/city_repository.dart';
import 'package:baytna_customer/features/workers/domain/entities/worker.dart';
import 'package:baytna_customer/features/workers/domain/entities/worker_query.dart';
import 'package:baytna_customer/features/workers/domain/repositories/worker_repository.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'browse_workers_event.dart';
part 'browse_workers_state.dart';

@injectable
class BrowseWorkersBloc extends Bloc<BrowseWorkersEvent, BrowseWorkersState> {
  BrowseWorkersBloc(this._workers, this._cities, this._selection) : super(const BrowseWorkersState()) {
    on<BrowseStarted>(_onStarted);
    // A newer filter wins: an in-flight page for the old filter is dropped.
    on<BrowseQueryChanged>(_onQueryChanged, transformer: restartable());
    on<BrowseNextPageRequested>(_onNextPage, transformer: droppable());
  }

  final WorkerRepository _workers;
  final CityRepository _cities;
  final CitySelection _selection;

  Future<void> _onStarted(BrowseStarted event, Emitter<BrowseWorkersState> emit) async {
    emit(state.copyWith(status: BrowseStatus.loading));
    switch (await _cities.getCities(event.countryId)) {
      case Err(:final failure):
        emit(state.copyWith(status: BrowseStatus.failure, failure: failure));
      case Ok(value: final cities):
        if (cities.isEmpty) {
          emit(state.copyWith(status: BrowseStatus.loaded, cities: cities, workers: const []));
          return;
        }
        final known = {for (final c in cities) c.id};
        final cityId = [event.cityId, _selection.cityId, event.homeCityId]
                .firstWhere((id) => id != null && known.contains(id), orElse: () => null) ??
            cities.first.id;
        final query = WorkerQuery(cityId: cityId, serviceId: event.serviceId);
        emit(state.copyWith(cities: cities));
        await _load(query, emit);
    }
  }

  Future<void> _onQueryChanged(BrowseQueryChanged event, Emitter<BrowseWorkersState> emit) async {
    final current = state.query;
    if (current == null) return;
    await _load(current.copyWith(cityId: event.cityId, sort: event.sort), emit);
  }

  Future<void> _load(WorkerQuery query, Emitter<BrowseWorkersState> emit) async {
    _selection.cityId = query.cityId;
    emit(state.copyWith(status: BrowseStatus.loading, query: query, workers: const []));
    switch (await _workers.browse(query)) {
      case Ok(:final value):
        emit(state.copyWith(status: BrowseStatus.loaded, workers: value.items, meta: value.meta));
      case Err(:final failure):
        emit(state.copyWith(status: BrowseStatus.failure, failure: failure));
    }
  }

  Future<void> _onNextPage(BrowseNextPageRequested event, Emitter<BrowseWorkersState> emit) async {
    final query = state.query;
    final meta = state.meta;
    if (query == null || meta == null || !meta.hasNext || state.status != BrowseStatus.loaded) return;
    emit(state.copyWith(loadingMore: true));
    final result = await _workers.browse(query, page: meta.page + 1);
    if (state.query != query) return; // filter changed meanwhile
    switch (result) {
      case Ok(:final value):
        emit(state.copyWith(
          workers: [...state.workers, ...value.items],
          meta: value.meta,
          loadingMore: false,
        ));
      case Err():
        // Keep what she's already looking at; scrolling again retries.
        emit(state.copyWith(loadingMore: false));
    }
  }
}
