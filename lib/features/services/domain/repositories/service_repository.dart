import 'package:baytna_customer/core/utils/result.dart';
import 'package:baytna_customer/features/services/domain/entities/service.dart';

abstract interface class ServiceRepository {
  /// Active services in display order; cached in memory after a successful load.
  Future<Result<List<Service>>> getServices({bool forceRefresh = false});
}
