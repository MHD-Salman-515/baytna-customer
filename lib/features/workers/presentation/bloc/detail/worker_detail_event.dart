part of 'worker_detail_bloc.dart';

sealed class WorkerDetailEvent extends Equatable {
  const WorkerDetailEvent();

  @override
  List<Object?> get props => [];
}

final class WorkerDetailRequested extends WorkerDetailEvent {
  const WorkerDetailRequested({required this.workerId, required this.countryId});

  final String workerId;

  /// The customer's country, to name the cities she works in.
  final String countryId;

  @override
  List<Object?> get props => [workerId, countryId];
}
