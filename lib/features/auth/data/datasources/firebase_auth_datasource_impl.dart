import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/user_model.dart';
import '../models/login_response_model.dart';

/// Contract for Firebase auth operations
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

  Future<void> changePassword(String newPassword);

  Future<void> sendPasswordResetEmail(String email);

  Future<UserModel?> getCurrentUserData();
}

/// Concrete implementation that uses FirebaseAuth + Firestore
class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDataSourceImpl({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseService.auth,
      _firestore = firestore ?? FirebaseService.firestore;

  @override
  Future<LoginResponseModel> loginWithEmail(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Login failed');
      }

      final userDoc = await _firestore
          .collection(FirebaseService.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw NotFoundException('User data not found');
      }

      // Block disabled accounts
      if ((userDoc.data()?['active'] ?? true) == false) {
        throw AuthException('This account has been deactivated');
      }

      final userModel = UserModel.fromFirestore(userDoc);

      // Students must be tied to an owner-created admission
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

      final idToken = await user.getIdToken();

      return LoginResponseModel(
        accessToken: idToken ?? '',
        refreshToken: user.refreshToken ?? '',
        user: userModel,
        firstLogin: userModel.firstLogin,
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

      // User document data
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

      await user.updateDisplayName(fullName);

      final userModel = UserModel.fromMap(userData, user.uid);

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

  Future<QueryDocumentSnapshot<Map<String, dynamic>>> _findAdmissionDoc({
    required String email,
    required String phone,
  }) async {
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
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: $e');
    }
  }

  @override
  Future<void> changePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException('No user signed in');
      }

      await user.updatePassword(newPassword);

      await _firestore
          .collection(FirebaseService.usersCollection)
          .doc(user.uid)
          .update({
            'first_login': false,
            'updated_at': FieldValue.serverTimestamp(),
          });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw AuthException('Please re-login and try again');
      }
      throw AuthException('Password change failed: ${e.message}');
    } catch (e) {
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

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      throw AuthException('Failed to get user data: $e');
    }
  }
}
