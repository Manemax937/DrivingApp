import 'dart:io';
import 'package:driveapp/core/services/pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Form14EnrollmentScreen extends ConsumerStatefulWidget {
  const Form14EnrollmentScreen({super.key});

  @override
  ConsumerState<Form14EnrollmentScreen> createState() =>
      _Form14EnrollmentScreenState();
}

class _Form14EnrollmentScreenState extends ConsumerState<Form14EnrollmentScreen>
    with TickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();

  // Controllers
  final traineeNameController = TextEditingController();
  final guardianNameController = TextEditingController(); // NEW
  final permanentAddressController = TextEditingController();
  final temporaryAddressController = TextEditingController();
  final enrollmentNumberController = TextEditingController();
  final learnerLicenseController = TextEditingController();
  final aadhaarNumberController = TextEditingController();
  final panNumberController = TextEditingController();
  final remarksController = TextEditingController();

  // NEW: Driving school details
  final drivingSchoolNameController = TextEditingController();
  final drivingSchoolLicenseController = TextEditingController();
  final drivingSchoolAddressController = TextEditingController();

  // NEW: Certification
  final instructorNameController = TextEditingController();

  // Date fields
  DateTime? dateOfBirth;
  DateTime? enrollmentDate;
  DateTime? trainingStartDate; // NEW
  DateTime? trainingEndDate; // NEW
  DateTime? learnerLicenseExpiry;
  DateTime? courseCompletionDate;
  DateTime? testPassDate;

  // NEW: Guardian relation dropdown
  String selectedGuardianRelation = 'S/O'; // NEW

  // NEW: Certifying authority dropdown
  String selectedCertifyingAuthority = 'Proprietor'; // NEW

  // NEW: Vehicle classes (multi-select)
  List<String> selectedVehicleClasses = ['2-Wheeler']; // NEW

  bool isLoading = false;
  bool hasExistingData = false;

  // Image upload fields
  File? userPhotoFile;
  File? aadhaarPhotoFile;
  File? panPhotoFile;
  String? existingUserPhotoUrl;
  String? existingAadhaarPhotoUrl;
  String? existingPanPhotoUrl;
  bool isUploadingImages = false;

  final ImagePicker picker = ImagePicker();
  AnimationController? animationController;
  Animation<double>? fadeAnimation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController!, curve: Curves.easeIn),
    );
    animationController!.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  @override
  void dispose() {
    animationController?.dispose();
    traineeNameController.dispose();
    guardianNameController.dispose();
    permanentAddressController.dispose();
    temporaryAddressController.dispose();
    enrollmentNumberController.dispose();
    learnerLicenseController.dispose();
    aadhaarNumberController.dispose();
    panNumberController.dispose();
    remarksController.dispose();
    drivingSchoolNameController.dispose();
    drivingSchoolLicenseController.dispose();
    drivingSchoolAddressController.dispose();
    instructorNameController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingData() async {
    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('form14_enrollment')
          .where('student_id', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        setState(() {
          hasExistingData = true;

          traineeNameController.text = data['trainee_name'] ?? '';
          guardianNameController.text = data['guardian_name'] ?? '';
          selectedGuardianRelation = data['guardian_relation'] ?? 'S/O';
          permanentAddressController.text = data['permanent_address'] ?? '';
          temporaryAddressController.text = data['temporary_address'] ?? '';
          enrollmentNumberController.text = data['enrollment_number'] ?? '';
          learnerLicenseController.text = data['learner_license_number'] ?? '';
          remarksController.text = data['remarks'] ?? '';
          aadhaarNumberController.text = data['aadhaar_number'] ?? '';
          panNumberController.text = data['pan_number'] ?? '';

          // NEW fields
          drivingSchoolNameController.text = data['driving_school_name'] ?? '';
          drivingSchoolLicenseController.text =
              data['driving_school_license_number'] ?? '';
          drivingSchoolAddressController.text =
              data['driving_school_address'] ?? '';
          instructorNameController.text = data['instructor_name'] ?? '';
          selectedCertifyingAuthority =
              data['certifying_authority'] ?? 'Proprietor';

          // Vehicle classes (list)
          final vehicleClassesRaw = data['vehicle_classes'];
          if (vehicleClassesRaw is List) {
            selectedVehicleClasses = vehicleClassesRaw
                .map((e) => e.toString())
                .toList();
          }

          existingUserPhotoUrl = data['photo_url'];
          existingAadhaarPhotoUrl = data['aadhaar_photo_url'];
          existingPanPhotoUrl = data['pan_photo_url'];

          if (data['date_of_birth'] != null) {
            dateOfBirth = (data['date_of_birth'] as Timestamp).toDate();
          }
          if (data['enrollment_date'] != null) {
            enrollmentDate = (data['enrollment_date'] as Timestamp).toDate();
          }
          if (data['training_start_date'] != null) {
            trainingStartDate = (data['training_start_date'] as Timestamp)
                .toDate();
          }
          if (data['training_end_date'] != null) {
            trainingEndDate = (data['training_end_date'] as Timestamp).toDate();
          }
          if (data['learner_license_expiry'] != null) {
            learnerLicenseExpiry = (data['learner_license_expiry'] as Timestamp)
                .toDate();
          }
          if (data['course_completion_date'] != null) {
            courseCompletionDate = (data['course_completion_date'] as Timestamp)
                .toDate();
          }
          if (data['test_pass_date'] != null) {
            testPassDate = (data['test_pass_date'] as Timestamp).toDate();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error loading data: $e', isError: true);
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source, String imageType) async {
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          switch (imageType) {
            case 'user':
              userPhotoFile = File(pickedFile.path);
              break;
            case 'aadhaar':
              aadhaarPhotoFile = File(pickedFile.path);
              break;
            case 'pan':
              panPhotoFile = File(pickedFile.path);
              break;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error picking image: $e', isError: true);
      }
    }
  }

  void _showImageSourceDialog(String imageType) {
    String title;
    switch (imageType) {
      case 'user':
        title = 'User Photo';
        break;
      case 'aadhaar':
        title = 'Aadhaar';
        break;
      case 'pan':
        title = 'PAN Card';
        break;
      default:
        title = 'Photo';
    }

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
                  colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.photo_camera,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF42A5F5), Color(0xFF64B5F6)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.photo_camera,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, imageType);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF66BB6A), Color(0xFF81C784)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, imageType);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, String?>> _uploadAllImages() async {
    setState(() => isUploadingImages = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnackBar('Not signed in', isError: true);
        return {};
      }

      String? userPhotoUrl = existingUserPhotoUrl;
      String? aadhaarPhotoUrl = existingAadhaarPhotoUrl;
      String? panPhotoUrl = existingPanPhotoUrl;

      Future<String?> uploadFile(File file, String destPath) async {
        final ref = FirebaseStorage.instance.ref().child(destPath);
        try {
          await ref.putFile(file);
          return await ref.getDownloadURL();
        } catch (e) {
          print('Upload error: $e');
          rethrow;
        }
      }

      if (userPhotoFile != null) {
        final fileName =
            'user_photo_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        userPhotoUrl = await uploadFile(
          userPhotoFile!,
          'form14_photos/user/$fileName',
        );
      }

      if (aadhaarPhotoFile != null) {
        final fileName =
            'aadhaar_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        aadhaarPhotoUrl = await uploadFile(
          aadhaarPhotoFile!,
          'form14_photos/aadhaar/$fileName',
        );
      }

      if (panPhotoFile != null) {
        final fileName =
            'pan_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        panPhotoUrl = await uploadFile(
          panPhotoFile!,
          'form14_photos/pan/$fileName',
        );
      }

      return {
        'photo_url': userPhotoUrl,
        'aadhaar_photo_url': aadhaarPhotoUrl,
        'pan_photo_url': panPhotoUrl,
      };
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error uploading images: $e', isError: true);
      }
      return {};
    } finally {
      setState(() => isUploadingImages = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
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
                child: isLoading
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  Color(0xFFFF7043),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Loading form...',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _buildForm(),
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FORM-14',
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
                Text(
                  'Trainee Enrollment Register',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (hasExistingData)
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.download, color: Colors.white),
                onPressed: _downloadPDF,
                tooltip: 'Download PDF',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Document Upload Section
          _buildDocumentUploadCard(),
          const SizedBox(height: 20),

          // NEW: Driving School Details
          _buildSectionCard(
            'Driving School Details',
            Icons.school,
            const [Color(0xFFFF6F00), Color(0xFFFF8F00)],
            [
              _buildTextField(
                controller: drivingSchoolNameController,
                label: 'Driving School Name *',
                icon: Icons.business,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                capitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: drivingSchoolLicenseController,
                label: 'School License Number *',
                icon: Icons.badge,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                capitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: drivingSchoolAddressController,
                label: 'School Address *',
                icon: Icons.location_on,
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                capitalization: TextCapitalization.words,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Basic Information
          _buildSectionCard(
            'Basic Information',
            Icons.person,
            const [Color(0xFFFFA726), Color(0xFFFFB74D)],
            [
              _buildTextField(
                controller: enrollmentNumberController,
                label: 'Enrollment Number *',
                icon: Icons.numbers,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: traineeNameController,
                label: 'Trainee Name *',
                icon: Icons.person,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                capitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              // NEW: Guardian Name
              _buildTextField(
                controller: guardianNameController,
                label: 'Guardian Name *',
                icon: Icons.family_restroom,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                capitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              // NEW: Guardian Relation Dropdown
              _buildDropdown(
                value: selectedGuardianRelation,
                label: 'Guardian Relation *',
                icon: Icons.people,
                items: const [
                  DropdownMenuItem(value: 'S/O', child: Text('S/O (Son of)')),
                  DropdownMenuItem(
                    value: 'D/O',
                    child: Text('D/O (Daughter of)'),
                  ),
                  DropdownMenuItem(value: 'W/O', child: Text('W/O (Wife of)')),
                ],
                onChanged: (value) {
                  setState(() => selectedGuardianRelation = value!);
                },
              ),
              const SizedBox(height: 16),
              _buildDatePicker(
                date: dateOfBirth,
                label: 'Date of Birth *',
                onTap: () => _selectDate(context, isDateOfBirth: true),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Identity Documents Section
          _buildSectionCard(
            'Identity Documents',
            Icons.credit_card,
            const [Color(0xFFEC407A), Color(0xFFF06292)],
            [
              _buildTextField(
                controller: aadhaarNumberController,
                label: 'Aadhaar Number',
                icon: Icons.credit_card,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: panNumberController,
                label: 'PAN Number',
                icon: Icons.card_membership,
                capitalization: TextCapitalization.characters,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Address Details
          _buildSectionCard(
            'Address Details',
            Icons.location_on,
            const [Color(0xFF42A5F5), Color(0xFF64B5F6)],
            [
              _buildTextField(
                controller: permanentAddressController,
                label: 'Permanent Address *',
                icon: Icons.home,
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                capitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: temporaryAddressController,
                label: 'Temporary/Official Address (Optional)',
                icon: Icons.location_city,
                maxLines: 3,
                capitalization: TextCapitalization.words,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Training Details (UPDATED)
          _buildSectionCard(
            'Training Details',
            Icons.directions_car,
            const [Color(0xFF66BB6A), Color(0xFF81C784)],
            [
              // NEW: Vehicle Classes Multi-Select
              _buildVehicleClassesSelector(),
              const SizedBox(height: 16),
              _buildDatePicker(
                date: enrollmentDate,
                label: 'Date of Enrollment *',
                onTap: () => _selectDate(context, isEnrollmentDate: true),
              ),
              const SizedBox(height: 16),
              // NEW: Training Start Date
              _buildDatePicker(
                date: trainingStartDate,
                label: 'Training Start Date *',
                onTap: () => _selectDate(context, isTrainingStart: true),
              ),
              const SizedBox(height: 16),
              // NEW: Training End Date
              _buildDatePicker(
                date: trainingEndDate,
                label: 'Training End Date *',
                onTap: () => _selectDate(context, isTrainingEnd: true),
              ),
              const SizedBox(height: 16),
              _buildDatePicker(
                date: courseCompletionDate,
                label: 'Course Completion Date (Optional)',
                onTap: () => _selectDate(context, isCourseCompletion: true),
              ),
              const SizedBox(height: 16),
              _buildDatePicker(
                date: testPassDate,
                label: 'Test Pass Date (Optional)',
                onTap: () => _selectDate(context, isTestPass: true),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // License Information
          _buildSectionCard(
            'License Information',
            Icons.badge,
            const [Color(0xFF7E57C2), Color(0xFF9575CD)],
            [
              _buildTextField(
                controller: learnerLicenseController,
                label: 'Learner\'s License Number (Optional)',
                icon: Icons.credit_card,
              ),
              const SizedBox(height: 16),
              _buildDatePicker(
                date: learnerLicenseExpiry,
                label: 'Learner\'s License Expiry (Optional)',
                onTap: () => _selectDate(context, isLearnerExpiry: true),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // NEW: Certification Section
          _buildSectionCard(
            'Certification',
            Icons.verified,
            const [Color(0xFF26A69A), Color(0xFF4DB6AC)],
            [
              _buildTextField(
                controller: instructorNameController,
                label: 'Instructor Name *',
                icon: Icons.person_outline,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                capitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                value: selectedCertifyingAuthority,
                label: 'Certifying Authority *',
                icon: Icons.admin_panel_settings,
                items: const [
                  DropdownMenuItem(
                    value: 'Proprietor',
                    child: Text('Proprietor'),
                  ),
                  DropdownMenuItem(
                    value: 'Head Instructor',
                    child: Text('Head Instructor'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => selectedCertifyingAuthority = value!);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Additional Information
          _buildSectionCard(
            'Additional Information',
            Icons.notes,
            const [Color(0xFFAB47BC), Color(0xFFBA68C8)],
            [
              _buildTextField(
                controller: remarksController,
                label: 'Remarks (Optional)',
                icon: Icons.comment,
                maxLines: 4,
                capitalization: TextCapitalization.sentences,
              ),
            ],
          ),
          const SizedBox(height: 32),

          _buildSubmitButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // NEW: Vehicle Classes Multi-Selector
  Widget _buildVehicleClassesSelector() {
    final allClasses = ['2-Wheeler', '4-Wheeler', 'LMV', 'HMV'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.directions_car,
              color: Color(0xFFFF7043),
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Vehicle Classes *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allClasses.map((vehicleClass) {
            final isSelected = selectedVehicleClasses.contains(vehicleClass);
            return FilterChip(
              label: Text(vehicleClass),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedVehicleClasses.add(vehicleClass);
                  } else {
                    selectedVehicleClasses.remove(vehicleClass);
                  }
                });
              },
              selectedColor: const Color(0xFFFF7043).withOpacity(0.3),
              checkmarkColor: const Color(0xFFFF7043),
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFFFF7043) : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDocumentUploadCard() {
    return Container(
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC407A), Color(0xFFF06292)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Document Uploads',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildImageUploadBox(
            title: 'User Photo',
            file: userPhotoFile,
            existingUrl: existingUserPhotoUrl,
            onTap: () => _showImageSourceDialog('user'),
            gradient: const [Color(0xFF42A5F5), Color(0xFF64B5F6)],
          ),
          const SizedBox(height: 16),
          _buildImageUploadBox(
            title: 'Aadhaar Card Photo',
            file: aadhaarPhotoFile,
            existingUrl: existingAadhaarPhotoUrl,
            onTap: () => _showImageSourceDialog('aadhaar'),
            gradient: const [Color(0xFF66BB6A), Color(0xFF81C784)],
          ),
          const SizedBox(height: 16),
          _buildImageUploadBox(
            title: 'PAN Card Photo',
            file: panPhotoFile,
            existingUrl: existingPanPhotoUrl,
            onTap: () => _showImageSourceDialog('pan'),
            gradient: const [Color(0xFFFFA726), Color(0xFFFFB74D)],
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadBox({
    required String title,
    required File? file,
    required String? existingUrl,
    required VoidCallback onTap,
    required List<Color> gradient,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: gradient[0].withOpacity(0.3), width: 2),
            ),
            child: file != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(file, fit: BoxFit.cover),
                  )
                : existingUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      existingUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            valueColor: AlwaysStoppedAnimation(gradient[0]),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholder(title, gradient),
                    ),
                  )
                : _buildPlaceholder(title, gradient),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(String title, List<Color> gradient) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add_a_photo, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to add $title',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    String title,
    IconData icon,
    List<Color> colors,
    List<Widget> children,
  ) {
    return Container(
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLines,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFFF7043)),
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
          borderSide: const BorderSide(color: Color(0xFFFF7043), width: 2),
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
      maxLines: maxLines,
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
        prefixIcon: Icon(icon, color: const Color(0xFFFF7043)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
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
          borderSide: const BorderSide(color: Color(0xFFFF7043), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        isDense: true,
      ),
      items: items,
      onChanged: onChanged,
      isExpanded: true,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFFFF7043)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                date == null
                    ? label
                    : '${label}: ${date.day}/${date.month}/${date.year}',
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
        gradient: const LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7043).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: isLoading || isUploadingImages ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: isLoading || isUploadingImages
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save, color: Colors.white),
        label: Text(
          isLoading || isUploadingImages
              ? 'Saving...'
              : hasExistingData
              ? 'Update Form-14'
              : 'Submit Form-14',
          style: const TextStyle(
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
    bool isDateOfBirth = false,
    bool isEnrollmentDate = false,
    bool isTrainingStart = false,
    bool isTrainingEnd = false,
    bool isCourseCompletion = false,
    bool isTestPass = false,
    bool isLearnerExpiry = false,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF7043),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isDateOfBirth) dateOfBirth = picked;
        if (isEnrollmentDate) enrollmentDate = picked;
        if (isTrainingStart) trainingStartDate = picked;
        if (isTrainingEnd) trainingEndDate = picked;
        if (isCourseCompletion) courseCompletionDate = picked;
        if (isTestPass) testPassDate = picked;
        if (isLearnerExpiry) learnerLicenseExpiry = picked;
      });
    }
  }

  Future<void> _downloadPDF() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      _showSnackBar('Generating PDF...');

      final snapshot = await FirebaseFirestore.instance
          .collection('form14_enrollment')
          .where('student_id', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        _showSnackBar('No data to download', isError: true);
        return;
      }

      final formData = snapshot.docs.first.data();

      await PDFService.downloadForm14PDF(
        context: context,
        studentName: traineeNameController.text.trim(),
        formData: formData,
        userPhotoUrl: formData['photo_url'],
        aadhaarPhotoUrl: formData['aadhaar_photo_url'],
        panPhotoUrl: formData['pan_photo_url'],
      );

      if (mounted) {
        _showSnackBar('PDF downloaded successfully!');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error generating PDF: $e', isError: true);
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!formKey.currentState!.validate()) return;

    // Validate required dates
    if (dateOfBirth == null ||
        enrollmentDate == null ||
        trainingStartDate == null ||
        trainingEndDate == null) {
      _showSnackBar('Please select all required dates', isError: true);
      return;
    }

    // Validate vehicle classes
    if (selectedVehicleClasses.isEmpty) {
      _showSnackBar('Please select at least one vehicle class', isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Upload all images
      final imageUrls = await _uploadAllImages();

      // Get school ID
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final schoolId = userDoc.data()?['school_id'] ?? '';

      final data = {
        'student_id': user.uid,
        'school_id': schoolId,

        // NEW: Driving school details
        'driving_school_name': drivingSchoolNameController.text.trim(),
        'driving_school_license_number': drivingSchoolLicenseController.text
            .trim(),
        'driving_school_address': drivingSchoolAddressController.text.trim(),

        'enrollment_number': enrollmentNumberController.text.trim(),
        'trainee_name': traineeNameController.text.trim(),

        // NEW: Guardian details
        'guardian_name': guardianNameController.text.trim(),
        'guardian_relation': selectedGuardianRelation,

        'permanent_address': permanentAddressController.text.trim(),
        'temporary_address': temporaryAddressController.text.trim(),
        'date_of_birth': Timestamp.fromDate(dateOfBirth!),

        // NEW: Vehicle classes (list)
        'vehicle_classes': selectedVehicleClasses,

        'enrollment_date': Timestamp.fromDate(enrollmentDate!),

        // NEW: Training period
        'training_start_date': Timestamp.fromDate(trainingStartDate!),
        'training_end_date': Timestamp.fromDate(trainingEndDate!),

        'learner_license_number': learnerLicenseController.text.trim(),
        'learner_license_expiry': learnerLicenseExpiry != null
            ? Timestamp.fromDate(learnerLicenseExpiry!)
            : null,
        'course_completion_date': courseCompletionDate != null
            ? Timestamp.fromDate(courseCompletionDate!)
            : null,
        'test_pass_date': testPassDate != null
            ? Timestamp.fromDate(testPassDate!)
            : null,

        // NEW: Certification
        'instructor_name': instructorNameController.text.trim(),
        'certifying_authority': selectedCertifyingAuthority,

        'remarks': remarksController.text.trim(),
        'aadhaar_number': aadhaarNumberController.text.trim(),
        'pan_number': panNumberController.text.trim(),
        'photo_url': imageUrls['photo_url'],
        'aadhaar_photo_url': imageUrls['aadhaar_photo_url'],
        'pan_photo_url': imageUrls['pan_photo_url'],
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (hasExistingData) {
        // Update existing record
        final snapshot = await FirebaseFirestore.instance
            .collection('form14_enrollment')
            .where('student_id', isEqualTo: user.uid)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          await snapshot.docs.first.reference.update(data);
        }
      } else {
        // Create new record
        data['created_at'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance
            .collection('form14_enrollment')
            .add(data);
      }

      if (mounted) {
        _showSnackBar('Form-14 saved successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}
