import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/attendance.dart';

part 'attendance_model.g.dart';

@JsonSerializable()
class AttendanceModel {
  final String id;

  @JsonKey(name: 'student_id')
  final String studentId;

  @JsonKey(name: 'school_id')
  final String schoolId;

  @JsonKey(name: 'instructor_id')
  final String? instructorId;

  @JsonKey(name: 'attendance_date')
  final String attendanceDate;

  @JsonKey(name: 'marked_at')
  final String markedAt;

  final String method;

  @JsonKey(name: 'qr_code_id')
  final String? qrCodeId;

  @JsonKey(name: 'device_info')
  final Map<String, dynamic>? deviceInfo;

  AttendanceModel({
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

  /// Create AttendanceModel from JSON
  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceModelFromJson(json);

  /// Convert AttendanceModel to JSON
  Map<String, dynamic> toJson() => _$AttendanceModelToJson(this);

  /// Convert AttendanceModel to Attendance entity
  Attendance toEntity() {
    return Attendance(
      id: id,
      studentId: studentId,
      schoolId: schoolId,
      instructorId: instructorId,
      attendanceDate: DateTime.parse(attendanceDate),
      markedAt: DateTime.parse(markedAt),
      method: method,
      qrCodeId: qrCodeId,
      deviceInfo: deviceInfo,
    );
  }

  /// Create AttendanceModel from Attendance entity
  factory AttendanceModel.fromEntity(Attendance attendance) {
    return AttendanceModel(
      id: attendance.id,
      studentId: attendance.studentId,
      schoolId: attendance.schoolId,
      instructorId: attendance.instructorId,
      attendanceDate: attendance.attendanceDate.toIso8601String().split('T')[0],
      markedAt: attendance.markedAt.toIso8601String(),
      method: attendance.method,
      qrCodeId: attendance.qrCodeId,
      deviceInfo: attendance.deviceInfo,
    );
  }

  /// Copy with method
  AttendanceModel copyWith({
    String? id,
    String? studentId,
    String? schoolId,
    String? instructorId,
    String? attendanceDate,
    String? markedAt,
    String? method,
    String? qrCodeId,
    Map<String, dynamic>? deviceInfo,
  }) {
    return AttendanceModel(
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
}
