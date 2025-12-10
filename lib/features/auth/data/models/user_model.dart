import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

class UserModel {
  final String id;
  final String username;
  final String? email;
  final String? phone;
  final String? fullName;
  final String role;
  final String? schoolId;
  final bool firstLogin;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.username,
    this.email,
    this.phone,
    this.fullName,
    required this.role,
    this.schoolId,
    this.firstLogin = false,
    this.active = true,
    this.createdAt,
    this.updatedAt,
  });

  // Convert from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data, doc.id);
  }

  // Convert from Map
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      username: map['username'] ?? '',
      email: map['email'],
      phone: map['phone'],
      fullName: map['full_name'],
      role: map['role'] ?? 'student',
      schoolId: map['school_id'],
      firstLogin: map['first_login'] ?? false,
      active: map['active'] ?? true,
      createdAt: _convertTimestamp(map['created_at']),
      updatedAt: _convertTimestamp(map['updated_at']),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'role': role,
      'school_id': schoolId,
      'first_login': firstLogin,
      'active': active,
      'created_at': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updated_at': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  // Legacy JSON support (for API compatibility)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'],
      phone: json['phone'],
      fullName: json['full_name'],
      role: json['role'] ?? 'student',
      schoolId: json['school_id'],
      firstLogin: json['first_login'] ?? false,
      active: json['active'] ?? true,
      createdAt: _convertTimestamp(json['created_at']),
      updatedAt: _convertTimestamp(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'role': role,
      'school_id': schoolId,
      'first_login': firstLogin,
      'active': active,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper to convert various timestamp formats to DateTime
  static DateTime? _convertTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;

    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }

    if (timestamp is String) {
      return DateTime.tryParse(timestamp);
    }

    if (timestamp is DateTime) {
      return timestamp;
    }

    return null;
  }

  // Convert to domain entity
  User toEntity() {
    return User(
      id: id,
      username: username,
      email: email,
      phone: phone ?? '',
      fullName: fullName,
      role: role,
      schoolId: schoolId,
      firstLogin: firstLogin,
      active: active,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Convert from domain entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      email: user.email,
      phone: user.phone,
      fullName: user.fullName,
      role: user.role,
      schoolId: user.schoolId,
      firstLogin: user.firstLogin,
      active: user.active,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  // Copy with method
  UserModel copyWith({
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
    return UserModel(
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

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.username == username &&
        other.email == email &&
        other.phone == phone &&
        other.role == role;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        role.hashCode;
  }
}
