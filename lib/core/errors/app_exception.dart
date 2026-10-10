/// Typed failures thrown by the Data layer (repositories).
///
/// Presentation never sees Dio, HTTP status codes or JSON errors: it only
/// sees these types and decides what to show for each one.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  /// Technical description, meant for logs / diagnostics (not for the user).
  final String message;

  /// The original error, kept for diagnostics (e.g. a future Sentry report).
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

/// No connectivity, timeouts, TLS problems.
final class NetworkException extends AppException {
  const NetworkException({
    String message = 'Could not reach the server.',
    Object? cause,
  }) : super(message, cause: cause);
}

/// The server answered with an unexpected error status (5xx, 4xx other than 404).
final class ServerException extends AppException {
  const ServerException({
    this.statusCode,
    String message = 'The server returned an error.',
    Object? cause,
  }) : super(message, cause: cause);

  final int? statusCode;
}

/// The requested resource does not exist (HTTP 404).
final class NotFoundException extends AppException {
  const NotFoundException({
    String message = 'Resource not found.',
    Object? cause,
  }) : super(message, cause: cause);
}

/// The response arrived but its shape is not what we expect.
final class InvalidDataException extends AppException {
  const InvalidDataException({
    String message = 'The server returned unexpected data.',
    Object? cause,
  }) : super(message, cause: cause);
}
