import 'dart:async';
import 'dart:convert';

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
    final response = await _dio.get<List<dynamic>>(
      '/breweries',
      queryParameters: {
        'page': page,
        'per_page': perPage
      },
    );

    final data = response.data ?? [];

    if(data == null){
      throw const FormatException(
        'Breweries response is null',
      );
    }

    return data.map(
          (json)=> BreweryDto.fromJson(
            json as Map<String,dynamic>,
          ),
    ).toList();
  }




}