import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/utils/validators.dart';

class Form14EnrollmentScreen extends ConsumerStatefulWidget {
  const Form14EnrollmentScreen({super.key});

  @override
  ConsumerState<Form14EnrollmentScreen> createState() =>
      _Form14EnrollmentScreenState();
}

class _Form14EnrollmentScreenState extends ConsumerState<Form14EnrollmentScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _traineeNameController = TextEditingController();
  final _relationNameController = TextEditingController();
  final _permanentAddressController = TextEditingController();
  final _temporaryAddressController = TextEditingController();
  final _enrollmentNumberController = TextEditingController();
  final _learnerLicenseController = TextEditingController();
  final _drivingLicenseController = TextEditingController();
  final _licensingAuthorityController = TextEditingController();
  final _remarksController = TextEditingController();
  final _aadhaarNumberController = TextEditingController();
  final _panNumberController = TextEditingController();

  DateTime? _dateOfBirth;
  DateTime? _enrollmentDate;
  DateTime? _learnerLicenseExpiry;
  DateTime? _courseCompletionDate;
  DateTime? _testPassDate;
  DateTime? _drivingLicenseIssueDate;
  String _selectedVehicleClass = '2-Wheeler';
  bool _isLoading = false;
  bool _hasExistingData = false;

  // Image upload fields
  File? _userPhotoFile;
  File? _aadhaarPhotoFile;
  File? _panPhotoFile;

  String? _existingUserPhotoUrl;
  String? _existingAadhaarPhotoUrl;
  String? _existingPanPhotoUrl;

  bool _isUploadingImages = false;
  final ImagePicker _picker = ImagePicker();

  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

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
    _animationController!.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  Future<void> _loadExistingData() async {
    setState(() => _isLoading = true);
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
          _hasExistingData = true;
          _traineeNameController.text = data['trainee_name'] ?? '';
          _relationNameController.text = data['relation_name'] ?? '';
          _permanentAddressController.text = data['permanent_address'] ?? '';
          _temporaryAddressController.text = data['temporary_address'] ?? '';
          _enrollmentNumberController.text = data['enrollment_number'] ?? '';
          _learnerLicenseController.text = data['learner_license_number'] ?? '';
          _drivingLicenseController.text = data['driving_license_number'] ?? '';
          _licensingAuthorityController.text =
              data['licensing_authority'] ?? '';
          _remarksController.text = data['remarks'] ?? '';
          _aadhaarNumberController.text = data['aadhaar_number'] ?? '';
          _panNumberController.text = data['pan_number'] ?? '';
          _selectedVehicleClass = data['vehicle_class'] ?? '2-Wheeler';

          _existingUserPhotoUrl = data['user_photo_url'];
          _existingAadhaarPhotoUrl = data['aadhaar_photo_url'];
          _existingPanPhotoUrl = data['pan_photo_url'];

          if (data['date_of_birth'] != null) {
            _dateOfBirth = (data['date_of_birth'] as Timestamp).toDate();
          }
          if (data['enrollment_date'] != null) {
            _enrollmentDate = (data['enrollment_date'] as Timestamp).toDate();
          }
          if (data['learner_license_expiry'] != null) {
            _learnerLicenseExpiry =
                (data['learner_license_expiry'] as Timestamp).toDate();
          }
          if (data['course_completion_date'] != null) {
            _courseCompletionDate =
                (data['course_completion_date'] as Timestamp).toDate();
          }
          if (data['test_pass_date'] != null) {
            _testPassDate = (data['test_pass_date'] as Timestamp).toDate();
          }
          if (data['driving_license_issue_date'] != null) {
            _drivingLicenseIssueDate =
                (data['driving_license_issue_date'] as Timestamp).toDate();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error loading data: $e', isError: true);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source, String imageType) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          switch (imageType) {
            case 'user':
              _userPhotoFile = File(pickedFile.path);
              break;
            case 'aadhaar':
              _aadhaarPhotoFile = File(pickedFile.path);
              break;
            case 'pan':
              _panPhotoFile = File(pickedFile.path);
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
    String title = '';
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
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.photo_camera, color: Colors.white, size: 24),
            ),
            SizedBox(width: 12),
            Text('Choose $title'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF42A5F5), Color(0xFF64B5F6)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.photo_camera, color: Colors.white, size: 24),
              ),
              title: Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, imageType);
              },
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF66BB6A), Color(0xFF81C784)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.photo_library, color: Colors.white, size: 24),
              ),
              title: Text('Gallery'),
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
    setState(() => _isUploadingImages = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnackBar('Not signed in', isError: true);
        return {};
      }

      // Force refresh the ID token so Storage sees a fresh, valid token
      try {
        await user.getIdToken(true);
        print('DEBUG: forced idToken refresh for uid=${user.uid}');
      } catch (e) {
        print('DEBUG: getIdToken(true) failed: $e');
      }

      String? userPhotoUrl = _existingUserPhotoUrl;
      String? aadhaarPhotoUrl = _existingAadhaarPhotoUrl;
      String? panPhotoUrl = _existingPanPhotoUrl;

      Future<String?> uploadFileWithFallback(File file, String destPath) async {
        final ref = FirebaseStorage.instance.ref().child(destPath);
        print('DEBUG: Uploading to: ${ref.fullPath} (bucket: ${ref.bucket})');

        try {
          // Primary: resumable upload using putFile
          final uploadTask = await ref.putFile(file);
          final url = await ref.getDownloadURL();
          print('DEBUG: upload succeeded for ${ref.fullPath} url=$url');
          return url;
        } on FirebaseException catch (e, st) {
          print(
            'DEBUG: putFile FirebaseException code=${e.code} message=${e.message}',
          );
          print(st);

          // If resumable upload fails with permission/403 or resumable-specific error, try putData as fallback
          try {
            final bytes = await file.readAsBytes();
            final snap = await ref.putData(bytes);
            final url = await ref.getDownloadURL();
            print(
              'DEBUG: fallback putData succeeded for ${ref.fullPath} url=$url',
            );
            return url;
          } on FirebaseException catch (e2, st2) {
            print(
              'DEBUG: fallback putData FirebaseException code=${e2.code} message=${e2.message}',
            );
            print(st2);
            rethrow; // bubble up so caller can show error
          } catch (e2, st2) {
            print('DEBUG: fallback putData other error: $e2');
            print(st2);
            rethrow;
          }
        } catch (e, st) {
          print('DEBUG: putFile other error: $e');
          print(st);
          rethrow;
        }
      }

      // Upload User Photo
      if (_userPhotoFile != null) {
        final fileName =
            'user_photo_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final dest = 'form14_photos/user/$fileName';
        userPhotoUrl = await uploadFileWithFallback(_userPhotoFile!, dest);
      }

      // Upload Aadhaar Photo
      if (_aadhaarPhotoFile != null) {
        final fileName =
            'aadhaar_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final dest = 'form14_photos/aadhaar/$fileName';
        aadhaarPhotoUrl = await uploadFileWithFallback(
          _aadhaarPhotoFile!,
          dest,
        );
      }

      // Upload PAN Photo
      if (_panPhotoFile != null) {
        final fileName =
            'pan_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final dest = 'form14_photos/pan/$fileName';
        panPhotoUrl = await uploadFileWithFallback(_panPhotoFile!, dest);
      }

      return {
        'user_photo_url': userPhotoUrl,
        'aadhaar_photo_url': aadhaarPhotoUrl,
        'pan_photo_url': panPhotoUrl,
      };
    } catch (e) {
      if (mounted) _showSnackBar('Error uploading images: $e', isError: true);
      return {};
    } finally {
      setState(() => _isUploadingImages = false);
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
            SizedBox(width: 12),
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
  void dispose() {
    _animationController?.dispose();
    _traineeNameController.dispose();
    _relationNameController.dispose();
    _permanentAddressController.dispose();
    _temporaryAddressController.dispose();
    _enrollmentNumberController.dispose();
    _learnerLicenseController.dispose();
    _drivingLicenseController.dispose();
    _licensingAuthorityController.dispose();
    _remarksController.dispose();
    _aadhaarNumberController.dispose();
    _panNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                child: _isLoading
                    ? Center(
                        child: Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  Color(0xFFFF7043),
                                ),
                              ),
                              SizedBox(height: 16),
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
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
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
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Document Upload Section
          _buildDocumentUploadCard(),
          SizedBox(height: 20),

          _buildSectionCard(
            'Basic Information',
            Icons.person,
            [Color(0xFFFFA726), Color(0xFFFFB74D)],
            [
              _buildTextField(
                controller: _enrollmentNumberController,
                label: 'Enrollment Number *',
                icon: Icons.numbers,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _traineeNameController,
                label: 'Trainee Name *',
                icon: Icons.person,
                validator: Validators.validateName,
                capitalization: TextCapitalization.words,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _relationNameController,
                label: 'Son/Wife/Daughter of *',
                icon: Icons.family_restroom,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                capitalization: TextCapitalization.words,
              ),
              SizedBox(height: 16),
              _buildDatePicker(
                date: _dateOfBirth,
                label: 'Date of Birth *',
                onTap: () => _selectDate(context, isDateOfBirth: true),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Identity Documents Section
          _buildSectionCard(
            'Identity Documents',
            Icons.credit_card,
            [Color(0xFFEC407A), Color(0xFFF06292)],
            [
              _buildTextField(
                controller: _aadhaarNumberController,
                label: 'Aadhaar Number (Optional)',
                icon: Icons.credit_card,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _panNumberController,
                label: 'PAN Number (Optional)',
                icon: Icons.card_membership,
                capitalization: TextCapitalization.characters,
              ),
            ],
          ),
          SizedBox(height: 20),

          _buildSectionCard(
            'Address Details',
            Icons.location_on,
            [Color(0xFF42A5F5), Color(0xFF64B5F6)],
            [
              _buildTextField(
                controller: _permanentAddressController,
                label: 'Permanent Address *',
                icon: Icons.home,
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                capitalization: TextCapitalization.words,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _temporaryAddressController,
                label: 'Temporary/Official Address (Optional)',
                icon: Icons.location_city,
                maxLines: 3,
                capitalization: TextCapitalization.words,
              ),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(height: 20),
          _buildSectionCard(
            'Training Details',
            Icons.directions_car,
            [const Color(0xFF66BB6A), const Color(0xFF81C784)],
            [
              SizedBox(
                width: double.infinity,
                child: _buildDropdown(
                  value: _selectedVehicleClass,
                  label: 'Class of Vehicle *',
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
                      value: 'LMV',
                      child: Text('LMV (Light Motor Vehicle)'),
                    ),
                    DropdownMenuItem(
                      value: 'HMV',
                      child: Text('HMV (Heavy Motor Vehicle)'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedVehicleClass = value!);
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildDatePicker(
                date: _enrollmentDate,
                label: 'Date of Enrollment *',
                onTap: () => _selectDate(context, isEnrollmentDate: true),
              ),
              const SizedBox(height: 16),
              _buildDatePicker(
                date: _courseCompletionDate,
                label: 'Course Completion Date (Optional)',
                onTap: () => _selectDate(context, isCourseCompletion: true),
              ),
              const SizedBox(height: 16),
              _buildDatePicker(
                date: _testPassDate,
                label: 'Test Pass Date (Optional)',
                onTap: () => _selectDate(context, isTestPass: true),
              ),
            ],
          ),

          SizedBox(height: 20),
          _buildSectionCard(
            'License Information',
            Icons.badge,
            [Color(0xFF7E57C2), Color(0xFF9575CD)],
            [
              _buildTextField(
                controller: _learnerLicenseController,
                label: "Learner's License Number (Optional)",
                icon: Icons.credit_card,
              ),
              SizedBox(height: 16),
              _buildDatePicker(
                date: _learnerLicenseExpiry,
                label: "Learner's License Expiry (Optional)",
                onTap: () => _selectDate(context, isLearnerExpiry: true),
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _drivingLicenseController,
                label: 'Driving License Number (Optional)',
                icon: Icons.card_membership,
              ),
              SizedBox(height: 16),
              _buildDatePicker(
                date: _drivingLicenseIssueDate,
                label: 'License Issue Date (Optional)',
                onTap: () => _selectDate(context, isLicenseIssue: true),
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _licensingAuthorityController,
                label: 'Licensing Authority (Optional)',
                icon: Icons.account_balance,
                capitalization: TextCapitalization.words,
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildSectionCard(
            'Additional Information',
            Icons.notes,
            [Color(0xFFAB47BC), Color(0xFFBA68C8)],
            [
              _buildTextField(
                controller: _remarksController,
                label: 'Remarks (Optional)',
                icon: Icons.comment,
                maxLines: 4,
                capitalization: TextCapitalization.sentences,
              ),
            ],
          ),
          SizedBox(height: 32),
          _buildSubmitButton(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadCard() {
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
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFEC407A), Color(0xFFF06292)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Document Uploads',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // User Photo
            _buildImageUploadBox(
              title: 'User Photo',
              file: _userPhotoFile,
              existingUrl: _existingUserPhotoUrl,
              onTap: () => _showImageSourceDialog('user'),
              gradient: [Color(0xFF42A5F5), Color(0xFF64B5F6)],
            ),
            SizedBox(height: 16),

            // Aadhaar Card Photo
            _buildImageUploadBox(
              title: 'Aadhaar Card Photo',
              file: _aadhaarPhotoFile,
              existingUrl: _existingAadhaarPhotoUrl,
              onTap: () => _showImageSourceDialog('aadhaar'),
              gradient: [Color(0xFF66BB6A), Color(0xFF81C784)],
            ),
            SizedBox(height: 16),

            // PAN Card Photo
            _buildImageUploadBox(
              title: 'PAN Card Photo',
              file: _panPhotoFile,
              existingUrl: _existingPanPhotoUrl,
              onTap: () => _showImageSourceDialog('pan'),
              gradient: [Color(0xFFFFA726), Color(0xFFFFB74D)],
            ),
          ],
        ),
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
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.image, color: Colors.white, size: 16),
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
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
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder(title, gradient);
                      },
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
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.add_a_photo, color: Colors.white, size: 28),
        ),
        SizedBox(height: 8),
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
          mainAxisSize: MainAxisSize.min,
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
    int? maxLines,
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
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 56, // fixed height to prevent overflow
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFFFF7043)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ), // reduced padding
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
          isDense: true, // makes the field more compact
        ),
        items: items,
        onChanged: onChanged,
        isExpanded: true, // ensures text doesn't overflow horizontally
      ),
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
                    ? label
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
        onPressed: (_isLoading || _isUploadingImages) ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: (_isLoading || _isUploadingImages)
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save, color: Colors.white),
        label: Text(
          (_isLoading || _isUploadingImages)
              ? 'Saving...'
              : _hasExistingData
              ? 'Update Form-14'
              : 'Submit Form-14',
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
    bool isDateOfBirth = false,
    bool isEnrollmentDate = false,
    bool isCourseCompletion = false,
    bool isTestPass = false,
    bool isLearnerExpiry = false,
    bool isLicenseIssue = false,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
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
        if (isDateOfBirth) _dateOfBirth = picked;
        if (isEnrollmentDate) _enrollmentDate = picked;
        if (isCourseCompletion) _courseCompletionDate = picked;
        if (isTestPass) _testPassDate = picked;
        if (isLearnerExpiry) _learnerLicenseExpiry = picked;
        if (isLicenseIssue) _drivingLicenseIssueDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dateOfBirth == null || _enrollmentDate == null) {
      _showSnackBar(
        'Please select Date of Birth and Enrollment Date',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

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
        'enrollment_number': _enrollmentNumberController.text.trim(),
        'trainee_name': _traineeNameController.text.trim(),
        'relation_name': _relationNameController.text.trim(),
        'permanent_address': _permanentAddressController.text.trim(),
        'temporary_address': _temporaryAddressController.text.trim(),
        'date_of_birth': Timestamp.fromDate(_dateOfBirth!),
        'vehicle_class': _selectedVehicleClass,
        'enrollment_date': Timestamp.fromDate(_enrollmentDate!),
        'learner_license_number': _learnerLicenseController.text.trim(),
        'learner_license_expiry': _learnerLicenseExpiry != null
            ? Timestamp.fromDate(_learnerLicenseExpiry!)
            : null,
        'course_completion_date': _courseCompletionDate != null
            ? Timestamp.fromDate(_courseCompletionDate!)
            : null,
        'test_pass_date': _testPassDate != null
            ? Timestamp.fromDate(_testPassDate!)
            : null,
        'driving_license_number': _drivingLicenseController.text.trim(),
        'driving_license_issue_date': _drivingLicenseIssueDate != null
            ? Timestamp.fromDate(_drivingLicenseIssueDate!)
            : null,
        'licensing_authority': _licensingAuthorityController.text.trim(),
        'remarks': _remarksController.text.trim(),
        'aadhaar_number': _aadhaarNumberController.text.trim(),
        'pan_number': _panNumberController.text.trim(),
        'user_photo_url': imageUrls['user_photo_url'],
        'aadhaar_photo_url': imageUrls['aadhaar_photo_url'],
        'pan_photo_url': imageUrls['pan_photo_url'],
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (_hasExistingData) {
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
        setState(() => _isLoading = false);
      }
    }
  }
}
