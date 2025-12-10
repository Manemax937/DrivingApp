import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/student.dart';

part 'student_model.g.dart';

@JsonSerializable()
class StudentModel {
  final String id;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'school_id')
  final String schoolId;

  @JsonKey(name: 'full_name')
  final String fullName;

  @JsonKey(name: 'father_name')
  final String? fatherName;

  final String? dob;
  final String? gender;
  final String phone;

  @JsonKey(name: 'alternate_phone')
  final String? alternatePhone;

  final String? email;
  final String? address;
  final String? city;
  final String? pincode;

  @JsonKey(name: 'id_proof_type')
  final String? idProofType;

  @JsonKey(name: 'id_proof_number')
  final String? idProofNumber;

  @JsonKey(name: 'course_type')
  final String courseType;

  @JsonKey(name: 'license_type')
  final String? licenseType;

  @JsonKey(name: 'batch_timing')
  final String? batchTiming;

  @JsonKey(name: 'training_start_date')
  final String? trainingStartDate;

  @JsonKey(name: 'training_end_date')
  final String? trainingEndDate;

  @JsonKey(name: 'total_duration_days')
  final int? totalDurationDays;

  @JsonKey(name: 'fees_amount')
  final double feesAmount;

  @JsonKey(name: 'payment_mode')
  final String? paymentMode;

  @JsonKey(name: 'payment_status')
  final String paymentStatus;

  @JsonKey(name: 'emergency_contact_name')
  final String? emergencyContactName;

  @JsonKey(name: 'emergency_contact_phone')
  final String? emergencyContactPhone;

  @JsonKey(name: 'assigned_instructor_id')
  final String? assignedInstructorId;

  @JsonKey(name: 'vehicle_type')
  final String? vehicleType;

  @JsonKey(name: 'vehicle_number')
  final String? vehicleNumber;

  final String? remarks;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  StudentModel({
    required this.id,
    required this.userId,
    required this.schoolId,
    required this.fullName,
    this.fatherName,
    this.dob,
    this.gender,
    required this.phone,
    this.alternatePhone,
    this.email,
    this.address,
    this.city,
    this.pincode,
    this.idProofType,
    this.idProofNumber,
    required this.courseType,
    this.licenseType,
    this.batchTiming,
    this.trainingStartDate,
    this.trainingEndDate,
    this.totalDurationDays,
    required this.feesAmount,
    this.paymentMode,
    required this.paymentStatus,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.assignedInstructorId,
    this.vehicleType,
    this.vehicleNumber,
    this.remarks,
    this.createdAt,
  });

  /// Create StudentModel from JSON
  factory StudentModel.fromJson(Map<String, dynamic> json) =>
      _$StudentModelFromJson(json);

  /// Convert StudentModel to JSON
  Map<String, dynamic> toJson() => _$StudentModelToJson(this);

  /// Convert StudentModel to Student entity
  Student toEntity() {
    return Student(
      id: id,
      userId: userId,
      schoolId: schoolId,
      fullName: fullName,
      fatherName: fatherName,
      dob: dob != null ? DateTime.tryParse(dob!) : null,
      gender: gender,
      phone: phone,
      alternatePhone: alternatePhone,
      email: email,
      address: address,
      city: city,
      pincode: pincode,
      idProofType: idProofType,
      idProofNumber: idProofNumber,
      courseType: courseType,
      licenseType: licenseType,
      batchTiming: batchTiming,
      trainingStartDate: trainingStartDate != null
          ? DateTime.tryParse(trainingStartDate!)
          : null,
      trainingEndDate: trainingEndDate != null
          ? DateTime.tryParse(trainingEndDate!)
          : null,
      totalDurationDays: totalDurationDays,
      feesAmount: feesAmount,
      paymentMode: paymentMode,
      paymentStatus: paymentStatus,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
      assignedInstructorId: assignedInstructorId,
      vehicleType: vehicleType,
      vehicleNumber: vehicleNumber,
      remarks: remarks,
    );
  }

  /// Create StudentModel from Student entity
  factory StudentModel.fromEntity(Student student) {
    return StudentModel(
      id: student.id,
      userId: student.userId,
      schoolId: student.schoolId,
      fullName: student.fullName,
      fatherName: student.fatherName,
      dob: student.dob?.toIso8601String(),
      gender: student.gender,
      phone: student.phone,
      alternatePhone: student.alternatePhone,
      email: student.email,
      address: student.address,
      city: student.city,
      pincode: student.pincode,
      idProofType: student.idProofType,
      idProofNumber: student.idProofNumber,
      courseType: student.courseType,
      licenseType: student.licenseType,
      batchTiming: student.batchTiming,
      trainingStartDate: student.trainingStartDate?.toIso8601String(),
      trainingEndDate: student.trainingEndDate?.toIso8601String(),
      totalDurationDays: student.totalDurationDays,
      feesAmount: student.feesAmount,
      paymentMode: student.paymentMode,
      paymentStatus: student.paymentStatus,
      emergencyContactName: student.emergencyContactName,
      emergencyContactPhone: student.emergencyContactPhone,
      assignedInstructorId: student.assignedInstructorId,
      vehicleType: student.vehicleType,
      vehicleNumber: student.vehicleNumber,
      remarks: student.remarks,
    );
  }

  /// Copy with method
  StudentModel copyWith({
    String? id,
    String? userId,
    String? schoolId,
    String? fullName,
    String? fatherName,
    String? dob,
    String? gender,
    String? phone,
    String? alternatePhone,
    String? email,
    String? address,
    String? city,
    String? pincode,
    String? idProofType,
    String? idProofNumber,
    String? courseType,
    String? licenseType,
    String? batchTiming,
    String? trainingStartDate,
    String? trainingEndDate,
    int? totalDurationDays,
    double? feesAmount,
    String? paymentMode,
    String? paymentStatus,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? assignedInstructorId,
    String? vehicleType,
    String? vehicleNumber,
    String? remarks,
    String? createdAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      schoolId: schoolId ?? this.schoolId,
      fullName: fullName ?? this.fullName,
      fatherName: fatherName ?? this.fatherName,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      idProofType: idProofType ?? this.idProofType,
      idProofNumber: idProofNumber ?? this.idProofNumber,
      courseType: courseType ?? this.courseType,
      licenseType: licenseType ?? this.licenseType,
      batchTiming: batchTiming ?? this.batchTiming,
      trainingStartDate: trainingStartDate ?? this.trainingStartDate,
      trainingEndDate: trainingEndDate ?? this.trainingEndDate,
      totalDurationDays: totalDurationDays ?? this.totalDurationDays,
      feesAmount: feesAmount ?? this.feesAmount,
      paymentMode: paymentMode ?? this.paymentMode,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      assignedInstructorId: assignedInstructorId ?? this.assignedInstructorId,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
