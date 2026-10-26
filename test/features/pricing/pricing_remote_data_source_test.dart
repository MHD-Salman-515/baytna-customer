import 'package:baytna_customer/core/config/app_config.dart';
import 'package:baytna_customer/core/network/api_client.dart';
import 'package:baytna_customer/core/network/dio_factory.dart';
import 'package:baytna_customer/core/network/server_status.dart';
import 'package:baytna_customer/core/network/session_events.dart';
import 'package:baytna_customer/core/network/token_refresher.dart';
import 'package:baytna_customer/core/storage/token_storage.dart';
import 'package:baytna_customer/features/pricing/data/pricing_remote_data_source.dart';
import 'package:baytna_customer/features/services/domain/entities/service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_backend.dart';
import '../../helpers/in_memory_token_storage.dart';

void main() {
  test('sends only what is set, and decodes the real staging quote', () async {
    final backend = FakeBackend({
      // Verbatim staging answer for estimatedHours=1 with minHours 2.
      'GET /api/v1/pricing/quote': (_, _) async => FakeBackend.ok({
        'price': 12000,
        'currency': 'SYP',
        'pricingType': 'HOURLY',
        'hours': 2,
      }),
    });
    const config = AppConfig(environment: AppEnvironment.staging, apiBaseUrl: 'https://api.test/api/v1');
    final status = ServerStatus();
    final storage = InMemoryTokenStorage(const AuthTokens(accessToken: 'a', refreshToken: 'r'));
    final refresher = TokenRefresher(storage, DioFactory.createRefreshDio(config, status), SessionEvents());
    final dio = DioFactory.createApiDio(config: config, status: status, storage: storage, refresher: refresher)
      ..httpClientAdapter = backend;
    final source = PricingRemoteDataSource(ApiClient(dio));

    final quote = await source.quote('ws1', hours: 1);
    expect(backend.requests.last.queryParameters, {'workerServiceId': 'ws1', 'estimatedHours': 1});
    expect(quote.hours, 2);
    expect(quote.price, 12000);
    expect(quote.pricingType, PricingType.hourly);

    await source.quote('ws1');
    expect(backend.requests.last.queryParameters, {'workerServiceId': 'ws1'});
  });
}
