// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../data/datasources/brewery_remote_datasource.dart' as _i578;
import '../../data/repositories_impl/brewery_repository_impl.dart' as _i475;
import '../../domain/repositories/brewery_repository.dart' as _i745;
import '../network/api_url.dart' as _i682;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final apiUrl = _$ApiUrl();
    gh.lazySingleton<_i361.Dio>(() => apiUrl.dio);
    gh.lazySingleton<_i578.BreweryRemoteDatasource>(
      () => _i578.BreweryRemoteDatasource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i745.BreweryRepository>(
      () => _i475.BreweryRepositoryImpl(gh<_i578.BreweryRemoteDatasource>()),
    );
    return this;
  }
}

class _$ApiUrl extends _i682.ApiUrl {}
