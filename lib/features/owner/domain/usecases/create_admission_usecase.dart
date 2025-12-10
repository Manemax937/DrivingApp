import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/student.dart';
import '../repositories/owner_repository.dart';

/// Use case for creating student admission
class CreateAdmissionUseCase {
  final OwnerRepository repository;

  CreateAdmissionUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, Student>> call(Map<String, dynamic> data) async {
    // Validate required fields
    final validation = _validateData(data);
    if (validation != null) {
      return Left(ValidationFailure(validation));
    }

    // Call repository
    return await repository.createStudentAdmission(data);
  }

  /// Validate admission form data
  String? _validateData(Map<String, dynamic> data) {
    // Required fields validation
    if (data['full_name'] == null || data['full_name'].toString().isEmpty) {
      return 'Full name is required';
    }

    if (data['phone'] == null || data['phone'].toString().isEmpty) {
      return 'Phone number is required';
    }

    if (data['course_type'] == null || data['course_type'].toString().isEmpty) {
      return 'Course type is required';
    }

    if (data['fees_amount'] == null) {
      return 'Fees amount is required';
    }

    // Phone number validation (10 digits)
    final phone = data['phone'].toString();
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
      return 'Invalid phone number format';
    }

    // Email validation (if provided)
    if (data['email'] != null && data['email'].toString().isNotEmpty) {
      final email = data['email'].toString();
      if (!RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(email)) {
        return 'Invalid email format';
      }
    }

    // Pincode validation (if provided)
    if (data['pincode'] != null && data['pincode'].toString().isNotEmpty) {
      final pincode = data['pincode'].toString();
      if (!RegExp(r'^\d{6}$').hasMatch(pincode)) {
        return 'Invalid pincode format (must be 6 digits)';
      }
    }

    // Fees amount validation
    final fees = data['fees_amount'];
    if (fees is num && fees <= 0) {
      return 'Fees amount must be greater than 0';
    }

    // Date validation
    if (data['training_start_date'] != null &&
        data['training_end_date'] != null) {
      try {
        final startDate = DateTime.parse(data['training_start_date']);
        final endDate = DateTime.parse(data['training_end_date']);

        if (endDate.isBefore(startDate)) {
          return 'End date must be after start date';
        }
      } catch (e) {
        return 'Invalid date format';
      }
    }

    return null; // All validations passed
  }
}
