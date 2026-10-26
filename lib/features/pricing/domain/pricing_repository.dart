import 'package:baytna_customer/core/utils/result.dart';
import 'package:baytna_customer/features/pricing/domain/quote.dart';

abstract interface class PricingRepository {
  Future<Result<Quote>> quote(String workerServiceId, {num? hours, int? roomCount});
}
