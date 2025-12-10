import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/student.dart';
import '../repositories/owner_repository.dart';

/// Use case for getting students list
class GetStudentsUseCase {
  final OwnerRepository repository;

  GetStudentsUseCase(this.repository);

  /// Execute the use case with optional filters
  Future<Either<Failure, List<Student>>> call({
    String? status,
    String? batchTiming,
    String? courseType,
  }) async {
    return await repository.getStudents(
      status: status,
      batchTiming: batchTiming,
      courseType: courseType,
    );
  }

  /// Get all students
  Future<Either<Failure, List<Student>>> getAllStudents() async {
    return await repository.getStudents();
  }

  /// Get active students only
  Future<Either<Failure, List<Student>>> getActiveStudents() async {
    return await repository.getStudents(status: 'active');
  }

  /// Get students by batch timing
  Future<Either<Failure, List<Student>>> getStudentsByBatch(
    String batchTiming,
  ) async {
    return await repository.getStudents(batchTiming: batchTiming);
  }

  /// Get students by course type
  Future<Either<Failure, List<Student>>> getStudentsByCourse(
    String courseType,
  ) async {
    return await repository.getStudents(courseType: courseType);
  }
}
