part of 'bookings_list_bloc.dart';

enum ListStatus { loading, loaded, failure }

final class BookingsListState extends Equatable {
  const BookingsListState({
    this.status = ListStatus.loading,
    this.filter,
    this.items = const [],
    this.meta,
    this.loadingMore = false,
    this.failure,
    this.services = const {},
    this.countries = const {},
  });

  final ListStatus status;
  final BookingStatus? filter;
  final List<Booking> items;
  final PageMeta? meta;
  final bool loadingMore;
  final Failure? failure;
  final Map<String, Service> services;
  final Map<String, Country> countries;

  BookingsListState copyWith({
    ListStatus? status,
    List<Booking>? items,
    PageMeta? meta,
    bool? loadingMore,
    Failure? failure,
    Map<String, Service>? services,
    Map<String, Country>? countries,
  }) => BookingsListState(
    status: status ?? this.status,
    filter: filter,
    items: items ?? this.items,
    meta: meta ?? this.meta,
    loadingMore: loadingMore ?? this.loadingMore,
    failure: failure ?? this.failure,
    services: services ?? this.services,
    countries: countries ?? this.countries,
  );

  @override
  List<Object?> get props => [status, filter, items, meta, loadingMore, failure, services, countries];
}
