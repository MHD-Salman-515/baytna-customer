import 'package:baytna_customer/core/network/paged.dart';
import 'package:baytna_customer/core/utils/result.dart';
import 'package:baytna_customer/features/workers/data/datasources/worker_remote_data_source.dart';
import 'package:baytna_customer/features/workers/domain/entities/free_interval.dart';
import 'package:baytna_customer/features/workers/domain/entities/worker.dart';
import 'package:baytna_customer/features/workers/domain/entities/worker_query.dart';
import 'package:baytna_customer/features/workers/domain/repositories/worker_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: WorkerRepository)
class WorkerRepositoryImpl implements WorkerRepository {
  WorkerRepositoryImpl(this._remote);

  final WorkerRemoteDataSource _remote;

  @override
  Future<Result<Paged<Worker>>> browse(WorkerQuery query, {int page = 1}) =>
      guard(() => _remote.fetchPage(query, page: page));

  @override
  Future<Result<Worker>> getWorker(String id) => guard(() => _remote.fetchById(id));

  @override
  Future<Result<List<FreeInterval>>> getFreeIntervals(String workerId, String date) =>
      guard(() => _remote.fetchSlots(workerId, date));
}
