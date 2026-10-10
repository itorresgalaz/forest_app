import 'package:dio/dio.dart';

import 'app_exception.dart';

class DioExceptionMapper {
  const DioExceptionMapper._();

  static AppException map(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
      case DioExceptionType.transformTimeout:
        return NetworkException(cause: error);

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;

        if (statusCode == 404) {
          return NotFoundException(cause: error);
        }

        return ServerException(
          statusCode: statusCode,
          cause: error,
        );

      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return ServerException(
          message: 'Unexpected request error.',
          cause: error,
        );
    }
  }
}