import 'package:driveapp/core/services/pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/date_formatter.dart';

class OwnerViewForm14Screen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const OwnerViewForm14Screen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<OwnerViewForm14Screen> createState() => _OwnerViewForm14ScreenState();
}

class _OwnerViewForm14ScreenState extends State<OwnerViewForm14Screen> {
  Map<String, dynamic>? _formData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('form14_enrollment')
          .where('student_id', isEqualTo: widget.studentId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _formData = snapshot.docs.first.data();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
              _buildAppBar(),
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
                                'Loading Form-14...',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _formData == null
                    ? _buildEmptyState()
                    : _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
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
                  widget.studentName,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Download Button
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

  Future<void> _downloadPDF() async {
    if (_formData == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No data to download')));
      return;
    }

    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Generating PDF...')));

      await PDFService.downloadForm14PDF(
        context: context, // Add this
        studentName: widget.studentName,
        formData: _formData!,
        userPhotoUrl: _formData!['user_photo_url'],
        aadhaarPhotoUrl: _formData!['aadhaar_photo_url'],
        panPhotoUrl: _formData!['pan_photo_url'],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF downloaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadFormData,
      color: Color(0xFFFF7043),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Document Photos
          _buildPhotoSection(),
          SizedBox(height: 20),

          // Basic Information
          _buildInfoCard(
            'Basic Information',
            Icons.person,
            [Color(0xFFFFA726), Color(0xFFFFB74D)],
            [
              _buildInfoRow(
                'Enrollment Number',
                _formData!['enrollment_number'],
              ),
              _buildInfoRow('Trainee Name', _formData!['trainee_name']),
              _buildInfoRow(
                'Son/Wife/Daughter of',
                _formData!['relation_name'],
              ),
              _buildInfoRow(
                'Date of Birth',
                _formatDate(_formData!['date_of_birth']),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Identity Documents
          _buildInfoCard(
            'Identity Documents',
            Icons.credit_card,
            [Color(0xFFEC407A), Color(0xFFF06292)],
            [
              _buildInfoRow('Aadhaar Number', _formData!['aadhaar_number']),
              _buildInfoRow('PAN Number', _formData!['pan_number']),
            ],
          ),
          SizedBox(height: 16),

          // Address
          _buildInfoCard(
            'Address Details',
            Icons.location_on,
            [Color(0xFF42A5F5), Color(0xFF64B5F6)],
            [
              _buildInfoRow(
                'Permanent Address',
                _formData!['permanent_address'],
              ),
              _buildInfoRow(
                'Temporary Address',
                _formData!['temporary_address'],
              ),
            ],
          ),
          SizedBox(height: 16),

          // Training Details
          _buildInfoCard(
            'Training Details',
            Icons.directions_car,
            [Color(0xFF66BB6A), Color(0xFF81C784)],
            [
              _buildInfoRow('Vehicle Class', _formData!['vehicle_class']),
              _buildInfoRow(
                'Enrollment Date',
                _formatDate(_formData!['enrollment_date']),
              ),
              _buildInfoRow(
                'Course Completion',
                _formatDate(_formData!['course_completion_date']),
              ),
              _buildInfoRow(
                'Test Pass Date',
                _formatDate(_formData!['test_pass_date']),
              ),
            ],
          ),
          SizedBox(height: 16),

          // License Information
          _buildInfoCard(
            'License Information',
            Icons.badge,
            [Color(0xFF7E57C2), Color(0xFF9575CD)],
            [
              _buildInfoRow(
                "Learner's License",
                _formData!['learner_license_number'],
              ),
              _buildInfoRow(
                'License Expiry',
                _formatDate(_formData!['learner_license_expiry']),
              ),
              _buildInfoRow(
                'Driving License',
                _formData!['driving_license_number'],
              ),
              _buildInfoRow(
                'License Issue Date',
                _formatDate(_formData!['driving_license_issue_date']),
              ),
              _buildInfoRow(
                'Licensing Authority',
                _formData!['licensing_authority'],
              ),
            ],
          ),
          SizedBox(height: 16),

          // Remarks
          if (_formData!['remarks'] != null &&
              _formData!['remarks'].toString().trim().isNotEmpty)
            _buildInfoCard(
              'Additional Information',
              Icons.notes,
              [Color(0xFFAB47BC), Color(0xFFBA68C8)],
              [_buildInfoRow('Remarks', _formData!['remarks'])],
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    final userPhoto = _formData!['user_photo_url'];
    final aadhaarPhoto = _formData!['aadhaar_photo_url'];
    final panPhoto = _formData!['pan_photo_url'];

    if (userPhoto == null && aadhaarPhoto == null && panPhoto == null) {
      return SizedBox.shrink();
    }

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
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFEC407A), Color(0xFFF06292)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.photo_library, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'Documents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          if (userPhoto != null) _buildPhotoTile('User Photo', userPhoto),
          if (aadhaarPhoto != null)
            _buildPhotoTile('Aadhaar Card', aadhaarPhoto),
          if (panPhoto != null) _buildPhotoTile('PAN Card', panPhoto),
        ],
      ),
    );
  }

  Widget _buildPhotoTile(String label, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showFullImage(url),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                url,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor: AlwaysStoppedAnimation(Color(0xFFFF7043)),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: Icon(Icons.error, color: Colors.red),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImage(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            InteractiveViewer(child: Image.network(url)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
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
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    if (value == null || (value is String && value.trim().isEmpty)) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(32),
        padding: EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFA726).withOpacity(0.2),
                    Color(0xFFFF7043).withOpacity(0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description,
                size: 64,
                color: Color(0xFFFF7043),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Form-14 Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This student has not filled Form-14 yet',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Timestamp) {
      return DateFormatter.formatDate(timestamp.toDate());
    }
    return 'N/A';
  }
}
