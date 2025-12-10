import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/attendance.dart';

/// Abstract repository for student operations
abstract class StudentRepository {
  /// Mark attendance by scanning QR code
  Future<Either<Failure, Map<String, dynamic>>> markAttendance(
    String qrData,
    Map<String, dynamic> deviceInfo,
  );

  /// Get attendance records for a student
  Future<Either<Failure, List<Attendance>>> getAttendance(String studentId);

  /// Get student profile
  Future<Either<Failure, Map<String, dynamic>>> getProfile(String studentId);
}
