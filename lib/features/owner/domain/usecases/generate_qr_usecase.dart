import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/qr_code.dart';
import '../repositories/owner_repository.dart';

/// Use case for generating QR code
class GenerateQRUseCase {
  final OwnerRepository repository;

  GenerateQRUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, QRCode>> call(String schoolId) async {
    // Validate school ID
    if (schoolId.isEmpty) {
      return const Left(ValidationFailure('School ID is required'));
    }

    // Call repository to generate QR code
    return await repository.generateQRCode(schoolId);
  }
}
