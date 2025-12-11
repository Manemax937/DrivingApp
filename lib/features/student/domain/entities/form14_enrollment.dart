import 'package:cloud_firestore/cloud_firestore.dart';

class Form14Enrollment {
  final String id;
  final String studentId;
  final String schoolId;
  final String enrollmentNumber;
  final String traineeName;
  final String? photoUrl;
  final String relationName; // Son/wife/daughter of
  final String permanentAddress;
  final String? temporaryAddress;
  final DateTime dateOfBirth;
  final String vehicleClass;
  final DateTime enrollmentDate;
  final String? learnerLicenseNumber;
  final DateTime? learnerLicenseExpiry;
  final DateTime? courseCompletionDate;
  final DateTime? testPassDate;
  final String? drivingLicenseNumber;
  final DateTime? drivingLicenseIssueDate;
  final String? licensingAuthority;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  Form14Enrollment({
    required this.id,
    required this.studentId,
    required this.schoolId,
    required this.enrollmentNumber,
    required this.traineeName,
    this.photoUrl,
    required this.relationName,
    required this.permanentAddress,
    this.temporaryAddress,
    required this.dateOfBirth,
    required this.vehicleClass,
    required this.enrollmentDate,
    this.learnerLicenseNumber,
    this.learnerLicenseExpiry,
    this.courseCompletionDate,
    this.testPassDate,
    this.drivingLicenseNumber,
    this.drivingLicenseIssueDate,
    this.licensingAuthority,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Form14Enrollment.fromMap(Map<String, dynamic> map, String id) {
    return Form14Enrollment(
      id: id,
      studentId: map['student_id'] ?? '',
      schoolId: map['school_id'] ?? '',
      enrollmentNumber: map['enrollment_number'] ?? '',
      traineeName: map['trainee_name'] ?? '',
      photoUrl: map['photo_url'],
      relationName: map['relation_name'] ?? '',
      permanentAddress: map['permanent_address'] ?? '',
      temporaryAddress: map['temporary_address'],
      dateOfBirth: (map['date_of_birth'] as Timestamp).toDate(),
      vehicleClass: map['vehicle_class'] ?? '',
      enrollmentDate: (map['enrollment_date'] as Timestamp).toDate(),
      learnerLicenseNumber: map['learner_license_number'],
      learnerLicenseExpiry: map['learner_license_expiry'] != null
          ? (map['learner_license_expiry'] as Timestamp).toDate()
          : null,
      courseCompletionDate: map['course_completion_date'] != null
          ? (map['course_completion_date'] as Timestamp).toDate()
          : null,
      testPassDate: map['test_pass_date'] != null
          ? (map['test_pass_date'] as Timestamp).toDate()
          : null,
      drivingLicenseNumber: map['driving_license_number'],
      drivingLicenseIssueDate: map['driving_license_issue_date'] != null
          ? (map['driving_license_issue_date'] as Timestamp).toDate()
          : null,
      licensingAuthority: map['licensing_authority'],
      remarks: map['remarks'],
      createdAt: (map['created_at'] as Timestamp).toDate(),
      updatedAt: (map['updated_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'school_id': schoolId,
      'enrollment_number': enrollmentNumber,
      'trainee_name': traineeName,
      'photo_url': photoUrl,
      'relation_name': relationName,
      'permanent_address': permanentAddress,
      'temporary_address': temporaryAddress,
      'date_of_birth': Timestamp.fromDate(dateOfBirth),
      'vehicle_class': vehicleClass,
      'enrollment_date': Timestamp.fromDate(enrollmentDate),
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
      'driving_license_number': drivingLicenseNumber,
      'driving_license_issue_date': drivingLicenseIssueDate != null
          ? Timestamp.fromDate(drivingLicenseIssueDate!)
          : null,
      'licensing_authority': licensingAuthority,
      'remarks': remarks,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }
}
