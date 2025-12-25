import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/user_model.dart';
import '../models/login_response_model.dart';

abstract class FirebaseAuthDataSource {
  Future<LoginResponseModel> loginWithEmail(String email, String password);

  Future<LoginResponseModel> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
    String? schoolId,
  });

  Future<void> signOut();

  Future<void> changePassword(String currentPassword, String newPassword);

  Future<void> sendPasswordResetEmail(String email);

  Future<UserModel?> getCurrentUserData();

  // NEW: create user profile document in Firestore
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String fullName,
    required String phone,
    required String role,
    String? schoolId,
  });

  // NEW: mark first_login = false
  Future<void> markFirstLoginComplete(String uid);
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _auth = FirebaseService.auth;
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  @override
  Future<LoginResponseModel> loginWithEmail(
    String email,
    String password,
  ) async {
    try {
      // Sign in with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Login failed');
      }

      // Get user data from Firestore
      final userDoc = await _firestore
          .collection(FirebaseService.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw NotFoundException('User data not found');
      }

      final userData = userDoc.data()!;

      // Block disabled accounts early
      if (userData['active'] == false) {
        throw AuthException('This account has been deactivated');
      }

      // Convert Firestore data to UserModel
      final userModel = UserModel(
        id: user.uid,
        username: userData['username'] ?? email.split('@')[0],
        email: userData['email'] ?? email,
        phone: userData['phone'],
        fullName: userData['full_name'],
        role: userData['role'] ?? 'student',
        schoolId: userData['school_id'],
        firstLogin: userData['first_login'] ?? false,
        active: userData['active'] ?? true,
        createdAt: _convertTimestamp(userData['created_at']),
        updatedAt: _convertTimestamp(userData['updated_at']),
      );

      // Students must be linked to an admission created by the owner
      if (userModel.role == 'student') {
        final admissionSnapshot = await _firestore
            .collection(FirebaseService.studentsCollection)
            .where('user_id', isEqualTo: user.uid)
            .limit(1)
            .get();

        if (admissionSnapshot.docs.isEmpty) {
          await _auth.signOut();
          throw AuthException(
            'No admission found for this account. Please contact the school owner.',
          );
        }
      }

      // Get Firebase ID token (use as access token)
      final idToken = await user.getIdToken();

      return LoginResponseModel(
        accessToken: idToken ?? '',
        refreshToken: user.refreshToken ?? '',
        user: userModel,
        firstLogin: userData['first_login'] ?? false,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw AuthException('No user found with this email');
        case 'wrong-password':
          throw AuthException('Incorrect password');
        case 'invalid-email':
          throw ValidationException('Invalid email address');
        case 'user-disabled':
          throw AuthException('This account has been disabled');
        case 'too-many-requests':
          throw AuthException('Too many attempts. Please try again later');
        default:
          throw AuthException('Login failed: ${e.message}');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException('Login failed: $e');
    }
  }

  @override
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String fullName,
    required String phone,
    required String role,
    String? schoolId,
  }) async {
    try {
      final resolvedSchoolId = role == 'student'
          ? await _linkStudentAdmission(uid: uid, email: email, phone: phone)
          : schoolId;

      final data = {
        'username': email.split('@')[0],
        'email': email,
        'phone': phone,
        'full_name': fullName,
        'role': role,
        'school_id': resolvedSchoolId,
        'first_login': true,
        'active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(FirebaseService.usersCollection)
          .doc(uid)
          .set(data, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ServerException('Failed to create user profile: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to create user profile: $e');
    }
  }

  Future<String?> _linkStudentAdmission({
    required String uid,
    required String email,
    required String phone,
  }) async {
    final admissionDoc = await _findAdmissionDoc(email: email, phone: phone);

    final admissionData = admissionDoc.data();
    final existingUserId = (admissionData['user_id'] ?? '') as String;
    if (existingUserId.trim().isNotEmpty) {
      throw DuplicateException(
        'An account is already linked to this admission. Please login instead.',
      );
    }

    final resolvedSchoolId = admissionData['school_id'] as String?;

    await admissionDoc.reference.update({
      'user_id': uid,
      'email': email,
      'phone': phone,
      'updated_at': FieldValue.serverTimestamp(),
    });

    return resolvedSchoolId;
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>> _findAdmissionDoc({
    required String email,
    required String phone,
  }) async {
    // Prefer phone match; fall back to email
    final phoneQuery = await _firestore
        .collection(FirebaseService.studentsCollection)
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (phoneQuery.docs.isNotEmpty) {
      return phoneQuery.docs.first;
    }

    final emailQuery = await _firestore
        .collection(FirebaseService.studentsCollection)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (emailQuery.docs.isNotEmpty) {
      return emailQuery.docs.first;
    }

    throw ValidationException(
      'No admission record found for the provided details. '
      'Please contact the school owner.',
    );
  }

  @override
  Future<void> markFirstLoginComplete(String uid) async {
    try {
      await _firestore
          .collection(FirebaseService.usersCollection)
          .doc(uid)
          .update({
            'first_login': false,
            'updated_at': FieldValue.serverTimestamp(),
          });
    } on FirebaseException catch (e) {
      throw ServerException('Failed to update first_login: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to update first_login: $e');
    }
  }

  @override
  Future<LoginResponseModel> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
    String? schoolId,
  }) async {
    try {
      QueryDocumentSnapshot<Map<String, dynamic>>? admissionDoc;
      String? resolvedSchoolId = schoolId;

      if (role == 'student') {
        admissionDoc = await _findAdmissionDoc(email: email, phone: phone);

        final existingUserId = (admissionDoc.data()['user_id'] ?? '') as String;
        if (existingUserId.trim().isNotEmpty) {
          throw DuplicateException(
            'An account is already linked to this admission. Please login instead.',
          );
        }

        resolvedSchoolId = admissionDoc.data()['school_id'] as String?;
      }

      // Check if phone already exists
      final phoneQuery = await _firestore
          .collection(FirebaseService.usersCollection)
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (phoneQuery.docs.isNotEmpty) {
        throw DuplicateException('Phone number already registered');
      }

      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Registration failed');
      }

      if (role == 'student' && admissionDoc != null) {
        await admissionDoc.reference.update({
          'user_id': user.uid,
          'email': email,
          'phone': phone,
          'updated_at': FieldValue.serverTimestamp(),
        });
      }

      // Create user document in Firestore
      final now = DateTime.now();
      final userData = {
        'username': email.split('@')[0],
        'email': email,
        'phone': phone,
        'full_name': fullName,
        'role': role,
        'school_id': resolvedSchoolId,
        'first_login': true,
        'active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(FirebaseService.usersCollection)
          .doc(user.uid)
          .set(userData);

      // Update display name
      await user.updateDisplayName(fullName);

      // Create user model (use current time since serverTimestamp is not available yet)
      final userModel = UserModel(
        id: user.uid,
        username: email.split('@')[0],
        email: email,
        phone: phone,
        fullName: fullName,
        role: role,
        schoolId: resolvedSchoolId,
        firstLogin: true,
        active: true,
        createdAt: now,
        updatedAt: now,
      );

      // Get Firebase ID token
      final idToken = await user.getIdToken();

      return LoginResponseModel(
        accessToken: idToken ?? '',
        refreshToken: user.refreshToken ?? '',
        user: userModel,
        firstLogin: true,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw DuplicateException('Email already registered');
        case 'invalid-email':
          throw ValidationException('Invalid email address');
        case 'weak-password':
          throw ValidationException('Password is too weak');
        default:
          throw AuthException('Registration failed: ${e.message}');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException('Registration failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: $e');
    }
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException('No user signed in');
      }

      // Get user email
      final email = user.email;
      if (email == null) {
        throw AuthException('User email not found');
      }

      // Get user role to check if student
      final userDoc = await _firestore
          .collection(FirebaseService.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw AuthException('User data not found');
      }

      final userRole = userDoc.data()?['role'] as String?;

      // STEP 1: Re-authenticate with current password (CRITICAL for security)
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      try {
        await user.reauthenticateWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          throw AuthException('Current password is incorrect');
        } else if (e.code == 'invalid-credential') {
          throw AuthException('Invalid credentials. Please try again');
        }
        throw AuthException('Re-authentication failed: ${e.message}');
      }

      // STEP 2: Update to new password (only after successful re-authentication)
      await user.updatePassword(newPassword);

      // STEP 3: Update Firestore metadata in users collection
      await _firestore
          .collection(FirebaseService.usersCollection)
          .doc(user.uid)
          .update({
            'password_updated_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });

      // STEP 4: If student, also update the password in students collection
      if (userRole == 'student') {
        final studentQuery = await _firestore
            .collection(FirebaseService.studentsCollection)
            .where('user_id', isEqualTo: user.uid)
            .limit(1)
            .get();

        if (studentQuery.docs.isNotEmpty) {
          await studentQuery.docs.first.reference.update({
            'login_password': newPassword,
            'updated_at': FieldValue.serverTimestamp(),
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw ValidationException(
            'New password is too weak. Use at least 6 characters',
          );
        case 'requires-recent-login':
          throw AuthException(
            'Session expired. Please log out and log in again',
          );
        case 'wrong-password':
          throw AuthException('Current password is incorrect');
        default:
          throw AuthException('Password change failed: ${e.message}');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException('Password change failed: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw NotFoundException('No user found with this email');
        case 'invalid-email':
          throw ValidationException('Invalid email address');
        default:
          throw AuthException('Failed to send reset email: ${e.message}');
      }
    } catch (e) {
      throw AuthException('Failed to send reset email: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore
          .collection(FirebaseService.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) return null;

      final userData = userDoc.data()!;

      return UserModel(
        id: user.uid,
        username: userData['username'] ?? user.email?.split('@')[0] ?? '',
        email: userData['email'] ?? user.email,
        phone: userData['phone'],
        fullName: userData['full_name'] ?? user.displayName,
        role: userData['role'] ?? 'student',
        schoolId: userData['school_id'],
        firstLogin: userData['first_login'] ?? false,
        active: userData['active'] ?? true,
        createdAt: _convertTimestamp(userData['created_at']),
        updatedAt: _convertTimestamp(userData['updated_at']),
      );
    } catch (e) {
      throw AuthException('Failed to get user data: $e');
    }
  }

  // Helper method to convert Firestore Timestamp to DateTime
  DateTime? _convertTimestamp(dynamic timestamp) {
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
}
