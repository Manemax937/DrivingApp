import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for user login
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, User>> call({
    required String username,
    required String password,
  }) async {
    // Validate inputs
    if (username.isEmpty) {
      return const Left(ValidationFailure('Username is required'));
    }

    if (password.isEmpty) {
      return const Left(ValidationFailure('Password is required'));
    }

    // Trim username
    final trimmedUsername = username.trim();

    // Call repository
    return await repository.login(
      username: trimmedUsername,
      password: password,
    );
  }
}
