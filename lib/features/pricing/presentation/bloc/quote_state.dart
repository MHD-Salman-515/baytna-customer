part of 'quote_bloc.dart';

enum QuoteStatus { loading, ready, failure }

final class QuoteState extends Equatable {
  const QuoteState({
    this.status = QuoteStatus.loading,
    this.workerServiceId,
    this.pricingType = PricingType.unknown,
    this.quote,
    this.quoting = false,
    this.minHours,
    this.hours = DurationSteps.defaultHours,
    this.rooms = QuoteBloc.defaultRooms,
    this.durationHours = DurationSteps.defaultHours,
    this.failure,
  });

  final QuoteStatus status;
  final String? workerServiceId;
  final PricingType pricingType;
  final Quote? quote;

  /// A request is in flight; the last price stays visible but dimmed.
  final bool quoting;

  /// HOURLY only: her minimum, as enforced by the server.
  final num? minHours;
  final num hours;
  final int rooms;

  /// BY_SIZE / FIXED: expected job length, for scheduling.
  final num durationHours;
  final Failure? failure;

  bool get canContinue => status == QuoteStatus.ready && quote != null && !quoting;

  JobSize get jobSize => switch (pricingType) {
    PricingType.hourly => JobSize(
      pricingType: pricingType,
      hours: hours,
      durationMinutes: DurationSteps.minutes(hours),
    ),
    PricingType.bySize => JobSize(
      pricingType: pricingType,
      roomCount: rooms,
      durationMinutes: DurationSteps.minutes(durationHours),
    ),
    PricingType.fixed || PricingType.unknown => JobSize(
      pricingType: pricingType,
      durationMinutes: DurationSteps.minutes(durationHours),
    ),
  };

  QuoteState copyWith({
    QuoteStatus? status,
    Quote? quote,
    bool? quoting,
    num? minHours,
    num? hours,
    int? rooms,
    num? durationHours,
    Failure? failure,
  }) => QuoteState(
    status: status ?? this.status,
    workerServiceId: workerServiceId,
    pricingType: pricingType,
    quote: quote ?? this.quote,
    quoting: quoting ?? this.quoting,
    minHours: minHours ?? this.minHours,
    hours: hours ?? this.hours,
    rooms: rooms ?? this.rooms,
    durationHours: durationHours ?? this.durationHours,
    failure: status == QuoteStatus.failure ? failure : null,
  );

  @override
  List<Object?> get props => [
    status,
    workerServiceId,
    pricingType,
    quote,
    quoting,
    minHours,
    hours,
    rooms,
    durationHours,
    failure,
  ];
}
