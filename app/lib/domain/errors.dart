/// Typed domain errors. Their messages never carry patient data.
sealed class DomainError implements Exception {
  const DomainError(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Input broke a domain invariant (negative portion, bad time, ...).
class DomainValidationError extends DomainError {
  const DomainValidationError(super.message);
}

/// An id did not match any stored entity.
class NotFoundError extends DomainError {
  const NotFoundError(super.message);
}

/// A repository operation failed.
class RepositoryError extends DomainError {
  const RepositoryError(super.message);
}
