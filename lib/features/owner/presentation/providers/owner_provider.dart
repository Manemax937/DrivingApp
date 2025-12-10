import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/firebase_service.dart';
import '../../domain/entities/student.dart';

// Owner State
class OwnerState {
  final bool isLoading;
  final String? error;
  final List<Student> students;
  final String? selectedFilter;
  final String? selectedCourse;

  OwnerState({
    this.isLoading = false,
    this.error,
    this.students = const [],
    this.selectedFilter,
    this.selectedCourse,
  });

  OwnerState copyWith({
    bool? isLoading,
    String? error,
    List<Student>? students,
    String? selectedFilter,
    String? selectedCourse,
  }) {
    return OwnerState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      students: students ?? this.students,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedCourse: selectedCourse ?? this.selectedCourse,
    );
  }
}

// Owner Notifier
class OwnerNotifier extends StateNotifier<OwnerState> {
  final FirebaseFirestore _firestore;

  OwnerNotifier({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseService.firestore,
      super(OwnerState());

  Future<void> fetchStudents() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final snapshot = await _firestore
          .collection(FirebaseService.studentsCollection)
          .where('school_id', isEqualTo: user.uid)
          .get();

      final students = snapshot.docs.map((doc) {
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

      state = state.copyWith(isLoading: false, students: students);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void applyFilters({String? courseType, String? status, String? batchTiming}) {
    state = state.copyWith(selectedCourse: courseType, selectedFilter: status);
  }

  void clearFilters() {
    state = state.copyWith(selectedCourse: null, selectedFilter: null);
  }

  Future<void> refresh() async {
    await fetchStudents();
  }

  Future<void> generateQRCode(String schoolId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final now = DateTime.now();
      final validUntil = now.add(const Duration(days: 30));
      final qrId = 'qr-${DateTime.now().millisecondsSinceEpoch}';

      await _firestore
          .collection(FirebaseService.qrCodesCollection)
          .doc(qrId)
          .set({
            'school_id': schoolId,
            'qr_payload': qrId,
            'valid_from': Timestamp.fromDate(now),
            'valid_until': Timestamp.fromDate(validUntil),
            'is_active': true,
            'created_at': FieldValue.serverTimestamp(),
          });

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Provider
final ownerProvider = StateNotifierProvider<OwnerNotifier, OwnerState>((ref) {
  return OwnerNotifier();
});
