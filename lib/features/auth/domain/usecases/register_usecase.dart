import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
    String? schoolId,
  }) async {
    // Validate inputs
    if (email.isEmpty) {
      return const Left(ValidationFailure('Email is required'));
    }

    if (password.isEmpty) {
      return const Left(ValidationFailure('Password is required'));
    }

    if (fullName.isEmpty) {
      return const Left(ValidationFailure('Full name is required'));
    }

    if (phone.isEmpty) {
      return const Left(ValidationFailure('Phone number is required'));
    }

    if (role.isEmpty) {
      return const Left(ValidationFailure('Role is required'));
    }

    // Validate email format
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      return const Left(ValidationFailure('Invalid email format'));
    }

    // Validate password strength
    if (password.length < 8) {
      return const Left(
        ValidationFailure('Password must be at least 8 characters'),
      );
    }

    // Validate phone format
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(phone)) {
      return const Left(ValidationFailure('Invalid phone number'));
    }

    return await repository.register(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
      role: role,
      schoolId: schoolId,
    );
  }
}
