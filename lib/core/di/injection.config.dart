// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:baytna_customer/core/config/app_config.dart' as _i1002;
import 'package:baytna_customer/core/di/app_module.dart' as _i447;
import 'package:baytna_customer/core/localization/locale_cubit.dart' as _i30;
import 'package:baytna_customer/core/network/api_client.dart' as _i36;
import 'package:baytna_customer/core/network/network_module.dart' as _i979;
import 'package:baytna_customer/core/network/server_status.dart' as _i698;
import 'package:baytna_customer/core/network/session_events.dart' as _i809;
import 'package:baytna_customer/core/network/token_refresher.dart' as _i293;
import 'package:baytna_customer/core/storage/secure_token_storage.dart'
    as _i231;
import 'package:baytna_customer/core/storage/storage_module.dart' as _i765;
import 'package:baytna_customer/core/storage/token_storage.dart' as _i372;
import 'package:baytna_customer/features/auth/data/datasources/auth_local_data_source.dart'
    as _i784;
import 'package:baytna_customer/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i234;
import 'package:baytna_customer/features/auth/data/repositories/auth_repository_impl.dart'
    as _i878;
import 'package:baytna_customer/features/auth/domain/repositories/auth_repository.dart'
    as _i244;
import 'package:baytna_customer/features/auth/presentation/bloc/auth/auth_bloc.dart'
    as _i390;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    final storageModule = _$StorageModule();
    final networkModule = _$NetworkModule();
    gh.singleton<_i1002.AppConfig>(() => appModule.config);
    gh.lazySingleton<_i698.ServerStatus>(() => _i698.ServerStatus());
    gh.lazySingleton<_i809.SessionEvents>(
      () => _i809.SessionEvents(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => storageModule.secureStorage,
    );
    gh.lazySingleton<_i30.LocaleCubit>(
      () => _i30.LocaleCubit(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i784.AuthLocalDataSource>(
      () => _i784.AuthLocalDataSource(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i372.TokenStorage>(
      () => _i231.SecureTokenStorage(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.refreshDio(
        gh<_i1002.AppConfig>(),
        gh<_i698.ServerStatus>(),
      ),
      instanceName: 'refreshDio',
    );
    gh.lazySingleton<_i293.TokenRefresher>(
      () => _i293.TokenRefresher(
        gh<_i372.TokenStorage>(),
        gh<_i361.Dio>(instanceName: 'refreshDio'),
        gh<_i809.SessionEvents>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.apiDio(
        gh<_i1002.AppConfig>(),
        gh<_i698.ServerStatus>(),
        gh<_i372.TokenStorage>(),
        gh<_i293.TokenRefresher>(),
        gh<_i30.LocaleCubit>(),
      ),
    );
    gh.lazySingleton<_i36.ApiClient>(() => _i36.ApiClient(gh<_i361.Dio>()));
    gh.lazySingleton<_i234.AuthRemoteDataSource>(
      () => _i234.AuthRemoteDataSource(gh<_i36.ApiClient>()),
    );
    gh.lazySingleton<_i244.AuthRepository>(
      () => _i878.AuthRepositoryImpl(
        gh<_i234.AuthRemoteDataSource>(),
        gh<_i784.AuthLocalDataSource>(),
        gh<_i372.TokenStorage>(),
      ),
    );
    gh.lazySingleton<_i390.AuthBloc>(
      () => _i390.AuthBloc(
        gh<_i244.AuthRepository>(),
        gh<_i30.LocaleCubit>(),
        gh<_i809.SessionEvents>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i447.AppModule {}

class _$StorageModule extends _i765.StorageModule {}

class _$NetworkModule extends _i979.NetworkModule {}
