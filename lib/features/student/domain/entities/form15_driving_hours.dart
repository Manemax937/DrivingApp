import 'package:cloud_firestore/cloud_firestore.dart';

class Form15DrivingHours {
  final String id;
  final String studentId;
  final String schoolId;
  final DateTime date;
  final DateTime timeFrom;
  final DateTime timeTo;
  final double hoursSpent;
  final String vehicleClass;
  final String instructorName;
  final String? instructorSignature;
  final String? studentSignature;
  final DateTime createdAt;

  Form15DrivingHours({
    required this.id,
    required this.studentId,
    required this.schoolId,
    required this.date,
    required this.timeFrom,
    required this.timeTo,
    required this.hoursSpent,
    required this.vehicleClass,
    required this.instructorName,
    this.instructorSignature,
    this.studentSignature,
    required this.createdAt,
  });

  factory Form15DrivingHours.fromMap(Map<String, dynamic> map, String id) {
    return Form15DrivingHours(
      id: id,
      studentId: map['student_id'] ?? '',
      schoolId: map['school_id'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      timeFrom: (map['time_from'] as Timestamp).toDate(),
      timeTo: (map['time_to'] as Timestamp).toDate(),
      hoursSpent: (map['hours_spent'] ?? 0).toDouble(),
      vehicleClass: map['vehicle_class'] ?? '',
      instructorName: map['instructor_name'] ?? '',
      instructorSignature: map['instructor_signature'],
      studentSignature: map['student_signature'],
      createdAt: (map['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'school_id': schoolId,
      'date': Timestamp.fromDate(date),
      'time_from': Timestamp.fromDate(timeFrom),
      'time_to': Timestamp.fromDate(timeTo),
      'hours_spent': hoursSpent,
      'vehicle_class': vehicleClass,
      'instructor_name': instructorName,
      'instructor_signature': instructorSignature,
      'student_signature': studentSignature,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
