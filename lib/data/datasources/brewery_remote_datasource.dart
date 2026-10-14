import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/braweryDto.dart';

@lazySingleton
class BreweryRemoteDatasource {
  const BreweryRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<BreweryDto>> getBreweries({
    required int page,
    required int perPage,
  }) async {
    final response = await _dio.get(
      '/breweries',
      queryParameters: {
        'page': page,
        'per_page': perPage
      },
    );

    final List<dynamic> data = (response.data as List?) ?? const [];

    return data.map(
          (json)=> BreweryDto.fromJson(
            json as Map<String,dynamic>,
          ),
    ).toList();
  }




}