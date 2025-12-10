// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceModel _$AttendanceModelFromJson(Map<String, dynamic> json) =>
    AttendanceModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      schoolId: json['school_id'] as String,
      instructorId: json['instructor_id'] as String?,
      attendanceDate: json['attendance_date'] as String,
      markedAt: json['marked_at'] as String,
      method: json['method'] as String,
      qrCodeId: json['qr_code_id'] as String?,
      deviceInfo: json['device_info'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AttendanceModelToJson(AttendanceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_id': instance.studentId,
      'school_id': instance.schoolId,
      'instructor_id': instance.instructorId,
      'attendance_date': instance.attendanceDate,
      'marked_at': instance.markedAt,
      'method': instance.method,
      'qr_code_id': instance.qrCodeId,
      'device_info': instance.deviceInfo,
    };
