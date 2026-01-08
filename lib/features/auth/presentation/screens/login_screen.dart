import 'package:driveapp/core/routes/app_router.dart';
import 'package:driveapp/features/auth/presentation/screens/force_change_password_screen.dart';
import 'package:driveapp/features/owner/presentation/screens/owner_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../providers/firebase_auth_provider.dart';

import 'owner_registration_screen.dart';

enum LoginRole { student, owner }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _schoolNameController = TextEditingController();
  bool _obscurePassword = true;
  bool _admissionDialogShown = false;
  bool _localLoading = false;
  LoginRole _loginRole = LoginRole.student;

  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _cardSlideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _cardSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _cardAnimationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _schoolNameController.dispose();
    _animationController.dispose();
    _cardAnimationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Biometric check listener - ONLY for owners
    ref.listen<FirebaseAuthState>(authProvider, (previous, next) async {
      if (next.isInitializing) return;

      final justLoggedIn =
          previous?.isAuthenticated == false && next.isAuthenticated == true;

      if (!justLoggedIn) return;

      // Only owners require biometric authentication
      if (next.userRole == 'owner') {
        final prefs = await SharedPreferences.getInstance();
        final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
        final key = 'last_biometric_check_$uid';

        final lastBiometricCheck = prefs.getString(key);

        bool needBiometric = true;

        // Check if biometric was verified within the last hour
        if (lastBiometricCheck != null && lastBiometricCheck.isNotEmpty) {
          final lastCheck = DateTime.tryParse(lastBiometricCheck);
          if (lastCheck != null &&
              DateTime.now().difference(lastCheck).inHours < 1) {
            needBiometric = false;
          }
        }

        if (needBiometric) {
          final biometric = BiometricService();
          final ok = await biometric.authenticate(
            reason: 'Verify owner access',
          );

          if (!mounted) return;

          if (!ok) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Biometric verification required for owner login',
                ),
                backgroundColor: Colors.red,
              ),
            );
            await ref.read(authProvider.notifier).logout();
            return;
          }

          // Store successful biometric verification timestamp
          await prefs.setString(key, DateTime.now().toIso8601String());
        }
      }

      if (!mounted) return;
      _navigateToRoleBasedHome(next.userRole);
    });

    // Admission error listener
    ref.listen<FirebaseAuthState>(authProvider, (previous, next) {
      final prevError = previous?.error ?? '';
      final error = next.error ?? '';

      final isAdmissionError = error.toLowerCase().contains('admission');
      final changed = prevError != error;

      if (!_admissionDialogShown && changed && isAdmissionError) {
        _admissionDialogShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Contact School Owner'),
              content: Text(
                error.isNotEmpty
                    ? error
                    : 'No admission found for this account. Please contact the school owner to get admitted.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _admissionDialogShown = false;
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        });
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFFFFA726), // Orange
              Color(0xFFFF7043), // Deep Orange
              Color(0xFFEC407A), // Pink
              Color(0xFFAB47BC), // Purple
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAnimatedLogo(),
                  const SizedBox(height: 40),
                  _buildAnimatedLoginCard(authState),
                  const SizedBox(height: 24),
                  _buildAnimatedRegisterLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.drive_eta,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Driving School',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Management System',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.95),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLoginCard(FirebaseAuthState authState) {
    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        final slideValue = _cardSlideAnimation.value.clamp(0.0, 100.0);
        final scaleValue = _scaleAnimation.value.clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, slideValue),
          child: Transform.scale(
            scale: scaleValue,
            child: Opacity(
              opacity: scaleValue,
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFAB47BC).withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Role Selector
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFFA726).withOpacity(0.15),
                              const Color(0xFFEC407A).withOpacity(0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: SegmentedButton<LoginRole>(
                          segments: const [
                            ButtonSegment<LoginRole>(
                              value: LoginRole.student,
                              label: Text('Student'),
                              icon: Icon(Icons.school),
                            ),
                            ButtonSegment<LoginRole>(
                              value: LoginRole.owner,
                              label: Text('Owner'),
                              icon: Icon(Icons.business_center),
                            ),
                          ],
                          selected: {_loginRole},
                          onSelectionChanged: (value) {
                            setState(() => _loginRole = value.first);
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(MaterialState.selected)) {
                                return Colors.white;
                              }
                              return Colors.transparent;
                            }),
                            foregroundColor: MaterialStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(MaterialState.selected)) {
                                return const Color(0xFFFF7043);
                              }
                              return Colors.grey[600];
                            }),
                            textStyle: MaterialStateProperty.all(
                              const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Header
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFA726), Color(0xFFEC407A)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFFF7043,
                                  ).withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.lock_person,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Login to access your account',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // School Name Field (only for students)
                      if (_loginRole == LoginRole.student) ...[
                        _buildColorfulTextField(
                          controller: _schoolNameController,
                          label: 'School Name',
                          icon: Icons.school,
                          iconColor: const Color(0xFFFFA726),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (_loginRole == LoginRole.student &&
                                (value == null || value.isEmpty)) {
                              return 'Please enter school name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                      ],

                      // Email Field
                      _buildColorfulTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.email,
                        iconColor: const Color(0xFFFF7043),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          if (!value.contains('@')) {
                            return 'Invalid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleLogin(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFEC407A).withOpacity(0.2),
                                  const Color(0xFFAB47BC).withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.lock,
                              color: Color(0xFFEC407A),
                              size: 20,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.grey[200]!,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFEC407A),
                              width: 2.5,
                            ),
                          ),
                        ),
                      ),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _showForgotPasswordDialog(),
                          icon: const Icon(Icons.help_outline, size: 16),
                          label: const Text('Forgot Password?'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFFF7043),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // Error Message
                      if (authState.error != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.red[50]!, Colors.red[100]!],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.red[300]!,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  authState.error!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 8),

                      // Sign In Button
                      Container(
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFFA726),
                              Color(0xFFFF7043),
                              Color(0xFFEC407A),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF7043).withOpacity(0.5),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: authState.isLoading || _localLoading
                              ? null
                              : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: authState.isLoading || _localLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.login_rounded, size: 22),
                                    SizedBox(width: 12),
                                    Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorfulTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization? textCapitalization,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: iconColor, width: 2.5),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedRegisterLink() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Contact the school owner for login.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const OwnerRegistrationScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.business, color: Colors.white, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'Register as School Owner',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_loginRole == LoginRole.owner) {
      // 🔐 OWNER LOGIN
      await ref.read(authProvider.notifier).login(email, password);

      if (!mounted) return; // ✅ IMPORTANT

      final authState = ref.read(authProvider);
      if (!authState.isAuthenticated) return;

      // 🔒 BIOMETRIC CHECK
      final prefs = await SharedPreferences.getInstance();
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final key = 'last_biometric_check_$uid';

      bool needBiometric = true;
      final lastCheck = prefs.getString(key);

      if (lastCheck != null) {
        final last = DateTime.tryParse(lastCheck);
        if (last != null && DateTime.now().difference(last).inHours < 1) {
          needBiometric = false;
        }
      }

      if (needBiometric) {
        final biometric = BiometricService();
        final ok = await biometric.authenticate(reason: 'Verify owner access');

        if (!mounted) return;

        if (!ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric verification required for owner login'),
              backgroundColor: Colors.red,
            ),
          );
          await ref.read(authProvider.notifier).logout();
          return;
        }

        await prefs.setString(key, DateTime.now().toIso8601String());
      }

      // ✅ FINAL FIX: USE GOROUTER (NOT Navigator)
      if (!mounted) return;
      context.go('/owner/dashboard');

      return;
    }

    // 🎓 STUDENT LOGIN
    await _loginStudentWithAdmission(email, password);
  }

  Future<void> _loginStudentWithAdmission(String email, String password) async {
    setState(() => _localLoading = true);
    try {
      // Step 1: Validate school name if provided
      final schoolName = _schoolNameController.text.trim();

      String? schoolId;
      if (schoolName.isNotEmpty) {
        final schoolQuery = await FirebaseFirestore.instance
            .collection('schools')
            .where('name', isEqualTo: schoolName)
            .limit(1)
            .get();

        if (schoolQuery.docs.isEmpty) {
          _showSnack('School not found. Please check the school name.');
          return;
        }

        schoolId = schoolQuery.docs.first.id;
      }

      // Step 2: Try to login with Firebase Auth directly
      print('🔍 Attempting Firebase Auth login for: $email');

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Login failed');
      }

      print('✅ Firebase Auth successful: ${user.uid}');

      // Step 3: Verify user document exists
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        await FirebaseAuth.instance.signOut();
        throw Exception(
          'User profile not found. Contact your school administrator.',
        );
      }

      final userData = userDoc.data()!;

      // Step 4: Verify school_id matches (if school name was provided)
      if (schoolId != null && userData['school_id'] != schoolId) {
        await FirebaseAuth.instance.signOut();
        throw Exception('This account does not belong to the selected school.');
      }

      // Step 5: Check if account is active
      if (userData['active'] == false) {
        await FirebaseAuth.instance.signOut();
        throw Exception(
          'Your account has been deactivated. Contact your school.',
        );
      }

      // Step 6: Check if must change password (first-time login)
      if (userData['must_change_password'] == true) {
        print('🔒 First-time login detected - must change password');

        if (mounted) {
          // Navigate to force change password screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ForceChangePasswordScreen(
                currentPassword: password,
                onPasswordChanged: () {
                  // After password change, complete login
                  if (mounted) {
                    ref.read(authProvider.notifier).login(email, password);
                  }
                },
              ),
            ),
          );
        }
        return;
      }

      // Step 7: Normal login - proceed to dashboard
      await ref.read(authProvider.notifier).login(email, password);

      print('✅ Login complete - redirecting to dashboard');
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');

      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage =
              'No account found with this email. Contact your school administrator.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Check your internet connection.';
          break;
        default:
          errorMessage = e.message ?? 'Login failed. Please try again.';
      }

      _showSnack(errorMessage);
    } catch (e) {
      print('❌ Error: $e');
      _showSnack(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _localLoading = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFFFF7043),
      ),
    );
  }

  void _navigateToRoleBasedHome(String? role) {
    final router = ref.read(routerProvider);

    switch (role) {
      case 'student':
        router.go('/student/dashboard');
        break;
      case 'instructor':
        router.go('/instructor/dashboard');
        break;
      case 'owner':
        router.go('/owner/dashboard');
        break;
      default:
        router.go('/login');
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFA726), Color(0xFFEC407A)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.lock_reset,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Reset Password'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email address and we\'ll send you a password reset link.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFFFF7043),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFFF7043),
                    width: 2,
                  ),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim().toLowerCase();

              // Validate email
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please enter your email address'),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                return;
              }

              if (!email.contains('@') || !email.contains('.')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please enter a valid email address'),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                return;
              }

              // Show loading
              if (context.mounted) {
                Navigator.pop(context); // Close dialog first

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text('Sending reset email...'),
                      ],
                    ),
                    backgroundColor: const Color(0xFFFF7043),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }

              print('📧 Requesting password reset for: $email');

              final success = await ref
                  .read(authProvider.notifier)
                  .sendPasswordResetEmail(email);

              if (context.mounted) {
                // Clear any existing snackbars
                ScaffoldMessenger.of(context).clearSnackBars();

                if (success) {
                  // Show detailed success dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text('Email Sent!'),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'A password reset link has been sent to:',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            email,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('Please check:'),
                          const SizedBox(height: 8),
                          _buildCheckItem('Your inbox'),
                          _buildCheckItem('Spam/Junk folder'),
                          _buildCheckItem('Promotions tab (Gmail)'),
                          const SizedBox(height: 16),
                          Text(
                            'The link will expire in 1 hour.',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Show error
                  final error =
                      ref.read(authProvider).error ??
                      'Failed to send reset email';

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(child: Text(error)),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7043),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  // Helper widget for the checklist
  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Color(0xFFFF7043),
          ),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
