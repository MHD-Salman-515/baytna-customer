part of 'quote_bloc.dart';

sealed class QuoteEvent extends Equatable {
  const QuoteEvent();

  @override
  List<Object?> get props => [];
}

final class QuoteStarted extends QuoteEvent {
  const QuoteStarted({required this.workerServiceId, required this.pricingType});

  final String workerServiceId;
  final PricingType pricingType;

  @override
  List<Object?> get props => [workerServiceId, pricingType];
}

/// Billed hours (HOURLY) or rooms (BY_SIZE): re-quotes.
final class QuoteSizeChanged extends QuoteEvent {
  const QuoteSizeChanged({this.hours, this.rooms});

  final num? hours;
  final int? rooms;

  @override
  List<Object?> get props => [hours, rooms];
}

/// How long a BY_SIZE / FIXED job will take. Scheduling only: no re-quote.
final class QuoteDurationChanged extends QuoteEvent {
  const QuoteDurationChanged(this.hours);

  final num hours;

  @override
  List<Object?> get props => [hours];
}
