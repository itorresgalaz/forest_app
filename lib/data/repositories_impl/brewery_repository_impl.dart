
import 'package:dio/dio.dart';
import 'package:forestchallenger/core/errors/app_exception.dart';
import 'package:forestchallenger/data/datasources/brewery_remote_datasource.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/dio_exception.dart';
import '../../domain/entities/brewery.dart';
import '../../domain/repositories/brewery_repository.dart';

@LazySingleton(as: BreweryRepository)
class BreweryRepositoryImpl implements BreweryRepository {
  const BreweryRepositoryImpl(this._remoteDataSource);

  final BreweryRemoteDatasource _remoteDataSource;
  
  @override
  Future<List<Brewery>> getBreweries({
    required int page,
    required int perPage
  }) async {
    try {
      final dtos = await _remoteDataSource.getBreweries(
          page: page,
          perPage: perPage
      );
      return dtos.map((dto)=>dto.toEntity()).toList();
    } on DioException catch (error) {
      throw DioExceptionMapper.map(error);
    } on FormatException catch (error) {
      throw InvalidDataException(cause: error);
    } on TypeError catch (error){
      throw InvalidDataException(cause: error);
    }
  }

  @override
  Future<Brewery> getBrewery(String id) async {
    final dto = await _remoteDataSource.getBrewery(id: id);

    return dto.toEntity();

  }

  @override
  Future<List<Brewery>> searchBreweries({required String query, required int page, required int perPage}) {
    // TODO: implement searchBreweries
    throw UnimplementedError();
  }
  
}