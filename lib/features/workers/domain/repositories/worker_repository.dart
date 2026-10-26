import 'package:baytna_customer/core/network/paged.dart';
import 'package:baytna_customer/core/utils/result.dart';
import 'package:baytna_customer/features/workers/domain/entities/free_interval.dart';
import 'package:baytna_customer/features/workers/domain/entities/worker.dart';
import 'package:baytna_customer/features/workers/domain/entities/worker_query.dart';

abstract interface class WorkerRepository {
  /// Only bookable workers come back (APPROVED, available, financially
  /// active): the backend enforces it, the app does not re-check.
  Future<Result<Paged<Worker>>> browse(WorkerQuery query, {int page = 1});

  Future<Result<Worker>> getWorker(String id);

  /// Her free intervals on [date] (`YYYY-MM-DD`, her country's timezone).
  Future<Result<List<FreeInterval>>> getFreeIntervals(String workerId, String date);
}
