import 'package:dartz/dartz.dart';
import 'package:driveapp/features/auth/domain/entities/user.dart';
import 'package:driveapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:driving_school_app/core/errors/failures.dart';
import 'package:driving_school_app/features/auth/domain/entities/user.dart';
import 'package:driving_school_app/features/auth/domain/usecases/login_usecase.dart';

import '../../../mocks/test_mocks.mocks.dart';

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  const tUsername = 'testuser';
  const tPassword = 'Test@1234';
  final tUser = User(
    id: '1',
    username: tUsername,
    phone: '9876543210',
    role: 'student',
    firstLogin: false,
  );

  test('should return User when login is successful', () async {
    // Arrange
    when(
      mockRepository.login(
        username: anyNamed('username'),
        password: anyNamed('password'),
      ),
    ).thenAnswer((_) async => const Right(tUser));

    // Act
    final result = await useCase(username: tUsername, password: tPassword);

    // Assert
    expect(result, const Right(tUser));
    verify(mockRepository.login(username: tUsername, password: tPassword));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ValidationFailure when username is empty', () async {
    // Act
    final result = await useCase(username: '', password: tPassword);

    // Assert
    expect(result, const Left(ValidationFailure('Username is required')));
    verifyZeroInteractions(mockRepository);
  });

  test('should return ValidationFailure when password is empty', () async {
    // Act
    final result = await useCase(username: tUsername, password: '');

    // Assert
    expect(result, const Left(ValidationFailure('Password is required')));
    verifyZeroInteractions(mockRepository);
  });

  test('should trim username before calling repository', () async {
    // Arrange
    const usernameWithSpaces = '  testuser  ';
    when(
      mockRepository.login(
        username: anyNamed('username'),
        password: anyNamed('password'),
      ),
    ).thenAnswer((_) async => const Right(tUser));

    // Act
    await useCase(username: usernameWithSpaces, password: tPassword);

    // Assert
    verify(
      mockRepository.login(
        username: tUsername, // Should be trimmed
        password: tPassword,
      ),
    );
  });

  test('should return AuthFailure when credentials are invalid', () async {
    // Arrange
    when(
      mockRepository.login(
        username: anyNamed('username'),
        password: anyNamed('password'),
      ),
    ).thenAnswer((_) async => const Left(AuthFailure('Invalid credentials')));

    // Act
    final result = await useCase(username: tUsername, password: tPassword);

    // Assert
    expect(result, const Left(AuthFailure('Invalid credentials')));
  });
}
