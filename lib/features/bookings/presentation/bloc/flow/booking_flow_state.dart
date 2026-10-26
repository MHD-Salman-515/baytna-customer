part of 'booking_flow_bloc.dart';

enum SetupStatus { loading, ready, failure }

enum SlotsStatus { loading, ready, failure }

enum FlowStep { time, address, review }

final class BookingFlowState extends Equatable {
  const BookingFlowState({
    this.setup = SetupStatus.loading,
    this.failure,
    this.worker,
    this.offering,
    this.country,
    this.city,
    this.size,
    this.step = FlowStep.time,
    this.day = 0,
    this.slots = SlotsStatus.loading,
    this.startTimes = const [],
    this.start,
    this.pin,
    this.pinFromGps = false,
    this.gpsTooFar = false,
    this.locating = false,
    this.locationTried = false,
    this.address,
    this.quote,
    this.submitting = false,
    this.submitFailure,
    this.created,
  });

  final SetupStatus setup;

  /// Setup or slot-loading failure.
  final Failure? failure;
  final Worker? worker;
  final WorkerOffering? offering;
  final Country? country;
  final City? city;
  final JobSize? size;
  final FlowStep step;

  /// Country calendar days after today.
  final int day;
  final SlotsStatus slots;
  final List<DateTime> startTimes;
  final DateTime? start;

  /// Where the pin is. Starts at the city centre; moves to her GPS fix if
  /// allowed and plausible; then wherever she drags it.
  final GeoPoint? pin;
  final bool pinFromGps;

  /// Her GPS fix was far from the booking city, so it was not used.
  final bool gpsTooFar;
  final bool locating;
  final bool locationTried;
  final BookingAddress? address;
  final Quote? quote;
  final bool submitting;
  final Failure? submitFailure;
  final Booking? created;

  CountryTime? get time => country == null ? null : CountryTime(country!.timezone);

  BookingFlowState copyWith({
    SetupStatus? setup,
    Failure? failure,
    Worker? worker,
    WorkerOffering? offering,
    Country? country,
    City? city,
    JobSize? size,
    FlowStep? step,
    int? day,
    SlotsStatus? slots,
    List<DateTime>? startTimes,
    DateTime? start,
    bool clearStart = false,
    GeoPoint? pin,
    bool? pinFromGps,
    bool? gpsTooFar,
    bool? locating,
    bool? locationTried,
    BookingAddress? address,
    Quote? quote,
    bool clearQuote = false,
    bool? submitting,
    Failure? submitFailure,
    bool clearSubmitFailure = false,
    Booking? created,
  }) => BookingFlowState(
    setup: setup ?? this.setup,
    failure: failure ?? this.failure,
    worker: worker ?? this.worker,
    offering: offering ?? this.offering,
    country: country ?? this.country,
    city: city ?? this.city,
    size: size ?? this.size,
    step: step ?? this.step,
    day: day ?? this.day,
    slots: slots ?? this.slots,
    startTimes: startTimes ?? this.startTimes,
    start: clearStart ? null : (start ?? this.start),
    pin: pin ?? this.pin,
    pinFromGps: pinFromGps ?? this.pinFromGps,
    gpsTooFar: gpsTooFar ?? this.gpsTooFar,
    locating: locating ?? this.locating,
    locationTried: locationTried ?? this.locationTried,
    address: address ?? this.address,
    quote: clearQuote ? null : (quote ?? this.quote),
    submitting: submitting ?? this.submitting,
    submitFailure: clearSubmitFailure ? null : (submitFailure ?? this.submitFailure),
    created: created ?? this.created,
  );

  @override
  List<Object?> get props => [
    setup,
    failure,
    worker,
    offering,
    country,
    city,
    size,
    step,
    day,
    slots,
    startTimes,
    start,
    pin,
    pinFromGps,
    gpsTooFar,
    locating,
    locationTried,
    address,
    quote,
    submitting,
    submitFailure,
    created,
  ];
}
