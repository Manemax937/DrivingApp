// lib/features/auth/domain/entities/user_profile.dart
class UserProfile {
  final String id;
  final String username;
  final String email;
  final String? phone;
  final String role;
  final bool firstLogin;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    required this.role,
    required this.firstLogin,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String id) {
    return UserProfile(
      id: id,
      username: map['username'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String?,
      role: map['role'] as String? ?? 'student',
      firstLogin: map['firstLogin'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'username': username,
    'email': email,
    if (phone != null) 'phone': phone,
    'role': role,
    'firstLogin': firstLogin,
    'updatedAt': DateTime.now().toIso8601String(),
  };
}
