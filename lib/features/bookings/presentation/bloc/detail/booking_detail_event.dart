part of 'booking_detail_bloc.dart';

sealed class BookingDetailEvent extends Equatable {
  const BookingDetailEvent();

  @override
  List<Object?> get props => [];
}

final class BookingDetailRequested extends BookingDetailEvent {
  const BookingDetailRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

final class BookingCancelRequested extends BookingDetailEvent {
  const BookingCancelRequested(this.reason);

  /// Required by the server; must not be empty.
  final String reason;

  @override
  List<Object?> get props => [reason];
}
