import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/student_repository.dart';

/// Use case for marking attendance
class MarkAttendanceUseCase {
  final StudentRepository repository;

  MarkAttendanceUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, Map<String, dynamic>>> call({
    required String qrData,
    required Map<String, dynamic> deviceInfo,
  }) async {
    // Validate QR data
    if (qrData.isEmpty) {
      return const Left(ValidationFailure('QR code data is required'));
    }

    // Add timestamp to device info
    final enrichedDeviceInfo = {
      ...deviceInfo,
      'scan_timestamp': DateTime.now().toIso8601String(),
    };

    // Call repository
    return await repository.markAttendance(qrData, enrichedDeviceInfo);
  }

  /// Mark attendance with additional validation
  Future<Either<Failure, Map<String, dynamic>>> markWithValidation({
    required String qrData,
    String? userAgent,
    String? ipAddress,
  }) async {
    // Build device info
    final deviceInfo = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (userAgent != null) {
      deviceInfo['user_agent'] = userAgent;
    }

    if (ipAddress != null) {
      deviceInfo['ip_address'] = ipAddress;
    }

    return await call(qrData: qrData, deviceInfo: deviceInfo);
  }
}
