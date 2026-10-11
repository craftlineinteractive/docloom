class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found']);
}

class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation failed']);
}
