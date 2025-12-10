import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/attendance.dart';
import '../repositories/student_repository.dart';

/// Use case for getting student attendance records
class GetAttendanceUseCase {
  final StudentRepository repository;

  GetAttendanceUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, List<Attendance>>> call(String studentId) async {
    // Validate student ID
    if (studentId.isEmpty) {
      return const Left(ValidationFailure('Student ID is required'));
    }

    // Call repository
    return await repository.getAttendance(studentId);
  }

  /// Get attendance for a specific month
  Future<Either<Failure, List<Attendance>>> getMonthlyAttendance(
    String studentId,
    int year,
    int month,
  ) async {
    final result = await call(studentId);

    return result.fold((failure) => Left(failure), (attendanceList) {
      final filteredList = attendanceList.where((attendance) {
        return attendance.attendanceDate.year == year &&
            attendance.attendanceDate.month == month;
      }).toList();
      return Right(filteredList);
    });
  }

  /// Get attendance count for a date range
  Future<Either<Failure, int>> getAttendanceCount(
    String studentId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final result = await call(studentId);

    return result.fold((failure) => Left(failure), (attendanceList) {
      final count = attendanceList.where((attendance) {
        return attendance.attendanceDate.isAfter(
              startDate.subtract(const Duration(days: 1)),
            ) &&
            attendance.attendanceDate.isBefore(
              endDate.add(const Duration(days: 1)),
            );
      }).length;
      return Right(count);
    });
  }

  /// Get attendance percentage for a date range
  Future<Either<Failure, double>> getAttendancePercentage(
    String studentId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final totalDays = endDate.difference(startDate).inDays + 1;

    final countResult = await getAttendanceCount(studentId, startDate, endDate);

    return countResult.fold((failure) => Left(failure), (presentDays) {
      if (totalDays == 0) return const Right(0.0);
      final percentage = (presentDays / totalDays) * 100;
      return Right(percentage);
    });
  }
}
