import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Login user with email and password
  Future<Either<Failure, User>> login({
    required String username,
    required String password,
  });

  /// Register new user
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
    String? schoolId,
  });

  /// Change user password
  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Get current authenticated user
  Future<Either<Failure, User>> getCurrentUser();

  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
}
