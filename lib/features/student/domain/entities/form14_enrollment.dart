// lib/domain/entities/form14_enrollment.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Form14Enrollment {
  final String id;
  final String studentId;
  final String schoolId;

  // Driving school details (RTO / inspection ready)
  final String drivingSchoolName;
  final String drivingSchoolLicenseNumber;
  final String drivingSchoolAddress;

  // Enrollment / trainee
  final String enrollmentNumber;
  final String traineeName;
  final String? photoUrl;
  final String? aadhaarPhotoUrl;
  final String? panPhotoUrl;

  // Guardian details (replaces relationName)
  final String guardianName;
  final String guardianRelation; // e.g. S/O, D/O, W/O

  // Address / identity
  final String permanentAddress;
  final String? temporaryAddress;
  final DateTime dateOfBirth;
  final String? aadhaarNumber;
  final String? panNumber;

  // Training + vehicle classes (updated)
  final List<String> vehicleClasses;
  final DateTime enrollmentDate;
  final DateTime trainingStartDate;
  final DateTime trainingEndDate;

  // Learner license
  final String? learnerLicenseNumber;
  final DateTime? learnerLicenseExpiry;

  // Course/test dates
  final DateTime? courseCompletionDate;
  final DateTime? testPassDate;

  // Certification (RTO-ready)
  final String instructorName;
  final String certifyingAuthority; // Proprietor / Head Instructor

  final String? remarks;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Form14Enrollment({
    required this.id,
    required this.studentId,
    required this.schoolId,
    required this.drivingSchoolName,
    required this.drivingSchoolLicenseNumber,
    required this.drivingSchoolAddress,
    required this.enrollmentNumber,
    required this.traineeName,
    this.photoUrl,
    this.aadhaarPhotoUrl,
    this.panPhotoUrl,
    required this.guardianName,
    required this.guardianRelation,
    required this.permanentAddress,
    this.temporaryAddress,
    required this.dateOfBirth,
    this.aadhaarNumber,
    this.panNumber,
    required this.vehicleClasses,
    required this.enrollmentDate,
    required this.trainingStartDate,
    required this.trainingEndDate,
    this.learnerLicenseNumber,
    this.learnerLicenseExpiry,
    this.courseCompletionDate,
    this.testPassDate,
    required this.instructorName,
    required this.certifyingAuthority,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Form14Enrollment.fromMap(Map<String, dynamic> map, String id) {
    final vehicleClassesRaw = map['vehicle_classes'];

    return Form14Enrollment(
      id: id,
      studentId: (map['student_id'] as String?) ?? '',
      schoolId: (map['school_id'] as String?) ?? '',
      drivingSchoolName: (map['driving_school_name'] as String?) ?? '',
      drivingSchoolLicenseNumber:
          (map['driving_school_license_number'] as String?) ?? '',
      drivingSchoolAddress: (map['driving_school_address'] as String?) ?? '',
      enrollmentNumber: (map['enrollment_number'] as String?) ?? '',
      traineeName: (map['trainee_name'] as String?) ?? '',
      photoUrl: map['photo_url'] as String?,
      aadhaarPhotoUrl: map['aadhaar_photo_url'] as String?,
      panPhotoUrl: map['pan_photo_url'] as String?,
      guardianName: (map['guardian_name'] as String?) ?? '',
      guardianRelation: (map['guardian_relation'] as String?) ?? '',
      permanentAddress: (map['permanent_address'] as String?) ?? '',
      temporaryAddress: map['temporary_address'] as String?,
      dateOfBirth: (map['date_of_birth'] as Timestamp).toDate(),
      aadhaarNumber: map['aadhaar_number'] as String?,
      panNumber: map['pan_number'] as String?,
      vehicleClasses: (vehicleClassesRaw is List)
          ? vehicleClassesRaw.map((e) => e.toString()).toList()
          : <String>[],
      enrollmentDate: (map['enrollment_date'] as Timestamp).toDate(),
      trainingStartDate: (map['training_start_date'] as Timestamp).toDate(),
      trainingEndDate: (map['training_end_date'] as Timestamp).toDate(),
      learnerLicenseNumber: map['learner_license_number'] as String?,
      learnerLicenseExpiry: map['learner_license_expiry'] != null
          ? (map['learner_license_expiry'] as Timestamp).toDate()
          : null,
      courseCompletionDate: map['course_completion_date'] != null
          ? (map['course_completion_date'] as Timestamp).toDate()
          : null,
      testPassDate: map['test_pass_date'] != null
          ? (map['test_pass_date'] as Timestamp).toDate()
          : null,
      instructorName: (map['instructor_name'] as String?) ?? '',
      certifyingAuthority: (map['certifying_authority'] as String?) ?? '',
      remarks: map['remarks'] as String?,
      createdAt: (map['created_at'] as Timestamp).toDate(),
      updatedAt: (map['updated_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'student_id': studentId,
      'school_id': schoolId,
      'driving_school_name': drivingSchoolName,
      'driving_school_license_number': drivingSchoolLicenseNumber,
      'driving_school_address': drivingSchoolAddress,
      'enrollment_number': enrollmentNumber,
      'trainee_name': traineeName,
      'photo_url': photoUrl,
      'aadhaar_photo_url': aadhaarPhotoUrl,
      'pan_photo_url': panPhotoUrl,
      'guardian_name': guardianName,
      'guardian_relation': guardianRelation,
      'permanent_address': permanentAddress,
      'temporary_address': temporaryAddress,
      'date_of_birth': Timestamp.fromDate(dateOfBirth),
      'aadhaar_number': aadhaarNumber,
      'pan_number': panNumber,
      'vehicle_classes': vehicleClasses,
      'enrollment_date': Timestamp.fromDate(enrollmentDate),
      'training_start_date': Timestamp.fromDate(trainingStartDate),
      'training_end_date': Timestamp.fromDate(trainingEndDate),
      'learner_license_number': learnerLicenseNumber,
      'learner_license_expiry': learnerLicenseExpiry != null
          ? Timestamp.fromDate(learnerLicenseExpiry!)
          : null,
      'course_completion_date': courseCompletionDate != null
          ? Timestamp.fromDate(courseCompletionDate!)
          : null,
      'test_pass_date': testPassDate != null
          ? Timestamp.fromDate(testPassDate!)
          : null,
      'instructor_name': instructorName,
      'certifying_authority': certifyingAuthority,
      'remarks': remarks,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }
}
