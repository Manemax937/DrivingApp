import 'package:driveapp/features/auth/presentation/screens/owner_registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';

import '../../features/auth/presentation/screens/change_password_screen.dart';
import '../../features/owner/presentation/screens/owner_dashboard_screen.dart';
import '../../features/owner/presentation/screens/admission_form_screen.dart';
import '../../features/owner/presentation/screens/qr_code_screen.dart';
import '../../features/student/presentation/screens/student_dashboard_screen.dart';
import '../../features/student/presentation/screens/qr_scanner_screen.dart';
import '../../features/student/presentation/screens/attendance_calendar_screen.dart';
import '../../features/student/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/providers/firebase_auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  debugPrint(
    "AUTH STATE IN ROUTER: isAuth=${authState.isAuthenticated}, firstLogin=${authState.firstLogin}, role=${authState.userRole}",
  );

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';
      final isRegisterRoute = state.matchedLocation == '/register';

      // If not authenticated and trying to access protected route
      if (!isAuthenticated && !isLoginRoute && !isRegisterRoute) {
        return '/login';
      }

      // If authenticated and on login/register page, redirect to dashboard
      if (isAuthenticated && (isLoginRoute || isRegisterRoute)) {
        // Navigate to role-based dashboard (no firstLogin redirect)
        switch (authState.userRole) {
          case 'student':
            return '/student/dashboard';
          case 'instructor':
            return '/instructor/dashboard';
          case 'owner':
            return '/owner/dashboard';
          default:
            return '/login';
        }
      }

      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),

      // Owner Routes
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

      // Student Routes
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
      GoRoute(
        path: '/owner/register',
        builder: (context, state) => const OwnerRegistrationScreen(),
      ),
    ],
  );
});
