/// Base exception class for the app
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Server exception (5xx errors)
class ServerException extends AppException {
  ServerException([String message = 'Server error occurred'])
    : super(message, code: 'SERVER_ERROR');
}

/// Network exception (no internet, timeout)
class NetworkException extends AppException {
  NetworkException([String message = 'No internet connection'])
    : super(message, code: 'NETWORK_ERROR');
}

/// Authentication exception (401, 403)
class AuthException extends AppException {
  AuthException([String message = 'Authentication failed'])
    : super(message, code: 'AUTH_ERROR');
}

/// Validation exception (400, invalid input)
class ValidationException extends AppException {
  ValidationException([String message = 'Validation error'])
    : super(message, code: 'VALIDATION_ERROR');
}

/// Not found exception (404)
class NotFoundException extends AppException {
  NotFoundException([String message = 'Resource not found'])
    : super(message, code: 'NOT_FOUND');
}

/// Cache exception
class CacheException extends AppException {
  CacheException([String message = 'Cache error'])
    : super(message, code: 'CACHE_ERROR');
}

/// QR Code exception
class QRCodeException extends AppException {
  QRCodeException([String message = 'Invalid QR code'])
    : super(message, code: 'QR_ERROR');
}

/// Duplicate entry exception
class DuplicateException extends AppException {
  DuplicateException([String message = 'Record already exists'])
    : super(message, code: 'DUPLICATE_ERROR');
}

/// Permission exception
class PermissionException extends AppException {
  PermissionException([String message = 'Permission denied'])
    : super(message, code: 'PERMISSION_ERROR');
}
