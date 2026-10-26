import 'package:baytna_customer/core/utils/result.dart';
import 'package:baytna_customer/features/services/data/datasources/service_remote_data_source.dart';
import 'package:baytna_customer/features/services/domain/entities/service.dart';
import 'package:baytna_customer/features/services/domain/repositories/service_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ServiceRepository)
class ServiceRepositoryImpl implements ServiceRepository {
  ServiceRepositoryImpl(this._remote);

  final ServiceRemoteDataSource _remote;
  List<Service>? _cache;

  @override
  Future<Result<List<Service>>> getServices({bool forceRefresh = false}) async {
    final cached = _cache;
    if (cached != null && !forceRefresh) return Ok(cached);
    final result = await guard(() async {
      final models = await _remote.fetchActive();
      final services = models.map((m) => m.toEntity()).toList()
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      return List<Service>.unmodifiable(services);
    });
    if (result case Ok(:final value)) _cache = value;
    return result;
  }
}
