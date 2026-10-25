import 'package:baytna_customer/core/config/app_config.dart';
import 'package:baytna_customer/core/network/dio_factory.dart';
import 'package:baytna_customer/core/network/server_status.dart';
import 'package:baytna_customer/core/network/token_refresher.dart';
import 'package:baytna_customer/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  @Named(refreshDioName)
  Dio refreshDio(AppConfig config, ServerStatus status) =>
      DioFactory.createRefreshDio(config, status);

  @lazySingleton
  Dio apiDio(
    AppConfig config,
    ServerStatus status,
    TokenStorage storage,
    TokenRefresher refresher,
  ) => DioFactory.createApiDio(
    config: config,
    status: status,
    storage: storage,
    refresher: refresher,
  );
}
