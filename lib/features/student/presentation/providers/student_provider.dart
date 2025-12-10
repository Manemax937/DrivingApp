import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/firebase_service.dart';
import '../../domain/entities/attendance.dart';

class StudentState {
  final bool isLoading;
  final String? error;
  final bool attendanceMarked;
  final String? attendanceMessage;
  final List<Attendance> attendanceList;

  StudentState({
    this.isLoading = false,
    this.error,
    this.attendanceMarked = false,
    this.attendanceMessage,
    this.attendanceList = const [],
  });

  StudentState copyWith({
    bool? isLoading,
    String? error,
    bool? attendanceMarked,
    String? attendanceMessage,
    List<Attendance>? attendanceList,
  }) {
    return StudentState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      attendanceMarked: attendanceMarked ?? this.attendanceMarked,
      attendanceMessage: attendanceMessage,
      attendanceList: attendanceList ?? this.attendanceList,
    );
  }
}

class StudentNotifier extends StateNotifier<StudentState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StudentNotifier({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseService.firestore,
      _auth = auth ?? FirebaseService.auth,
      super(StudentState());

  Future<void> markAttendance(String qrData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          attendanceMarked: false,
          attendanceMessage: 'User not authenticated',
        );
        return;
      }

      final qrDoc = await _firestore
          .collection(FirebaseService.qrCodesCollection)
          .doc(qrData)
          .get();

      if (!qrDoc.exists) {
        state = state.copyWith(
          isLoading: false,
          attendanceMarked: false,
          attendanceMessage: 'Invalid QR code',
        );
        return;
      }

      final qrCodeData = qrDoc.data()!;
      final validUntil = (qrCodeData['valid_until'] as Timestamp).toDate();
      final now = DateTime.now();

      if (now.isAfter(validUntil)) {
        state = state.copyWith(
          isLoading: false,
          attendanceMarked: false,
          attendanceMessage: 'QR code has expired. Ask admin for new QR.',
        );
        return;
      }

      if (qrCodeData['is_active'] != true) {
        state = state.copyWith(
          isLoading: false,
          attendanceMarked: false,
          attendanceMessage: 'QR code is not active',
        );
        return;
      }

      final hour = now.hour;
      if (hour < 6 || hour >= 21) {
        state = state.copyWith(
          isLoading: false,
          attendanceMarked: false,
          attendanceMessage: 'Attendance window closed (6 AM - 9 PM).',
        );
        return;
      }

      final today = DateTime(now.year, now.month, now.day);
      final attendanceQuery = await _firestore
          .collection(FirebaseService.attendanceCollection)
          .where('student_id', isEqualTo: user.uid)
          .where('date', isEqualTo: Timestamp.fromDate(today))
          .limit(1)
          .get();

      if (attendanceQuery.docs.isNotEmpty) {
        state = state.copyWith(
          isLoading: false,
          attendanceMarked: false,
          attendanceMessage: 'Attendance already marked for today.',
        );
        return;
      }

      final deviceInfo = {
        'timestamp': now.toIso8601String(),
        'platform': 'mobile',
      };

      final attendanceDoc = _firestore
          .collection(FirebaseService.attendanceCollection)
          .doc();

      await attendanceDoc.set({
        'student_id': user.uid,
        'school_id': qrCodeData['school_id'],
        'instructor_id': null,
        'qr_code_id': qrData,
        'date': Timestamp.fromDate(today),
        'marked_at': FieldValue.serverTimestamp(),
        'method': 'QR',
        'device_info': deviceInfo,
      });

      state = state.copyWith(
        isLoading: false,
        attendanceMarked: true,
        attendanceMessage: 'Attendance marked successfully!',
      );

      await fetchAttendance(user.uid);
    } on FirebaseException catch (e) {
      state = state.copyWith(
        isLoading: false,
        attendanceMarked: false,
        attendanceMessage: 'Firebase error: ${e.message}',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        attendanceMarked: false,
        attendanceMessage: 'Error: ${e.toString()}',
      );
    }
  }

  Future<void> fetchAttendance(String studentId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final snapshot = await _firestore
          .collection(FirebaseService.attendanceCollection)
          .where('student_id', isEqualTo: studentId)
          .orderBy('date', descending: true)
          .limit(100)
          .get();

      final attendanceList = snapshot.docs.map((doc) {
        final data = doc.data();
        return Attendance(
          id: doc.id,
          studentId: data['student_id'] ?? '',
          schoolId: data['school_id'] ?? '',
          instructorId: data['instructor_id'],
          attendanceDate:
              (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
          markedAt:
              (data['marked_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
          method: data['method'] ?? 'QR',
          qrCodeId: data['qr_code_id'],
          deviceInfo: data['device_info'] != null
              ? Map<String, dynamic>.from(data['device_info'])
              : null,
        );
      }).toList();

      state = state.copyWith(isLoading: false, attendanceList: attendanceList);
    } on FirebaseException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch attendance: ${e.message}',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearMessage() {
    state = state.copyWith(
      attendanceMarked: false,
      attendanceMessage: null,
      error: null,
    );
  }
}

final studentProvider = StateNotifierProvider<StudentNotifier, StudentState>((
  ref,
) {
  return StudentNotifier();
});
