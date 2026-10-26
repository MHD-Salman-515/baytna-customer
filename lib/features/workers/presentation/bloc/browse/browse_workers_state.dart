part of 'browse_workers_bloc.dart';

enum BrowseStatus { loading, loaded, failure }

final class BrowseWorkersState extends Equatable {
  const BrowseWorkersState({
    this.status = BrowseStatus.loading,
    this.cities = const [],
    this.query,
    this.workers = const [],
    this.meta,
    this.loadingMore = false,
    this.failure,
  });

  final BrowseStatus status;
  final List<City> cities;
  final WorkerQuery? query;
  final List<Worker> workers;
  final PageMeta? meta;
  final bool loadingMore;
  final Failure? failure;

  City? get city => cities.where((c) => c.id == query?.cityId).firstOrNull;

  BrowseWorkersState copyWith({
    BrowseStatus? status,
    List<City>? cities,
    WorkerQuery? query,
    List<Worker>? workers,
    PageMeta? meta,
    bool? loadingMore,
    Failure? failure,
  }) => BrowseWorkersState(
    status: status ?? this.status,
    cities: cities ?? this.cities,
    query: query ?? this.query,
    workers: workers ?? this.workers,
    meta: meta ?? this.meta,
    loadingMore: loadingMore ?? this.loadingMore,
    failure: failure ?? (status == BrowseStatus.failure ? this.failure : null),
  );

  @override
  List<Object?> get props => [status, cities, query, workers, meta, loadingMore, failure];
}
