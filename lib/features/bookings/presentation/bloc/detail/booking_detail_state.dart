part of 'booking_detail_bloc.dart';

enum DetailStatus { loading, loaded, failure }

final class BookingDetailState extends Equatable {
  const BookingDetailState({
    this.status = DetailStatus.loading,
    this.booking,
    this.country,
    this.service,
    this.worker,
    this.failure,
    this.cancelling = false,
    this.cancelFailure,
  });

  final DetailStatus status;
  final Booking? booking;
  final Country? country;
  final Service? service;

  /// Her public profile, if she's still listed; only used for her name.
  final Worker? worker;
  final Failure? failure;
  final bool cancelling;
  final Failure? cancelFailure;

  BookingDetailState copyWith({
    DetailStatus? status,
    Booking? booking,
    Country? country,
    Service? service,
    Worker? worker,
    Failure? failure,
    bool? cancelling,
    Failure? cancelFailure,
    bool clearCancelFailure = false,
  }) => BookingDetailState(
    status: status ?? this.status,
    booking: booking ?? this.booking,
    country: country ?? this.country,
    service: service ?? this.service,
    worker: worker ?? this.worker,
    failure: failure ?? this.failure,
    cancelling: cancelling ?? this.cancelling,
    cancelFailure: clearCancelFailure ? null : (cancelFailure ?? this.cancelFailure),
  );

  @override
  List<Object?> get props => [status, booking, country, service, worker, failure, cancelling, cancelFailure];
}
