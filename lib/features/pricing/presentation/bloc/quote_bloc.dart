import 'package:baytna_customer/core/error/failure.dart';
import 'package:baytna_customer/core/utils/result.dart';
import 'package:baytna_customer/features/pricing/domain/job_size.dart';
import 'package:baytna_customer/features/pricing/domain/pricing_repository.dart';
import 'package:baytna_customer/features/pricing/domain/quote.dart';
import 'package:baytna_customer/features/services/domain/entities/service.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'quote_event.dart';
part 'quote_state.dart';

/// Live price preview for one offering. Every number shown comes from
/// GET /pricing/quote; the app never computes a price itself.
@injectable
class QuoteBloc extends Bloc<QuoteEvent, QuoteState> {
  QuoteBloc(this._pricing) : super(const QuoteState()) {
    on<QuoteStarted>(_onStarted);
    // Tapping + three times sends three requests; only the last answer counts.
    on<QuoteSizeChanged>(_onSizeChanged, transformer: restartable());
    on<QuoteDurationChanged>(_onDurationChanged);
  }

  final PricingRepository _pricing;

  static const defaultRooms = 2;
  static const maxRooms = 12;

  Future<void> _onStarted(QuoteStarted event, Emitter<QuoteState> emit) async {
    emit(QuoteState(workerServiceId: event.workerServiceId, pricingType: event.pricingType));
    switch (event.pricingType) {
      case PricingType.hourly:
        // No hours → the server answers for her minimum. That IS minHours.
        final result = await _pricing.quote(event.workerServiceId);
        switch (result) {
          case Ok(:final value):
            final min = value.hours ?? 1;
            emit(state.copyWith(status: QuoteStatus.ready, quote: value, minHours: min, hours: min));
          case Err(:final failure):
            emit(state.copyWith(status: QuoteStatus.failure, failure: failure));
        }
      case PricingType.bySize:
        await _fetch(emit, rooms: defaultRooms);
      case PricingType.fixed || PricingType.unknown:
        await _fetch(emit);
    }
  }

  Future<void> _onSizeChanged(QuoteSizeChanged event, Emitter<QuoteState> emit) async {
    if (state.workerServiceId == null) return;
    switch (state.pricingType) {
      case PricingType.hourly:
        final hours = DurationSteps.clamp(event.hours ?? state.hours, min: state.minHours ?? DurationSteps.step);
        await _fetch(emit, hours: hours);
      case PricingType.bySize:
        await _fetch(emit, rooms: (event.rooms ?? state.rooms).clamp(1, maxRooms));
      case PricingType.fixed || PricingType.unknown:
        return;
    }
  }

  void _onDurationChanged(QuoteDurationChanged event, Emitter<QuoteState> emit) =>
      emit(state.copyWith(durationHours: DurationSteps.clamp(event.hours)));

  Future<void> _fetch(Emitter<QuoteState> emit, {num? hours, int? rooms}) async {
    emit(state.copyWith(quoting: true, hours: hours, rooms: rooms));
    final result = await _pricing.quote(state.workerServiceId!, hours: hours, roomCount: rooms);
    switch (result) {
      case Ok(:final value):
        emit(state.copyWith(
          status: QuoteStatus.ready,
          quote: value,
          quoting: false,
          // Trust the server's effective hours over what was asked for.
          hours: value.hours ?? hours,
        ));
      case Err(:final failure):
        emit(state.copyWith(status: QuoteStatus.failure, failure: failure, quoting: false));
    }
  }
}
