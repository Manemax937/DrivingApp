import 'package:equatable/equatable.dart';

/// Attendance entity
class Attendance extends Equatable {
  final String id;
  final String studentId;
  final String schoolId;
  final String? instructorId;
  final DateTime attendanceDate;
  final DateTime markedAt;
  final String method; // 'QR' or 'manual'
  final String? qrCodeId;
  final Map<String, dynamic>? deviceInfo;

  const Attendance({
    required this.id,
    required this.studentId,
    required this.schoolId,
    this.instructorId,
    required this.attendanceDate,
    required this.markedAt,
    required this.method,
    this.qrCodeId,
    this.deviceInfo,
  });

  /// Check if attendance was marked today
  bool get isToday {
    final now = DateTime.now();
    return attendanceDate.year == now.year &&
        attendanceDate.month == now.month &&
        attendanceDate.day == now.day;
  }

  /// Check if attendance was marked via QR code
  bool get isQRMethod => method == 'QR';

  /// Check if attendance was marked manually
  bool get isManualMethod => method == 'manual';

  /// Get time when attendance was marked (only time part)
  String get markedTime {
    final hour = markedAt.hour.toString().padLeft(2, '0');
    final minute = markedAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Copy with method
  Attendance copyWith({
    String? id,
    String? studentId,
    String? schoolId,
    String? instructorId,
    DateTime? attendanceDate,
    DateTime? markedAt,
    String? method,
    String? qrCodeId,
    Map<String, dynamic>? deviceInfo,
  }) {
    return Attendance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      schoolId: schoolId ?? this.schoolId,
      instructorId: instructorId ?? this.instructorId,
      attendanceDate: attendanceDate ?? this.attendanceDate,
      markedAt: markedAt ?? this.markedAt,
      method: method ?? this.method,
      qrCodeId: qrCodeId ?? this.qrCodeId,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }

  @override
  List<Object?> get props => [
    id,
    studentId,
    schoolId,
    instructorId,
    attendanceDate,
    markedAt,
    method,
    qrCodeId,
    deviceInfo,
  ];
}
