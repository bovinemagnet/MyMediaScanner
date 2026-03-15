/// Domain-layer failure types surfaced via Riverpod AsyncError.
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error']);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Database error']);
}

class ApiFailure extends Failure {
  const ApiFailure([super.message = 'API error']);

  const ApiFailure.notFound() : this('Resource not found');
}

class SyncFailure extends Failure {
  const SyncFailure([super.message = 'Sync error']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation error']);
}
