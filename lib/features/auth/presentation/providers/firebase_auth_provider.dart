// features/auth/presentation/providers/firebase_auth_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driveapp/core/services/biometric_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';

import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/repositories/firebase_auth_repository_impl.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';

/// State
class FirebaseAuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final bool isInitializing; // true while we check restored session
  final String? error;
  final bool firstLogin;
  final String? userRole;
  final String? userId;

  const FirebaseAuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.isInitializing = true,
    this.error,
    this.firstLogin = false,
    this.userRole,
    this.userId,
  });

  FirebaseAuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    bool? isInitializing,
    String? error,
    bool? firstLogin,
    String? userRole,
    String? userId,
  }) {
    return FirebaseAuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      isInitializing: isInitializing ?? this.isInitializing,
      error: error,
      firstLogin: firstLogin ?? this.firstLogin,
      userRole: userRole ?? this.userRole,
      userId: userId ?? this.userId,
    );
  }
}

/// Notifier (Firebase-only)
class FirebaseAuthNotifier extends StateNotifier<FirebaseAuthState> {
  final FirebaseAuthDataSource dataSource;
  final firebase_auth.FirebaseAuth _firebaseAuth;

  FirebaseAuthNotifier({required this.dataSource})
    : _firebaseAuth = firebase_auth.FirebaseAuth.instance,
      super(const FirebaseAuthState()) {
    _initialize();
  }

  // Initialize: restore session and listen to changes
  Future<void> _initialize() async {
    try {
      // Listen to auth state changes
      _firebaseAuth.authStateChanges().listen((user) {
        if (user == null) {
          // signed out
          state = const FirebaseAuthState(isInitializing: false);
        } else {
          // signed in -> load profile
          _loadUserDataAndSetState();
        }
      });

      // If a user is already signed in, load data; otherwise finish initializing
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        await _loadUserDataAndSetState();
      } else {
        state = state.copyWith(isInitializing: false);
      }
    } catch (e, st) {
      debugPrint('FirebaseAuthNotifier._initialize error: $e\n$st');
      state = state.copyWith(
        isInitializing: false,
        error: 'Initialization failed',
      );
    }
  }

  // Load user profile from your data source (e.g., Firestore) and update state
  Future<void> _loadUserDataAndSetState() async {
    try {
      // Keep loading indicator minimal when restoring session
      state = state.copyWith(isLoading: true, error: null);
      final userData = await dataSource.getCurrentUserData();
      if (userData != null) {
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          isInitializing: false,
          firstLogin: userData.firstLogin,
          userRole: userData.role,
          userId: userData.id,
          error: null,
        );
      } else {
        // If profile not found, treat as signed out (or handle as needed)
        state = const FirebaseAuthState(isInitializing: false);
      }
    } catch (e, st) {
      debugPrint('FirebaseAuthNotifier._loadUserData error: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        isInitializing: false,
        error: 'Failed to load user data',
      );
    }
  }

  /// Sign in with Firebase Auth (email/password)
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // On successful Firebase sign-in, load user profile and update state
      await _loadUserDataAndSetState();
      // NOTE: usecases/repositories are not used for auth since we use Firebase directly
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint(
        'FirebaseAuthNotifier.login Firebase error: ${e.code} ${e.message}',
      );
      state = state.copyWith(
        isLoading: false,
        error: e.message ?? 'Authentication failed',
      );
    } catch (e, st) {
      debugPrint('FirebaseAuthNotifier.login error: $e\n$st');
      state = state.copyWith(isLoading: false, error: 'Login failed');
    }
  }

  /// Register (create user in Firebase Auth and then create profile via dataSource)
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
    String? schoolId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create profile record in your DB through the dataSource/repository
      // Expect dataSource to implement createUserProfile or similar
      // If your datasource uses repository/usecase, you can call them instead
      await dataSource.createUserProfile(
        uid: cred.user!.uid,
        email: email,
        fullName: fullName,
        phone: phone,
        role: role,
        schoolId: schoolId,
      );

      // Load profile and set firstLogin = true
      await _loadUserDataAndSetState();
      state = state.copyWith(firstLogin: true);
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint(
        'FirebaseAuthNotifier.register Firebase error: ${e.code} ${e.message}',
      );
      state = state.copyWith(
        isLoading: false,
        error: e.message ?? 'Registration failed',
      );
    } catch (e, st) {
      debugPrint('FirebaseAuthNotifier.register error: $e\n$st');
      state = state.copyWith(isLoading: false, error: 'Registration failed');
    }
  }

  /// Owner login with biometric verification
  Future<void> loginOwner(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Step 1: Login with Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Login failed');

      // Step 2: Check if user is owner
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) throw Exception('User data not found');

      final userData = userDoc.data()!;
      if (userData['role'] != 'owner') {
        await firebase_auth.FirebaseAuth.instance.signOut();
        throw Exception('This account is not registered as an owner');
      }

      // Step 3: Check owner approval status
      final ownerDoc = await FirebaseFirestore.instance
          .collection('owners')
          .doc(user.uid)
          .get();

      if (!ownerDoc.exists) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Owner profile not found');
      }

      final ownerData = ownerDoc.data()!;
      final status = ownerData['status'] as String;

      // Step 4: Validate approval status
      if (status == 'pending') {
        await FirebaseAuth.instance.signOut();
        throw Exception(
          'Account pending approval. You will be notified via email within 24-48 hours.',
        );
      }

      if (status == 'rejected') {
        await FirebaseAuth.instance.signOut();
        final reason = ownerData['rejection_reason'] ?? 'No reason provided';
        throw Exception('Account rejected. Reason: $reason');
      }

      if (status != 'approved') {
        await firebase_auth.FirebaseAuth.instance.signOut();
        throw Exception('Invalid account status');
      }

      // Step 5: Require biometric authentication
      final biometricService = BiometricService();
      final isAuthenticated = await biometricService.authenticate(
        reason: 'Verify your identity to access Owner Dashboard',
      );

      if (!isAuthenticated) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Biometric authentication failed');
      }

      // Step 6: Success - Update state
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        userId: email,
        userRole: 'owner',
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        default:
          errorMessage = e.message ?? 'Login failed';
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e, st) {
      debugPrint('FirebaseAuthNotifier.sendPasswordResetEmail error: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to send reset email',
      );
      return false;
    }
  }

  /// Change password (re-auth if needed). This uses your dataSource/usecase if you have extra checks.
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'No authenticated user',
        );
        return false;
      }

      // Reauthenticate user with old password
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      // If you maintain a 'firstLogin' flag in profile, update it via dataSource
      await dataSource.markFirstLoginComplete(user.uid);

      // Reload profile
      await _loadUserDataAndSetState();

      state = state.copyWith(isLoading: false, firstLogin: false);
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint(
        'FirebaseAuthNotifier.changePassword Firebase error: ${e.code} ${e.message}',
      );
      state = state.copyWith(
        isLoading: false,
        error: e.message ?? 'Change password failed',
      );
      return false;
    } catch (e, st) {
      debugPrint('FirebaseAuthNotifier.changePassword error: $e\n$st');
      state = state.copyWith(isLoading: false, error: 'Change password failed');
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      state = const FirebaseAuthState(isInitializing: false);
    } catch (e, st) {
      debugPrint('FirebaseAuthNotifier.logout error: $e\n$st');
      state = state.copyWith(error: 'Logout failed');
    }
  }

  /// Clear UI errors
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Providers for datasource/usecases (kept for compatibility)
final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  return FirebaseAuthDataSourceImpl();
});

// If you still have repository/usecases that operate on profile data,
// keep them; otherwise they aren't necessary for auth.
final authRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(firebaseAuthDataSourceProvider);
  return FirebaseAuthRepositoryImpl(dataSource: dataSource);
});

final loginUseCaseProvider = Provider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final registerUseCaseProvider = Provider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository);
});

final changePasswordUseCaseProvider = Provider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ChangePasswordUseCase(repository);
});

final authProvider =
    StateNotifierProvider<FirebaseAuthNotifier, FirebaseAuthState>((ref) {
      final dataSource = ref.watch(firebaseAuthDataSourceProvider);
      return FirebaseAuthNotifier(dataSource: dataSource);
    });
