import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/qr_code.dart';
import '../entities/student.dart';

/// Abstract repository for owner operations
abstract class OwnerRepository {
  /// Create new student admission
  Future<Either<Failure, Student>> createStudentAdmission(
    Map<String, dynamic> data,
  );

  /// Get list of students with optional filters
  Future<Either<Failure, List<Student>>> getStudents({
    String? status,
    String? batchTiming,
    String? courseType,
  });

  /// Get student by ID
  Future<Either<Failure, Student>> getStudentById(String studentId);

  /// Update student information
  Future<Either<Failure, Student>> updateStudent(
    String studentId,
    Map<String, dynamic> data,
  );

  /// Delete student
  Future<Either<Failure, void>> deleteStudent(String studentId);

  /// Generate new QR code for school
  Future<Either<Failure, QRCode>> generateQRCode(String schoolId);

  /// Get active QR code for school
  Future<Either<Failure, QRCode>> getActiveQRCode(String schoolId);
}
