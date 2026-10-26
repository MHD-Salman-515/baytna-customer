part of 'booking_flow_bloc.dart';

sealed class BookingFlowEvent extends Equatable {
  const BookingFlowEvent();

  @override
  List<Object?> get props => [];
}

/// The size she chose on the price preview comes along: [hours] (HOURLY),
/// [rooms] (BY_SIZE) and the expected [durationMinutes] (BY_SIZE / FIXED).
final class FlowStarted extends BookingFlowEvent {
  const FlowStarted({
    required this.workerId,
    required this.serviceId,
    required this.cityId,
    required this.countryId,
    this.hours,
    this.rooms,
    this.durationMinutes,
  });

  final String workerId;
  final String serviceId;
  final String cityId;
  final String countryId;
  final num? hours;
  final int? rooms;
  final int? durationMinutes;

  @override
  List<Object?> get props => [workerId, serviceId, cityId, countryId, hours, rooms, durationMinutes];
}

final class FlowDaySelected extends BookingFlowEvent {
  const FlowDaySelected(this.daysFromToday);

  final int daysFromToday;

  @override
  List<Object?> get props => [daysFromToday];
}

final class FlowStartSelected extends BookingFlowEvent {
  const FlowStartSelected(this.start);

  final DateTime start;

  @override
  List<Object?> get props => [start];
}

final class FlowStepRequested extends BookingFlowEvent {
  const FlowStepRequested(this.step);

  final FlowStep step;

  @override
  List<Object?> get props => [step];
}

final class FlowPinMoved extends BookingFlowEvent {
  const FlowPinMoved(this.point);

  final GeoPoint point;

  @override
  List<Object?> get props => [point];
}

final class FlowLocateRequested extends BookingFlowEvent {
  const FlowLocateRequested();
}

final class FlowAddressSubmitted extends BookingFlowEvent {
  const FlowAddressSubmitted({required this.landmark, required this.text, this.floor = '', this.notes = ''});

  final String landmark;
  final String text;
  final String floor;
  final String notes;

  @override
  List<Object?> get props => [landmark, text, floor, notes];
}

final class FlowSubmitted extends BookingFlowEvent {
  const FlowSubmitted();
}
