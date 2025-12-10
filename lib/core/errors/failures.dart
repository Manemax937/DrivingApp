import 'package:equatable/equatable.dart';

/// Base failure class for error handling
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Server failure (5xx errors)
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred'])
    : super(message, code: 'SERVER_FAILURE');
}

/// Network failure (no internet, timeout)
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection'])
    : super(message, code: 'NETWORK_FAILURE');
}

/// Authentication failure (401, 403)
class AuthFailure extends Failure {
  const AuthFailure([String message = 'Authentication failed'])
    : super(message, code: 'AUTH_FAILURE');
}

/// Validation failure (400, invalid input)
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation error'])
    : super(message, code: 'VALIDATION_FAILURE');
}

/// Not found failure (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Resource not found'])
    : super(message, code: 'NOT_FOUND_FAILURE');
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error'])
    : super(message, code: 'CACHE_FAILURE');
}

/// QR Code failure
class QRCodeFailure extends Failure {
  const QRCodeFailure([String message = 'Invalid QR code'])
    : super(message, code: 'QR_FAILURE');
}

/// Duplicate entry failure
class DuplicateFailure extends Failure {
  const DuplicateFailure([String message = 'Record already exists'])
    : super(message, code: 'DUPLICATE_FAILURE');
}

/// Permission failure
class PermissionFailure extends Failure {
  const PermissionFailure([String message = 'Permission denied'])
    : super(message, code: 'PERMISSION_FAILURE');
}

/// Generic failure
class GenericFailure extends Failure {
  const GenericFailure([String message = 'An error occurred'])
    : super(message, code: 'GENERIC_FAILURE');
}
