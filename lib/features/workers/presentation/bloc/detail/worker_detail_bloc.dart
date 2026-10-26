import 'package:baytna_customer/core/error/failure.dart';
import 'package:baytna_customer/core/utils/result.dart';
import 'package:baytna_customer/features/cities/domain/entities/city.dart';
import 'package:baytna_customer/features/cities/domain/repositories/city_repository.dart';
import 'package:baytna_customer/features/workers/domain/entities/worker.dart';
import 'package:baytna_customer/features/workers/domain/repositories/worker_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'worker_detail_event.dart';
part 'worker_detail_state.dart';

@injectable
class WorkerDetailBloc extends Bloc<WorkerDetailEvent, WorkerDetailState> {
  WorkerDetailBloc(this._workers, this._cities) : super(const WorkerDetailLoading()) {
    on<WorkerDetailRequested>(_onRequested);
  }

  final WorkerRepository _workers;
  final CityRepository _cities;

  Future<void> _onRequested(WorkerDetailRequested event, Emitter<WorkerDetailState> emit) async {
    emit(const WorkerDetailLoading());
    final (worker, cities) = (
      await _workers.getWorker(event.workerId),
      await _cities.getCities(event.countryId),
    );
    switch (worker) {
      case Err(:final failure):
        emit(WorkerDetailFailure(failure));
      case Ok(:final value):
        // City names are a nicety; a failed city load must not hide her profile.
        final byId = switch (cities) {
          Ok(value: final list) => {for (final c in list) c.id: c},
          Err() => const <String, City>{},
        };
        emit(WorkerDetailLoaded(worker: value, cities: byId));
    }
  }
}
