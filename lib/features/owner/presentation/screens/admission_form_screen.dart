import 'package:flutter/material.dart';
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

class _AdmissionFormScreenState extends ConsumerState<AdmissionFormScreen> {
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

  @override
  void dispose() {
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
    return Scaffold(
      appBar: AppBar(title: const Text('New Admission')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Personal Information Section
            _buildSectionHeader('Personal Information'),
            const SizedBox(height: 12),

            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: Validators.validateName,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhone,
              maxLength: 10,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email (Optional)',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  return Validators.validateEmail(value);
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _fatherNameController,
              decoration: const InputDecoration(
                labelText: "Father's Name (Optional)",
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address (Optional)',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 24),

            // Course Information Section
            _buildSectionHeader('Course Information'),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _selectedCourseType,
              decoration: const InputDecoration(
                labelText: 'Course Type *',
                prefixIcon: Icon(Icons.directions_car),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '2-Wheeler', child: Text('2-Wheeler')),
                DropdownMenuItem(value: '4-Wheeler', child: Text('4-Wheeler')),
                DropdownMenuItem(value: 'Both', child: Text('Both')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCourseType = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedLicenseType,
              decoration: const InputDecoration(
                labelText: 'License Type (Optional)',
                prefixIcon: Icon(Icons.badge),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Learner', child: Text('Learner')),
                DropdownMenuItem(value: 'Permanent', child: Text('Permanent')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedLicenseType = value;
                });
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedBatchTiming,
              decoration: const InputDecoration(
                labelText: 'Batch Timing (Optional)',
                prefixIcon: Icon(Icons.access_time),
                border: OutlineInputBorder(),
              ),
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
            const SizedBox(height: 24),

            // Financial Information Section
            _buildSectionHeader('Financial Information'),
            const SizedBox(height: 12),

            TextFormField(
              controller: _feesAmountController,
              decoration: const InputDecoration(
                labelText: 'Fees Amount *',
                prefixIcon: Icon(Icons.currency_rupee),
                border: OutlineInputBorder(),
              ),
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

            DropdownButtonFormField<String>(
              value: _selectedPaymentStatus,
              decoration: const InputDecoration(
                labelText: 'Payment Status *',
                prefixIcon: Icon(Icons.payment),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Pending', child: Text('Pending')),
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
            const SizedBox(height: 24),

            // Training Dates Section
            _buildSectionHeader('Training Period (Optional)'),
            const SizedBox(height: 12),

            ListTile(
              title: Text(
                _trainingStartDate == null
                    ? 'Select Start Date'
                    : 'Start: ${_trainingStartDate!.day}/${_trainingStartDate!.month}/${_trainingStartDate!.year}',
              ),
              leading: const Icon(Icons.calendar_today),
              trailing: const Icon(Icons.arrow_drop_down),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[400]!),
              ),
              onTap: () => _selectDate(context, isStartDate: true),
            ),
            const SizedBox(height: 16),

            ListTile(
              title: Text(
                _trainingEndDate == null
                    ? 'Select End Date'
                    : 'End: ${_trainingEndDate!.day}/${_trainingEndDate!.month}/${_trainingEndDate!.year}',
              ),
              leading: const Icon(Icons.calendar_today),
              trailing: const Icon(Icons.arrow_drop_down),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[400]!),
              ),
              onTap: () => _selectDate(context, isStartDate: false),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleSubmit,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(_isLoading ? 'Creating...' : 'Create Admission'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
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

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Not authenticated');
      }

      // Create student document in Firestore
      final studentDoc = FirebaseFirestore.instance
          .collection('students')
          .doc();

      await studentDoc.set({
        'user_id': '', // Will be set when student creates account
        'school_id': user.uid,
        'full_name': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
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
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student admission created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
