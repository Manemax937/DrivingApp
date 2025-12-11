import 'package:driveapp/features/owner/presentation/screens/owner_profile_screen.dart';
import 'package:driveapp/features/owner/presentation/screens/owner_view_attendance_screen.dart';
import 'package:driveapp/features/owner/presentation/screens/owner_view_form14_screen.dart';
import 'package:driveapp/features/owner/presentation/screens/owner_view_form15_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/presentation/providers/firebase_auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/student.dart';

class OwnerDashboardScreen extends ConsumerStatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  ConsumerState<OwnerDashboardScreen> createState() =>
      _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends ConsumerState<OwnerDashboardScreen>
    with TickerProviderStateMixin {
  String? _selectedCourse;
  String? _selectedStatus;

  // Animation Controllers
  AnimationController? _animationController;
  AnimationController? _cardAnimationController;
  AnimationController? _fabController;

  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _scaleAnimation;
  Animation<double>? _fabScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController!,
            curve: Curves.easeOutCubic,
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _cardAnimationController!, curve: Curves.easeOut),
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController!, curve: Curves.elasticOut),
    );

    _animationController!.forward();
    _cardAnimationController!.forward();

    Future.delayed(Duration(milliseconds: 400), () {
      if (mounted) _fabController!.forward();
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _cardAnimationController?.dispose();
    _fabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentsStream = ref.watch(studentsStreamProvider);
    final schoolInfo = ref.watch(ownerSchoolProvider);

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
              _buildSchoolHeader(schoolInfo),
              Expanded(
                child: studentsStream.when(
                  data: (students) => _buildDashboardContent(students),
                  loading: () => Center(
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
                            'Loading students...',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  error: (error, stack) => _buildErrorWidget(error.toString()),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation!,
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/owner/admission'),
          icon: const Icon(Icons.person_add),
          label: const Text(
            'New Admission',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color(0xFFFF7043),
          elevation: 8,
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Dashboard',
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
          Row(
            children: [
              // Profile Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.person, color: Colors.white),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OwnerProfileScreen(),
                    ),
                  ),
                  tooltip: 'Profile',
                ),
              ),
              SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.qr_code, color: Colors.white),
                  onPressed: () => context.push('/owner/qr-code'),
                  tooltip: 'QR Code',
                ),
              ),
              SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () => _handleLogout(context),
                  tooltip: 'Logout',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolHeader(AsyncValue<SchoolInfo?> schoolInfo) {
    return schoolInfo.when(
      data: (info) {
        if (info == null) {
          return SizedBox.shrink();
        }
        return ScaleTransition(
          scale: _scaleAnimation!,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.school, color: Colors.white, size: 28),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      if (info.address != null && info.address!.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          info.address!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        margin: EdgeInsets.all(20),
        child: LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.white.withOpacity(0.5)),
          backgroundColor: Colors.white.withOpacity(0.2),
        ),
      ),
      error: (e, _) => SizedBox.shrink(),
    );
  }

  Widget _buildDashboardContent(List<Student> students) {
    return FadeTransition(
      opacity: _fadeAnimation!,
      child: SlideTransition(
        position: _slideAnimation!,
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildStatisticsSection(students),
            _buildFilterSection(),
            Expanded(
              child: students.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () async {
                        setState(() {});
                      },
                      color: Color(0xFFFF7043),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          return TweenAnimationBuilder<double>(
                            duration: Duration(
                              milliseconds: 300 + (index * 50),
                            ),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(opacity: value, child: child),
                              );
                            },
                            child: _buildStudentCard(students[index]),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  student.fullName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      student.phone,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _deleteStudent(context, student),
                tooltip: 'Remove Student',
              ),
            ],
          ),
          Divider(height: 24, color: Colors.grey[300]),
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  Icons.directions_car,
                  student.courseType,
                  [Color(0xFF42A5F5), Color(0xFF64B5F6)],
                ),
              ),
              SizedBox(width: 8),
              if (student.batchTiming != null)
                Expanded(
                  child: _buildInfoChip(
                    Icons.access_time,
                    student.batchTiming!,
                    [Color(0xFFAB47BC), Color(0xFFBA68C8)],
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  Icons.currency_rupee,
                  '${student.feesAmount.toStringAsFixed(0)}',
                  [Color(0xFF66BB6A), Color(0xFF81C784)],
                ),
              ),
              SizedBox(width: 8),
              _buildPaymentStatusChip(student.paymentStatus),
            ],
          ),
          SizedBox(height: 12),
          // Form and Attendance buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OwnerViewForm14Screen(
                          studentId: student.userId,
                          studentName: student.fullName,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.description, size: 16),
                  label: const Text(
                    'Form-14',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF42A5F5),
                      width: 1.5,
                    ),
                    foregroundColor: const Color(0xFF42A5F5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OwnerViewForm15Screen(
                          studentId: student.userId,
                          studentName: student.fullName,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.access_time, size: 16),
                  label: const Text(
                    'Form-15',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFFEC407A),
                      width: 1.5,
                    ),
                    foregroundColor: const Color(0xFFEC407A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OwnerViewAttendanceScreen(
                          studentId: student.userId,
                          studentName: student.fullName,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: const Text(
                    'Attendance',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF66BB6A),
                      width: 1.5,
                    ),
                    foregroundColor: const Color(0xFF66BB6A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, List<Color> colors) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors.map((c) => c.withOpacity(0.15)).toList(),
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors[0].withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors[0]),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors[0],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(List<Student> students) {
    final totalStudents = students.length;
    final paidCount = students
        .where((s) => s.paymentStatus == 'Fully Paid')
        .length;
    final pendingCount = students
        .where((s) => s.paymentStatus == 'Pending')
        .length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total',
              totalStudents.toString(),
              Icons.people,
              [Color(0xFF42A5F5), Color(0xFF64B5F6)],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Paid',
              paidCount.toString(),
              Icons.check_circle,
              [Color(0xFF66BB6A), Color(0xFF81C784)],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Pending',
              pendingCount.toString(),
              Icons.pending,
              [Color(0xFFFFA726), Color(0xFFFFB74D)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    List<Color> colors,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colors[0].withOpacity(0.4),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              'All',
              _selectedCourse == null && _selectedStatus == null,
              () {
                setState(() {
                  _selectedCourse = null;
                  _selectedStatus = null;
                });
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip('2-Wheeler', _selectedCourse == '2-Wheeler', () {
              setState(() {
                _selectedCourse = '2-Wheeler';
                _selectedStatus = null;
              });
            }),
            const SizedBox(width: 8),
            _buildFilterChip('4-Wheeler', _selectedCourse == '4-Wheeler', () {
              setState(() {
                _selectedCourse = '4-Wheeler';
                _selectedStatus = null;
              });
            }),
            const SizedBox(width: 8),
            _buildFilterChip('Pending', _selectedStatus == 'Pending', () {
              setState(() {
                _selectedCourse = null;
                _selectedStatus = 'Pending';
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(colors: [Color(0xFFFFA726), Color(0xFFFF7043)])
              : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : Color(0xFFFF7043).withOpacity(0.3),
            width: 2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Color(0xFFFF7043).withOpacity(0.4),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : Color(0xFFFF7043),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentStatusChip(String status) {
    List<Color> colors;
    switch (status) {
      case 'Fully Paid':
        colors = [Color(0xFF66BB6A), Color(0xFF81C784)];
        break;
      case 'Partially Paid':
        colors = [Color(0xFFFFA726), Color(0xFFFFB74D)];
        break;
      default:
        colors = [Color(0xFFEF5350), Color(0xFFE57373)];
    }

    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.4),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          status,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
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
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.school, size: 64, color: Colors.grey[400]),
            ),
            const SizedBox(height: 20),
            Text(
              'No students yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first student to get started',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: () => context.push('/owner/admission'),
                icon: const Icon(Icons.person_add),
                label: const Text(
                  'Add Student',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
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
                  colors: [Color(0xFFEF5350), Color(0xFFE57373)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: () => setState(() {}),
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'Retry',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteStudent(BuildContext context, Student student) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEF5350), Color(0xFFE57373)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.delete, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Text('Remove Student'),
          ],
        ),
        content: Text(
          'Are you sure you want to remove ${student.fullName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEF5350), Color(0xFFE57373)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Remove',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(student.id)
          .delete();

      if (student.userId.isNotEmpty) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(student.userId)
              .delete();
        } catch (e) {
          debugPrint('Error deleting user: $e');
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('${student.fullName} removed successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
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
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEF5350), Color(0xFFE57373)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.logout, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await ref.read(authProvider.notifier).logout();
      context.go('/login');
    }
  }
}

// Providers remain the same
final ownerSchoolProvider = FutureProvider.autoDispose<SchoolInfo?>((
  ref,
) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return SchoolInfo(id: 'unknown', name: 'Your School', address: null);
  }

  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();
  final schoolId = userDoc.data()?['school_id'] as String? ?? user.uid;

  final schoolDoc = await FirebaseFirestore.instance
      .collection('schools')
      .doc(schoolId)
      .get();

  if (!schoolDoc.exists) {
    return SchoolInfo(id: schoolId, name: 'Your School', address: null);
  }
  final data = schoolDoc.data()!;
  return SchoolInfo(
    id: schoolDoc.id,
    name: (data['name'] as String?)?.trim().isNotEmpty == true
        ? data['name'] as String
        : 'Your School',
    address: (data['address'] as String?)?.trim().isNotEmpty == true
        ? data['address'] as String
        : null,
  );
});

class SchoolInfo {
  final String id;
  final String name;
  final String? address;

  SchoolInfo({required this.id, required this.name, this.address});
}

final studentsStreamProvider = StreamProvider.autoDispose<List<Student>>((
  ref,
) async* {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    yield [];
    return;
  }

  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();
  final schoolId = userDoc.data()?['school_id'] as String? ?? user.uid;

  yield* FirebaseFirestore.instance
      .collection('students')
      .where('school_id', isEqualTo: schoolId)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return Student(
            id: doc.id,
            userId: data['user_id'] ?? '',
            schoolId: data['school_id'] ?? '',
            fullName: data['full_name'] ?? '',
            phone: data['phone'] ?? '',
            email: data['email'],
            fatherName: data['father_name'],
            address: data['address'],
            courseType: data['course_type'] ?? '',
            licenseType: data['license_type'],
            batchTiming: data['batch_timing'],
            feesAmount: (data['fees_amount'] ?? 0).toDouble(),
            paymentStatus: data['payment_status'] ?? 'Pending',
            trainingStartDate: data['training_start_date'] != null
                ? (data['training_start_date'] as Timestamp).toDate()
                : null,
            trainingEndDate: data['training_end_date'] != null
                ? (data['training_end_date'] as Timestamp).toDate()
                : null,
          );
        }).toList();
      });
});
