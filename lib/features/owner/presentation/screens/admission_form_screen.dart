import 'dart:math';

import 'package:driveapp/features/owner/presentation/screens/student_created_success_screen.dart';

import 'package:driveapp/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';

class AdmissionFormScreen extends ConsumerStatefulWidget {
  const AdmissionFormScreen({super.key});

  @override
  ConsumerState<AdmissionFormScreen> createState() =>
      _AdmissionFormScreenState();
}

class _AdmissionFormScreenState extends ConsumerState<AdmissionFormScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  final _fatherNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _feesAmountController = TextEditingController();

  String _selectedCourseType = '2-Wheeler';
  String? _selectedLicenseType;
  String? _selectedBatchTiming;
  String _selectedPaymentStatus = 'Pending';
  DateTime? _trainingStartDate;
  DateTime? _trainingEndDate;

  bool _isLoading = false;

  // Animation Controllers
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController!,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();

    _fatherNameController.dispose();
    _addressController.dispose();
    _feesAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_fadeAnimation == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFA726),
                Color(0xFFFF7043),
                Color(0xFFEC407A),
                Color(0xFFAB47BC),
              ],
            ),
          ),
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFA726),
              Color(0xFFFF7043),
              Color(0xFFEC407A),
              Color(0xFFAB47BC),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: FadeTransition(
                    opacity: _fadeAnimation!,
                    child: SlideTransition(
                      position: _slideAnimation!,
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          _buildSectionCard(
                            'Personal Information',
                            Icons.person,
                            [Color(0xFFFFA726), Color(0xFFFFB74D)],
                            [
                              _buildTextField(
                                controller: _fullNameController,
                                label: 'Full Name',
                                icon: Icons.person,
                                validator: Validators.validateName,
                                capitalization: TextCapitalization.words,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _phoneController,
                                label: 'Phone Number',
                                icon: Icons.phone,
                                keyboardType: TextInputType.phone,
                                validator: Validators.validatePhone,
                                maxLength: 10,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _emailController,
                                label: 'Student Email',
                                icon: Icons.email,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email is required';
                                  }
                                  return Validators.validateEmail(value);
                                },
                              ),

                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _fatherNameController,
                                label: "Father's Name",
                                icon: Icons.person_outline,
                                capitalization: TextCapitalization.words,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _addressController,
                                label: 'Address',
                                icon: Icons.location_on,
                                maxLines: 3,
                                capitalization: TextCapitalization.words,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildSectionCard(
                            'Course Information',
                            Icons.directions_car,
                            [Color(0xFF42A5F5), Color(0xFF64B5F6)],
                            [
                              _buildDropdown(
                                value: _selectedCourseType,
                                label: 'Course Type',
                                icon: Icons.directions_car,
                                items: const [
                                  DropdownMenuItem(
                                    value: '2-Wheeler',
                                    child: Text('2-Wheeler'),
                                  ),
                                  DropdownMenuItem(
                                    value: '4-Wheeler',
                                    child: Text('4-Wheeler'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Both',
                                    child: Text('Both'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCourseType = value!;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildDropdown(
                                value: _selectedLicenseType,
                                label: 'License Type ',
                                icon: Icons.badge,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Learner',
                                    child: Text('Learner'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Permanent',
                                    child: Text('Permanent'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedLicenseType = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildDropdown(
                                value: _selectedBatchTiming,
                                label: 'Batch Timing (Optional)',
                                icon: Icons.access_time,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Morning',
                                    child: Text('Morning (6 AM - 10 AM)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Afternoon',
                                    child: Text('Afternoon (2 PM - 6 PM)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Evening',
                                    child: Text('Evening (6 PM - 9 PM)'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedBatchTiming = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildSectionCard(
                            'Financial Information',
                            Icons.currency_rupee,
                            [Color(0xFF66BB6A), Color(0xFF81C784)],
                            [
                              _buildTextField(
                                controller: _feesAmountController,
                                label: 'Fees Amount',
                                icon: Icons.currency_rupee,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Fees amount is required';
                                  }
                                  final amount = double.tryParse(value);
                                  if (amount == null || amount <= 0) {
                                    return 'Enter valid amount';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildDropdown(
                                value: _selectedPaymentStatus,
                                label: 'Payment Status',
                                icon: Icons.payment,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Pending',
                                    child: Text('Pending'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Partially Paid',
                                    child: Text('Partially Paid'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Fully Paid',
                                    child: Text('Fully Paid'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPaymentStatus = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildSectionCard(
                            'Training Period',
                            Icons.calendar_month,
                            [Color(0xFFEC407A), Color(0xFFF06292)],
                            [
                              _buildDatePicker(
                                date: _trainingStartDate,
                                label: 'Start Date',
                                onTap: () =>
                                    _selectDate(context, isStartDate: true),
                              ),
                              const SizedBox(height: 16),
                              _buildDatePicker(
                                date: _trainingEndDate,
                                label: 'End Date',
                                onTap: () =>
                                    _selectDate(context, isStartDate: false),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          _buildSubmitButton(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SizedBox(width: 16),
          Text(
            'New Admission',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [
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
    );
  }

  Widget _buildSectionCard(
    String title,
    IconData icon,
    List<Color> colors,
    List<Widget> children,
  ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
    int? maxLines,
    int? maxLength,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFFFF7043)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFFF7043), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      maxLength: maxLength,
      textCapitalization: capitalization,
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFFFF7043)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFFF7043), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildDatePicker({
    required DateTime? date,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Color(0xFFFF7043)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                date == null
                    ? 'Select $label'
                    : '$label: ${date.day}/${date.month}/${date.year}',
                style: TextStyle(
                  fontSize: 16,
                  color: date == null ? Colors.grey[600] : Colors.grey[800],
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF7043).withOpacity(0.4),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check, color: Colors.white),
        label: Text(
          _isLoading ? 'Creating...' : 'Create Admission',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStartDate,
  }) async {
    final initialDate = DateTime.now();
    final firstDate = DateTime(2020);
    final lastDate = DateTime(2030);

    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_trainingStartDate ?? initialDate)
          : (_trainingEndDate ?? initialDate),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFFF7043),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.grey[800]!,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _trainingStartDate = picked;
        } else {
          _trainingEndDate = picked;
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final fullName = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();
    const tempPassword = 'Student@123';

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');

      final ownerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!ownerDoc.exists) throw Exception('Owner profile not found');

      final schoolId = ownerDoc.data()!['school_id'] as String;
      final studentDocRef = FirebaseFirestore.instance
          .collection('students')
          .doc();

      await studentDocRef.set({
        'user_id': '',
        'school_id': schoolId,
        'full_name': fullName,
        'phone': phone,
        'email': email,
        'login_email': email,
        'father_name': _fatherNameController.text.trim().isEmpty
            ? null
            : _fatherNameController.text.trim(),
        'address': _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        'course_type': _selectedCourseType,
        'license_type': _selectedLicenseType,
        'batch_timing': _selectedBatchTiming,
        'fees_amount': double.parse(_feesAmountController.text),
        'payment_status': _selectedPaymentStatus,
        'training_start_date': _trainingStartDate != null
            ? Timestamp.fromDate(_trainingStartDate!)
            : null,
        'training_end_date': _trainingEndDate != null
            ? Timestamp.fromDate(_trainingEndDate!)
            : null,
        'status': 'active',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: tempPassword);

      final uid = userCred.user!.uid;
      await userCred.user!.updateDisplayName(fullName);

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': email.split('@')[0],
        'email': email,
        'phone': phone,
        'full_name': fullName,
        'role': 'student',
        'school_id': schoolId,
        'first_login': true,
        'must_change_password': true,
        'active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      await studentDocRef.update({
        'user_id': uid,
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Clear form
      _emailController.clear();
      _fullNameController.clear();
      _phoneController.clear();
      _fatherNameController.clear();
      _addressController.clear();
      _feesAmountController.clear();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _selectedCourseType = '2-Wheeler';
          _selectedLicenseType = null;
          _selectedBatchTiming = null;
          _selectedPaymentStatus = 'Pending';
          _trainingStartDate = null;
          _trainingEndDate = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Helper widget for credential rows
  Widget _buildCredRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ],
    );
  }

  // Add these helper methods at the bottom of the class (before the closing brace)

  // Generate secure 8-character temporary password
  String _generateTempPassword() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789@#';
    final random = Random.secure();
    return List.generate(
      8,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  // Show dialog with temp password
  Future<void> _showTempPasswordDialog(
    String email,
    String name,
    String tempPassword,
  ) async {
    print('📱 Building dialog for $name');

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF66BB6A), Color(0xFF81C784)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: Colors.white, size: 24),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text('Student Created', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Student account created successfully!',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.share,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Share these credentials:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24, color: Colors.orange.shade200),
                    _buildCredentialRow('Name:', name),
                    _buildCredentialRow('Email:', email),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Temporary Password:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          SelectableText(
                            tempPassword,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Color(0xFFFF7043),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Student must change password on first login',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(
                ClipboardData(
                  text:
                      'Login Credentials for $name\n\n'
                      'Email: $email\n'
                      'Temporary Password: $tempPassword\n\n'
                      'Important: Please change your password on first login.',
                ),
              );
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(
                  content: Text('Copied to clipboard!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: Icon(Icons.copy, size: 18),
            label: Text('Copy'),
            style: TextButton.styleFrom(foregroundColor: Color(0xFFFF7043)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await FirebaseAuth.instance.signOut();

              _emailController.clear();
              _fullNameController.clear();
              _phoneController.clear();
              _fatherNameController.clear();
              _addressController.clear();
              _feesAmountController.clear();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF7043),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Done',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
