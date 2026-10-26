part of 'worker_detail_bloc.dart';

sealed class WorkerDetailState extends Equatable {
  const WorkerDetailState();

  @override
  List<Object?> get props => [];
}

final class WorkerDetailLoading extends WorkerDetailState {
  const WorkerDetailLoading();
}

final class WorkerDetailLoaded extends WorkerDetailState {
  const WorkerDetailLoaded({required this.worker, required this.cities});

  final Worker worker;
  final Map<String, City> cities;

  @override
  List<Object?> get props => [worker, cities];
}

/// A 404 here usually means she stopped being bookable since the list loaded.
final class WorkerDetailFailure extends WorkerDetailState {
  const WorkerDetailFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
