import 'package:equatable/equatable.dart';

class Student extends Equatable {
  final String id;
  final String userId;
  final String schoolId;
  final String fullName;
  final String? fatherName;
  final DateTime? dob;
  final String? gender;
  final String phone;
  final String? alternatePhone;
  final String? email;
  final String? address;
  final String? city;
  final String? pincode;
  final String? idProofType;
  final String? idProofNumber;
  final String courseType;
  final String? licenseType;
  final String? batchTiming;
  final DateTime? trainingStartDate;
  final DateTime? trainingEndDate;
  final int? totalDurationDays;
  final double feesAmount;
  final String? paymentMode;
  final String paymentStatus;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? assignedInstructorId;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? remarks;

  const Student({
    required this.id,
    this.userId = '',
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
    this.feesAmount = 0.0,
    this.paymentMode,
    this.paymentStatus = 'Pending',
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.assignedInstructorId,
    this.vehicleType,
    this.vehicleNumber,
    this.remarks,
  });

  Student copyWith({
    String? id,
    String? userId,
    String? schoolId,
    String? fullName,
    String? fatherName,
    DateTime? dob,
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
    DateTime? trainingStartDate,
    DateTime? trainingEndDate,
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
  }) {
    return Student(
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
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    schoolId,
    fullName,
    fatherName,
    dob,
    gender,
    phone,
    alternatePhone,
    email,
    address,
    city,
    pincode,
    idProofType,
    idProofNumber,
    courseType,
    licenseType,
    batchTiming,
    trainingStartDate,
    trainingEndDate,
    totalDurationDays,
    feesAmount,
    paymentMode,
    paymentStatus,
    emergencyContactName,
    emergencyContactPhone,
    assignedInstructorId,
    vehicleType,
    vehicleNumber,
    remarks,
  ];

  @override
  String toString() {
    return 'Student(id: $id, fullName: $fullName, phone: $phone, courseType: $courseType, paymentStatus: $paymentStatus)';
  }
}
