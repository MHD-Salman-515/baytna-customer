import 'package:baytna_customer/core/utils/result.dart';
import 'package:baytna_customer/features/pricing/data/pricing_remote_data_source.dart';
import 'package:baytna_customer/features/pricing/domain/pricing_repository.dart';
import 'package:baytna_customer/features/pricing/domain/quote.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: PricingRepository)
class PricingRepositoryImpl implements PricingRepository {
  PricingRepositoryImpl(this._remote);

  final PricingRemoteDataSource _remote;

  @override
  Future<Result<Quote>> quote(String workerServiceId, {num? hours, int? roomCount}) =>
      guard(() => _remote.quote(workerServiceId, hours: hours, roomCount: roomCount));
}
