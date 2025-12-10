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

class _OwnerDashboardScreenState extends ConsumerState<OwnerDashboardScreen> {
  String? _selectedCourse;
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final studentsStream = ref.watch(studentsStreamProvider);
    final schoolInfo = ref.watch(ownerSchoolProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            tooltip: 'QR Code',
            onPressed: () => context.push('/owner/qr-code'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSchoolHeader(schoolInfo),
          Expanded(
            child: studentsStream.when(
              data: (students) => _buildDashboardContent(students),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorWidget(error.toString()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/owner/admission'),
        icon: const Icon(Icons.person_add),
        label: const Text('New Admission'),
      ),
    );
  }

  Widget _buildDashboardContent(List<Student> students) {
    return Column(
      children: [
        const SizedBox(height: 8),
        _buildStatisticsSection(students),
        _buildFilterSection(),
        Expanded(
          child: students.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async {
                    // Refresh handled by stream automatically
                    setState(() {});
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Text(
                              student.fullName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          title: Text(
                            student.fullName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('📱 ${student.phone}'),
                              Text('🚗 ${student.courseType}'),
                              if (student.batchTiming != null)
                                Text('⏰ ${student.batchTiming}'),
                              Text(
                                '💰 ₹${student.feesAmount.toStringAsFixed(0)}',
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildPaymentStatusChip(student.paymentStatus),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _deleteStudent(context, student),
                                tooltip: 'Remove Student',
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Students',
              totalStudents.toString(),
              Icons.people,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Paid',
              paidCount.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Pending',
              pendingCount.toString(),
              Icons.pending,
              Colors.orange,
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
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('All'),
              selected: _selectedCourse == null && _selectedStatus == null,
              onSelected: (_) {
                setState(() {
                  _selectedCourse = null;
                  _selectedStatus = null;
                });
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('2-Wheeler'),
              selected: _selectedCourse == '2-Wheeler',
              onSelected: (_) {
                setState(() {
                  _selectedCourse = '2-Wheeler';
                  _selectedStatus = null;
                });
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('4-Wheeler'),
              selected: _selectedCourse == '4-Wheeler',
              onSelected: (_) {
                setState(() {
                  _selectedCourse = '4-Wheeler';
                  _selectedStatus = null;
                });
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Pending Payment'),
              selected: _selectedStatus == 'Pending',
              onSelected: (_) {
                setState(() {
                  _selectedCourse = null;
                  _selectedStatus = 'Pending';
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Fully Paid':
        color = Colors.green;
        break;
      case 'Partially Paid':
        color = Colors.orange;
        break;
      default:
        color = Colors.red;
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(fontSize: 11, color: Colors.white),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No students found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first student to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/owner/admission'),
            icon: const Icon(Icons.person_add),
            label: const Text('Add Student'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text('Error', style: TextStyle(fontSize: 18, color: Colors.red[700])),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStudent(BuildContext context, Student student) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Student'),
        content: Text(
          'Are you sure you want to remove ${student.fullName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    try {
      // Delete student document from Firestore
      await FirebaseFirestore.instance
          .collection('students')
          .doc(student.id)
          .delete();

      // Optionally, also delete the user account if exists
      if (student.userId.isNotEmpty) {
        try {
          // Delete user document
          await FirebaseFirestore.instance
              .collection('users')
              .doc(student.userId)
              .delete();
        } catch (e) {
          // User might not exist, ignore error
          debugPrint('Error deleting user: $e');
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${student.fullName} has been removed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing student: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
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

/// Provider to fetch current owner's school info (name/address)
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
    // Avoid indefinite loading by returning a fallback
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

extension _SchoolHeader on _OwnerDashboardScreenState {
  Widget _buildSchoolHeader(AsyncValue<SchoolInfo?> schoolInfo) {
    return schoolInfo.when(
      data: (info) {
        if (info == null) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'School: Loading...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          );
        }
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (info.address != null && info.address!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    info.address!,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 16,
            width: 120,
            child: LinearProgressIndicator(minHeight: 3),
          ),
        ),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Could not load school info',
          style: TextStyle(color: Colors.red[700]),
        ),
      ),
    );
  }
}

// Firebase Stream Provider - SIMPLER VERSION
final studentsStreamProvider = StreamProvider.autoDispose<List<Student>>((
  ref,
) async* {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    yield [];
    return;
  }

  // Fetch schoolId from users/{uid} to ensure isolation
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
