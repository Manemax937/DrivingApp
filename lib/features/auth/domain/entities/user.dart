import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String? email;
  final String phone;
  final String? fullName;
  final String role;
  final String? schoolId;
  final bool firstLogin;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.username,
    this.email,
    required this.phone,
    this.fullName,
    required this.role,
    this.schoolId,
    this.firstLogin = false,
    this.active = true,
    this.createdAt,
    this.updatedAt,
  });

  bool get isStudent => role == 'student';
  bool get isInstructor => role == 'instructor';
  bool get isOwner => role == 'owner';

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    phone,
    fullName,
    role,
    schoolId,
    firstLogin,
    active,
    createdAt,
    updatedAt,
  ];

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? fullName,
    String? role,
    String? schoolId,
    bool? firstLogin,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      schoolId: schoolId ?? this.schoolId,
      firstLogin: firstLogin ?? this.firstLogin,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
