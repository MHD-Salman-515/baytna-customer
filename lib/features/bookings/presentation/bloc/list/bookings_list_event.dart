part of 'bookings_list_bloc.dart';

sealed class BookingsListEvent extends Equatable {
  const BookingsListEvent();

  @override
  List<Object?> get props => [];
}

/// Null [status] = all of them.
final class BookingsRequested extends BookingsListEvent {
  const BookingsRequested({this.status});

  final BookingStatus? status;

  @override
  List<Object?> get props => [status];
}

final class BookingsNextPageRequested extends BookingsListEvent {
  const BookingsNextPageRequested();
}
