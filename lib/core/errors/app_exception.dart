/// Sealed exception hierarchy for the data layer.
sealed class AppException implements Exception {
  const AppException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  const NetworkException(super.message, [super.cause]);
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, [super.cause]);
}

class ApiException extends AppException {
  const ApiException(String message, {this.statusCode, Object? cause})
      : super(message, cause);

  final int? statusCode;
}

class SyncException extends AppException {
  const SyncException(super.message, [super.cause]);
}

class CacheException extends AppException {
  const CacheException(super.message, [super.cause]);
}
