import 'package:baytna_customer/core/network/api_client.dart';
import 'package:baytna_customer/core/network/json.dart';
import 'package:baytna_customer/features/pricing/domain/quote.dart';
import 'package:baytna_customer/features/services/domain/entities/service.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class PricingRemoteDataSource {
  PricingRemoteDataSource(this._api);

  final ApiClient _api;

  /// [hours] for HOURLY only (omit to get her minimum); [roomCount] for BY_SIZE.
  Future<Quote> quote(String workerServiceId, {num? hours, int? roomCount}) => _api.get(
    '/pricing/quote',
    query: {
      'workerServiceId': workerServiceId,
      'estimatedHours': ?hours,
      'roomCount': ?roomCount,
    },
    decode: (data) {
      final j = asJson(data);
      return Quote(
        price: j['price'] as num,
        currency: j['currency'] as String,
        pricingType: PricingType.parse(j['pricingType']),
        hours: j['hours'] as num?,
        roomCount: (j['roomCount'] as num?)?.toInt(),
      );
    },
  );
}
