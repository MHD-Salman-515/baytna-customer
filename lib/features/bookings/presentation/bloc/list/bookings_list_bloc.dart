import 'package:baytna_customer/core/error/failure.dart';
import 'package:baytna_customer/core/network/paged.dart';
import 'package:baytna_customer/core/utils/result.dart';
import 'package:baytna_customer/features/bookings/domain/booking_repository.dart';
import 'package:baytna_customer/features/bookings/domain/entities/booking.dart';
import 'package:baytna_customer/features/countries/domain/entities/country.dart';
import 'package:baytna_customer/features/countries/domain/repositories/country_repository.dart';
import 'package:baytna_customer/features/services/domain/entities/service.dart';
import 'package:baytna_customer/features/services/domain/repositories/service_repository.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'bookings_list_event.dart';
part 'bookings_list_state.dart';

@injectable
class BookingsListBloc extends Bloc<BookingsListEvent, BookingsListState> {
  BookingsListBloc(this._bookings, this._services, this._countries) : super(const BookingsListState()) {
    on<BookingsRequested>(_onRequested, transformer: restartable());
    on<BookingsNextPageRequested>(_onNextPage, transformer: droppable());
  }

  final BookingRepository _bookings;
  final ServiceRepository _services;
  final CountryRepository _countries;

  Future<void> _onRequested(BookingsRequested e, Emitter<BookingsListState> emit) async {
    emit(BookingsListState(filter: e.status, services: state.services, countries: state.countries));
    // Names for services and the country clock are niceties: load them
    // alongside, never fail the list over them.
    final (page, services, countries) = (
      await _bookings.list(status: e.status),
      await _services.getServices(),
      await _countries.getCountries(),
    );
    final serviceMap = switch (services) {
      Ok(:final value) => {for (final s in value) s.id: s},
      Err() => state.services,
    };
    final countryMap = switch (countries) {
      Ok(:final value) => {for (final c in value) c.id: c},
      Err() => state.countries,
    };
    emit(switch (page) {
      Ok(:final value) => state.copyWith(
        status: ListStatus.loaded,
        items: value.items,
        meta: value.meta,
        services: serviceMap,
        countries: countryMap,
      ),
      Err(:final failure) => state.copyWith(status: ListStatus.failure, failure: failure),
    });
  }

  Future<void> _onNextPage(BookingsNextPageRequested e, Emitter<BookingsListState> emit) async {
    final meta = state.meta;
    if (meta == null || !meta.hasNext || state.status != ListStatus.loaded) return;
    final filter = state.filter;
    emit(state.copyWith(loadingMore: true));
    final result = await _bookings.list(status: filter, page: meta.page + 1);
    if (state.filter != filter) return;
    emit(switch (result) {
      Ok(:final value) => state.copyWith(items: [...state.items, ...value.items], meta: value.meta, loadingMore: false),
      Err() => state.copyWith(loadingMore: false),
    });
  }
}
