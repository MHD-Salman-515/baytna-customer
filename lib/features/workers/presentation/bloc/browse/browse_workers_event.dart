part of 'browse_workers_bloc.dart';

sealed class BrowseWorkersEvent extends Equatable {
  const BrowseWorkersEvent();

  @override
  List<Object?> get props => [];
}

/// [cityId] from the URL wins, then her last choice, then her home city,
/// then the first city of her country.
final class BrowseStarted extends BrowseWorkersEvent {
  const BrowseStarted({required this.countryId, required this.serviceId, this.cityId, this.homeCityId});

  final String countryId;
  final String serviceId;
  final String? cityId;
  final String? homeCityId;

  @override
  List<Object?> get props => [countryId, serviceId, cityId, homeCityId];
}

final class BrowseQueryChanged extends BrowseWorkersEvent {
  const BrowseQueryChanged({this.cityId, this.sort});

  final String? cityId;
  final WorkerSort? sort;

  @override
  List<Object?> get props => [cityId, sort];
}

final class BrowseNextPageRequested extends BrowseWorkersEvent {
  const BrowseNextPageRequested();
}
