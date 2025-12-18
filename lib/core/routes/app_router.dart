import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/change_password_screen.dart';
import '../../features/auth/presentation/screens/owner_registration_screen.dart';

import '../../features/owner/presentation/screens/owner_dashboard_screen.dart';
import '../../features/owner/presentation/screens/admission_form_screen.dart';
import '../../features/owner/presentation/screens/qr_code_screen.dart';

import '../../features/student/presentation/screens/student_dashboard_screen.dart';
import '../../features/student/presentation/screens/qr_scanner_screen.dart';
import '../../features/student/presentation/screens/attendance_calendar_screen.dart';
import '../../features/student/presentation/screens/profile_screen.dart';

import '../../features/auth/presentation/providers/firebase_auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  ref.keepAlive();

  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',

    /// 🔐 AUTH / ROLE REDIRECTS
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final location = state.matchedLocation;

      const publicRoutes = ['/login', '/register', '/owner/register'];

      // ❌ Block unauthenticated users
      if (!isAuthenticated && !publicRoutes.contains(location)) {
        return '/login';
      }

      // ✅ Redirect logged-in users away from auth pages
      if (isAuthenticated &&
          (location == '/login' || location == '/register')) {
        return switch (authState.userRole) {
          'owner' => '/owner/dashboard',
          'student' => '/student/dashboard',
          _ => '/login',
        };
      }

      return null;
    },

    routes: [
      // 🔐 AUTH ROUTES
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),

      GoRoute(
        path: '/owner/register',
        builder: (context, state) => const OwnerRegistrationScreen(),
      ),

      // 👑 OWNER ROUTES
      GoRoute(
        path: '/owner/dashboard',
        builder: (context, state) => const OwnerDashboardScreen(),
      ),

      GoRoute(
        path: '/owner/admission',
        builder: (context, state) => const AdmissionFormScreen(),
      ),

      GoRoute(
        path: '/owner/qr-code',
        builder: (context, state) => const QRCodeScreen(),
      ),

      // 🎓 STUDENT ROUTES
      GoRoute(
        path: '/student/dashboard',
        builder: (context, state) => const StudentDashboardScreen(),
      ),

      GoRoute(
        path: '/student/scan-qr',
        builder: (context, state) => const QRScannerScreen(),
      ),

      GoRoute(
        path: '/student/attendance',
        builder: (context, state) => const AttendanceCalendarScreen(),
      ),

      GoRoute(
        path: '/student/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
