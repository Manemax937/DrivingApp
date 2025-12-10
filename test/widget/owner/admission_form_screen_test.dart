import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:driving_school_app/core/errors/failures.dart';
import 'package:driving_school_app/features/owner/domain/entities/student.dart';
import 'package:driving_school_app/features/owner/domain/usecases/create_admission_usecase.dart';

import '../../../mocks/test_mocks.mocks.dart';

void main() {
  late CreateAdmissionUseCase useCase;
  late MockOwnerRepository mockRepository;

  setUp(() {
    mockRepository = MockOwnerRepository();
    useCase = CreateAdmissionUseCase(mockRepository);
  });

  final tStudentData = {
    'full_name': 'Rahul Kumar',
    'phone': '9876543210',
    'course_type': '2-Wheeler',
    'fees_amount': 15000,
  };

  final tStudent = Student(
    id: '1',
    userId: 'user1',
    schoolId: 'school1',
    fullName: 'Rahul Kumar',
    phone: '9876543210',
    courseType: '2-Wheeler',
    feesAmount: 15000,
    paymentStatus: 'Pending',
  );

  test('should create student admission successfully', () async {
    // Arrange
    when(
      mockRepository.createStudentAdmission(any),
    ).thenAnswer((_) async => Right(tStudent));

    // Act
    final result = await useCase(tStudentData);

    // Assert
    expect(result, Right(tStudent));
    verify(mockRepository.createStudentAdmission(tStudentData));
  });

  test('should return ValidationFailure when full_name is missing', () async {
    // Arrange
    final invalidData = Map<String, dynamic>.from(tStudentData);
    invalidData.remove('full_name');

    // Act
    final result = await useCase(invalidData);

    // Assert
    expect(result, const Left(ValidationFailure('Full name is required')));
    verifyZeroInteractions(mockRepository);
  });

  test('should return ValidationFailure when phone is missing', () async {
    // Arrange
    final invalidData = Map<String, dynamic>.from(tStudentData);
    invalidData.remove('phone');

    // Act
    final result = await useCase(invalidData);

    // Assert
    expect(result, const Left(ValidationFailure('Phone number is required')));
    verifyZeroInteractions(mockRepository);
  });

  test('should return ValidationFailure for invalid phone format', () async {
    // Arrange
    final invalidData = Map<String, dynamic>.from(tStudentData);
    invalidData['phone'] = '12345';

    // Act
    final result = await useCase(invalidData);

    // Assert
    expect(
      result,
      const Left(ValidationFailure('Invalid phone number format')),
    );
    verifyZeroInteractions(mockRepository);
  });

  test('should return ValidationFailure for invalid email format', () async {
    // Arrange
    final invalidData = Map<String, dynamic>.from(tStudentData);
    invalidData['email'] = 'invalid-email';

    // Act
    final result = await useCase(invalidData);

    // Assert
    expect(result, const Left(ValidationFailure('Invalid email format')));
    verifyZeroInteractions(mockRepository);
  });
}
