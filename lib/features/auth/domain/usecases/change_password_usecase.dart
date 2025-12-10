import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case for changing user password
class ChangePasswordUseCase {
  final AuthRepository repository;

  ChangePasswordUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, void>> call({
    required String oldPassword,
    required String newPassword,
  }) async {
    // Validate inputs
    if (oldPassword.isEmpty) {
      return const Left(ValidationFailure('Current password is required'));
    }

    if (newPassword.isEmpty) {
      return const Left(ValidationFailure('New password is required'));
    }

    if (newPassword.length < 8) {
      return const Left(
        ValidationFailure('Password must be at least 8 characters'),
      );
    }

    if (oldPassword == newPassword) {
      return const Left(
        ValidationFailure(
          'New password must be different from current password',
        ),
      );
    }

    // Validate password strength
    if (!_isPasswordStrong(newPassword)) {
      return const Left(
        ValidationFailure(
          'Password must contain uppercase, lowercase, number, and special character',
        ),
      );
    }

    // Call repository
    return await repository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }

  /// Check if password is strong enough
  bool _isPasswordStrong(String password) {
    // Check for uppercase
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return false;
    }

    // Check for lowercase
    if (!password.contains(RegExp(r'[a-z]'))) {
      return false;
    }

    // Check for number
    if (!password.contains(RegExp(r'[0-9]'))) {
      return false;
    }

    // Check for special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return false;
    }

    return true;
  }
}
